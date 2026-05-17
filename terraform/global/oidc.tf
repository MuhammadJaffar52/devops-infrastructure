# ============================================================
# OIDC PROVIDER FOR EKS (IRSA ENABLEMENT)
# ============================================================

# Get EKS cluster info (SAFE & REQUIRED)
data "aws_eks_cluster" "this" {
  name = local.eks_cluster_name
}

# Get TLS certificate from OIDC issuer
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ============================================================
# IAM OIDC PROVIDER
# ============================================================

resource "aws_iam_openid_connect_provider" "eks" {

  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-${local.environment}-eks-oidc"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}