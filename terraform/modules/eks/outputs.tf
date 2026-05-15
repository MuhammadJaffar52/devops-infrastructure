output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}
output "oidc_provider" {
  value = aws_iam_openid_connect_provider.eks.url
}