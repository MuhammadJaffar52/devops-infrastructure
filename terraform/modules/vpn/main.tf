resource "aws_security_group" "vpn_sg" {
  name   = "vpn-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg"
  }
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  count = var.server_certificate_arn != "" ? 1 : 0
  description            = "devops-client-vpn"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block

  split_tunnel       = true
  transport_protocol = "udp"
  vpn_port           = 443

  vpc_id = var.vpc_id

  security_group_ids = [aws_security_group.vpn_sg.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_root_certificate_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name = "devops-client-vpn"
  }
}

resource "aws_ec2_client_vpn_network_association" "private" {
  count = length(var.private_subnets)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.private_subnets[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "allow_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}