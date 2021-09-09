resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "3.3.0"
  create_namespace = true
  timeout       = "600"
  values = [<<EOF
  controller:
    updateStrategy:
      type: RollingUpdate
    kind: "DaemonSet"
    service:
      enableHttp: false
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
        service.beta.kubernetes.io/aws-load-balancer-type: nlb
    config:
      enable-underscores-in-headers: "true"
EOF
  ]
}