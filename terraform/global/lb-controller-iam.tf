# ============================================================
# IAM ROLE FOR AWS LOAD BALANCER CONTROLLER (IRSA)
# ============================================================

data "aws_iam_policy_document" "alb_assume_role" {

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

# ============================================================
# IAM ROLE
# ============================================================

resource "aws_iam_role" "alb_controller" {

  name = "${local.project_name}-${local.environment}-alb-controller-role"

  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json

  tags = {
    Name        = "alb-controller-role"
    Environment = local.environment
  }
}

# ============================================================
# ATTACH ALB POLICY
# ============================================================

resource "aws_iam_role_policy" "alb_controller_policy" {

  name = "${local.project_name}-${local.environment}-alb-policy"

  role = aws_iam_role.alb_controller.id

  policy = file("${path.module}/alb-controller-policy.json")
}