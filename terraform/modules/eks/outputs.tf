# =========================================================
# EKS CLUSTER NAME
# =========================================================

output "cluster_name" {

  description = "EKS cluster name"

  value = aws_eks_cluster.cluster.name
}

# =========================================================
# EKS CLUSTER ENDPOINT
# =========================================================

output "cluster_endpoint" {

  description = "EKS cluster API endpoint"

  value = aws_eks_cluster.cluster.endpoint
}

# =========================================================
# EKS CLUSTER ARN
# =========================================================

output "cluster_arn" {

  description = "EKS cluster ARN"

  value = aws_eks_cluster.cluster.arn
}

# =========================================================
# EKS OIDC PROVIDER URL
# =========================================================

output "oidc_provider_url" {

  description = "OIDC provider URL"

  value = aws_iam_openid_connect_provider.eks.url
}

# =========================================================
# EKS OIDC PROVIDER ARN
# =========================================================

output "oidc_provider_arn" {

  description = "OIDC provider ARN"

  value = aws_iam_openid_connect_provider.eks.arn
}

# =========================================================
# EKS SECURITY GROUP
# =========================================================

output "cluster_security_group_id" {

  description = "EKS cluster security group"

  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}