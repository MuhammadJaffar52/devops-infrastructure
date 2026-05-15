variable "aws_region" {
description = "AWS region"
type        = string
}


variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate for VPN"
  type        = string
}

variable "client_root_certificate_arn" {
  description = "ARN of the client root certificate for VPN"
  type        = string
}