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

  description = "EKS cluster endpoint"

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
# OIDC PROVIDER URL
# =========================================================

output "oidc_provider_url" {

  description = "OIDC provider URL"

  value = aws_iam_openid_connect_provider.oidc.url
}

# =========================================================
# OIDC PROVIDER ARN
# =========================================================

output "oidc_provider_arn" {

  description = "OIDC provider ARN"

  value = aws_iam_openid_connect_provider.oidc.arn
}

# =========================================================
# EKS CLUSTER SECURITY GROUP
# =========================================================

output "cluster_security_group_id" {

  description = "Cluster security group ID"

  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

# =========================================================
# NODE GROUP NAME
# =========================================================

output "node_group_name" {

  description = "EKS node group name"

  value = aws_eks_node_group.nodes.node_group_name
}

# =========================================================
# NODE IAM ROLE ARN
# =========================================================

output "node_role_arn" {

  description = "EKS node IAM role ARN"

  value = aws_iam_role.eks_node_role.arn
}