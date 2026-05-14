variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "client_cidr_block" {
  type    = string
  default = "172.16.0.0/22"
}
variable "server_certificate_arn" {
  type    = string
  default = null
}

variable "client_root_certificate_arn" {
  type    = string
  default = null
}