# =========================================================
# SECURITY GROUP FOR CLIENT VPN
# =========================================================

resource "aws_security_group" "vpn_sg" {

  name   = "${var.environment}-vpn-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Client VPN access"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-vpn-sg"
    Environment = var.environment
  }
}

# =========================================================
# CLIENT VPN ENDPOINT
# =========================================================

resource "aws_ec2_client_vpn_endpoint" "this" {

  count = var.enabled ? 1 : 0

  description            = "${var.environment}-client-vpn"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block

  split_tunnel       = true
  transport_protocol  = "udp"
  vpn_port           = 443

  security_group_ids = [aws_security_group.vpn_sg.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_root_certificate_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name        = "${var.environment}-client-vpn"
    Environment = var.environment
  }
}

# =========================================================
# VPN NETWORK ASSOCIATION (PRIVATE SUBNETS)
# =========================================================

resource "aws_ec2_client_vpn_network_association" "private" {

  count = var.enabled ? length(var.private_subnets) : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this[0].id
  subnet_id              = var.private_subnets[count.index]
}

# =========================================================
# AUTHORIZATION RULE (ALLOW VPC ACCESS)
# =========================================================

resource "aws_ec2_client_vpn_authorization_rule" "allow_vpc" {

  count = var.enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this[0].id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}