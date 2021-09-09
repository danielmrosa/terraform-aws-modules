resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "16.11.0"
  namespace  = "observability"
  timeout = "900"
  create_namespace = true
  values = [<<EOF
global:
  rbac:
    create: true
    pspEnabled: false
grafana:
  image:
    repository: grafana/grafana
    tag: latest
  enabled: true
  additionalDataSources:
  - name: 'Tracing'
    uid: tracing
    type: tempo
    url: http://grafana-tempo-tempo-distributed-query-frontend:3100
    access: proxy
    withCredentials: false
    isDefault: false
    jsonData:
      tlsAuth: false
      tlsAuthWithCACert: false
      tracesToLogs:
        datasourceUid: 'Logs'
  - name: 'Logs'
    type: loki
    url: http://loki:3100
    access: proxy
    jsonData:
      derivedFields:
        - datasourceUid: tracing
          matcherRegex: "trace_id=(\\w+)"
          name: Tracing
          url: "$$${__value.raw}"
  grafana.ini:
    auth:
      sigv4_auth_enabled: true
prometheus:
  enabled: true
  servicePerReplica:
    targetPort: 8005
  prometheusSpec:
    enableFeatures:
    - exemplar-storage
    containers:
    - image: "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
      name: aws-sigv4-proxy
      args:
      - --name
      - aps
      - --region
      - us-east-1
      - --host
      - aps-workspaces.us-east-1.amazonaws.com
      - --port
      - :8005
      ports:
      - name: aws-sigv4-proxy
        containerPort: 8005
EOF
  ]
}

resource "helm_release" "loki" {
  provider         = helm
  name             = "loki"
  repository       = "https://grafana.github.io/loki/charts"
  chart            = "loki"
  version          = "0.31.1"
  namespace        = "observability"
  timeout          = "600"
  create_namespace = true

  values = [<<EOF
 serviceAccount:
  name: loki-irsa
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-loki-irsa"
 replicas: 1
 config:
  schema_config:
    configs:
    - from: 2020-10-30
      store: aws
      object_store: s3
      schema: v11
      index:
        prefix: obs-loki-index-
        period: 24h
  storage_config:
    aws:
      s3: s3://${var.region}/${aws_s3_bucket.obs-loki.id}
      dynamodb:
        dynamodb_url: dynamodb://${var.region}
  table_manager:
    retention_deletes_enabled: true
    retention_period: 24h
    index_tables_provisioning:
      enable_ondemand_throughput_mode: true
      enable_inactive_throughput_on_demand_mode: true
    chunk_tables_provisioning:
      enable_ondemand_throughput_mode: true
      enable_inactive_throughput_on_demand_mode: true

 EOF
  ]
  depends_on = [
    aws_iam_policy.aws-dynamodb-loki-policy-obs,
    aws_iam_policy.aws-s3-loki-policy-obs,
    aws_s3_bucket.obs-loki
  ]

}

resource "helm_release" "promtail" {
  provider         = helm
  name             = "promtail"
  repository       = "https://grafana.github.io/loki/charts"
  chart            = "promtail"
  version          = "0.24.0"
  namespace        = "observability"
  timeout          = "600"
  create_namespace = true

  values = [<<EOF
 livenessProbe: []
 readinessProbe: []
 scrapeConfigs:
 - job_name: kubernetes-pods
   pipeline_stages:
   - docker: {}
   - json:
       expressions:
         output: msg
         level: level
         timestamp: time
   - timestamp:
       source: timestamp
       format: Unix
       action_on_failure: skip
   - labels:
         level:
   - output:
       source: output
   kubernetes_sd_configs:
   - role: pod
   relabel_configs:
   - action: labelmap
     regex: __meta_kubernetes_pod_label_(.+)
   - replacement: /var/log/pods/*$1*/*/*.log
     separator: /
     source_labels:
     - __meta_kubernetes_pod_uid
     target_label: __path__

EOF
  ]

  set {
    name  = "loki.serviceName"
    value = helm_release.loki.name
  }
  depends_on = [
    aws_iam_policy.aws-dynamodb-loki-policy-obs,
    aws_iam_policy.aws-s3-loki-policy-obs,
    helm_release.loki
  ]
}

resource "helm_release" "grafana-tempo" {
  name       = "grafana-tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  version    = "0.9.13"
  namespace  = "observability"
  timeout = "900"
  create_namespace = true
  values = [<<EOF
  serviceMonitor:
    enabled: true
  memcached:
    enabled: false
  serviceAccount:
    name: grafana-tempo-sa
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-grafana_tempo-irsa"
  traces:
    jaeger:
      grpc: true
      thriftBinary: true
      thriftCompact: true
      thriftHttp: true
    zipkin: false
    otlp:
      http: true
      grpc: true
  config: |
    auth_enabled: false
    compactor:
        compaction:
          block_retention: 1h
        ring:
          kvstore:
            store: memberlist
    distributor:
        receivers:
          jaeger:
            protocols:
              grpc:
                endpoint: 0.0.0.0:14250
              thrift_binary:
                endpoint: 0.0.0.0:6832
              thrift_compact:
                endpoint: 0.0.0.0:6831
              thrift_http:
                endpoint: 0.0.0.0:14268
    querier:
        frontend_worker:
          frontend_address: {{ include "tempo.queryFrontendFullname" . }}:9095
    ingester:
        lifecycler:
          ring:
            replication_factor: 1
    memberlist:
      bind_port: 7946
      join_members:
        - grafana-tempo-tempo-distributed-gossip-ring.observability.svc.cluster.local:7946  # A DNS entry that lists all tempo components.  A "Headless" Cluster IP service in Kubernetes
    overrides:
        # per_tenant_override_config: /conf/overrides.yaml
        ingestion_rate_strategy: global
    server:
        http_listen_port: 3100
    storage:
      trace:
        backend: s3
        s3:
          bucket: ${aws_s3_bucket.obs-tempo.id}
          endpoint: s3.dualstack.${var.region}.amazonaws.com
          insecure: true
          region: ${var.region}
        pool:
          queue_depth: 10000
          max_workers: 100
        wal:
          path: /var/tempo/wal
EOF
  ]
  depends_on = [
    helm_release.kube-prometheus-stack,
    aws_s3_bucket.obs-tempo,
    aws_iam_policy.grafana-tempo-obs
  ]
}

data "aws_iam_policy_document" "grafana-tempo" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.obs-tempo.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.obs-tempo.id}"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.obs-tempo.id}",
    ]
  }
}