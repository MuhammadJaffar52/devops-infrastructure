# =========================================================
# CLIENT VPN ENDPOINT ID
# =========================================================
# =========================================================
# CLIENT VPN ENDPOINT ID
# =========================================================

# =========================================================
# CLIENT VPN ENDPOINT ID
# =========================================================

output "client_vpn_endpoint_id" {

  description = "AWS Client VPN endpoint ID"

  value = length(aws_ec2_client_vpn_endpoint.this) > 0 ? aws_ec2_client_vpn_endpoint.this[0].id : null
}

# =========================================================
# CLIENT VPN DNS
# =========================================================

output "client_vpn_dns" {

  description = "Client VPN DNS name"

  value = length(aws_ec2_client_vpn_endpoint.this) > 0 ? aws_ec2_client_vpn_endpoint.this[0].dns_name : null
}

# =========================================================
# SECURITY GROUP ID
# =========================================================

output "vpn_security_group_id" {

  description = "Security group used by VPN"

  value = aws_security_group.vpn_sg.id
}