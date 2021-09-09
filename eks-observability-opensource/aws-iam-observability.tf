# Loki Policy Documents

data "aws_iam_policy_document" "aws-dynamodb-loki" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/obs-loki-index-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
    ]
    resources = [
    "*"]
  }
}

data "aws_iam_policy_document" "aws-s3-loki" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:*",
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.obs-loki.arn,
      "${aws_s3_bucket.obs-loki.arn}/*"
    ]
  }
}


# Loki Policies

resource "aws_iam_policy" "aws-dynamodb-loki-policy-obs" {
  name   = "${random_id.random.hex}-aws-dynamodb-loki-policy-obs"
  policy = data.aws_iam_policy_document.aws-dynamodb-loki.json

  depends_on = [
    data.aws_iam_policy_document.aws-dynamodb-loki
  ]
}


resource "aws_iam_policy" "aws-s3-loki-policy-obs" {
  name   = "${random_id.random.hex}-aws-s3-loki-policy-obs"
  policy = data.aws_iam_policy_document.aws-s3-loki.json

  depends_on = [
    data.aws_iam_policy_document.aws-s3-loki
  ]
}

# Grafana Tempo Policy

resource "aws_iam_policy" "grafana-tempo-obs" {
  name   = "${random_id.random.hex}-grafana-tempo-policy-obs"
  path   = "/"
  policy = data.aws_iam_policy_document.grafana-tempo.json
}


# IRSA Grafana Tempo and Loki

module "iam_assumable_role_grafana-tempo" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 3.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-grafana_tempo-irsa"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.grafana-tempo-obs.arn]
  number_of_role_policy_arns    = 1
  oidc_fully_qualified_subjects = ["system:serviceaccount:observability:grafana-tempo-sa"]

  }

  module "iam_assumable_role_loki" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 3.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-loki-irsa"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.aws-s3-loki-policy-obs.arn,aws_iam_policy.aws-dynamodb-loki-policy-obs.arn]
  number_of_role_policy_arns    = 2
  oidc_fully_qualified_subjects = ["system:serviceaccount:observability:loki-irsa"]

  }