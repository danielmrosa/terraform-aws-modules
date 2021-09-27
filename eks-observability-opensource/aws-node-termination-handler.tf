resource "helm_release" "aws-node-termination-handler" {
  name       = "aws-node-termination-handler"
  version    = "0.13.3"

  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"

  set {
    name  = "serviceAccount.name"
    value = "aws-node-termination-handler"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "nodeSelector.node\\.kubernetes\\.io/lifecycle"
    value = "spot"
  }

}