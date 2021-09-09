resource "helm_release" "keda" {
  name       = "keda"
  chart      = "keda"
  repository = "https://kedacore.github.io/charts"
  version    = "2.4.0"
  create_namespace = true
  namespace  = "keda"
  timeout = "600"
}