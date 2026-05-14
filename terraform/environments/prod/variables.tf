variable "vpc_cidr" {
  type = string
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate for VPN"
  type        = string
}

variable "client_root_certificate_arn" {
  description = "ARN of the client root certificate for VPN"
  type        = string
}