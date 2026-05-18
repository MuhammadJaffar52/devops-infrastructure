variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

# =========================================================
# KUBERNETES VERSION
# =========================================================

variable "kubernetes_version" {

  description = "EKS Kubernetes version"

  type = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
}

variable "instance_types" {
  description = "EKS worker node instance types"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node count"
  type        = number
}

variable "min_size" {
  description = "Minimum node count"
  type        = number
}

variable "max_size" {
  description = "Maximum node count"
  type        = number
}

variable "server_certificate_arn" {
  description = "VPN server certificate ARN"
  type        = string
}

variable "client_root_certificate_arn" {
  description = "VPN client root certificate ARN"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}
