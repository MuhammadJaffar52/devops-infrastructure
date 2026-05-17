# =========================================================
# VPC ID
# =========================================================

output "vpc_id" {

  description = "VPC ID"

  value = aws_vpc.main.id
}

# =========================================================
# VPC CIDR
# =========================================================

output "vpc_cidr" {

  description = "VPC CIDR Block"

  value = aws_vpc.main.cidr_block
}

# =========================================================
# PUBLIC SUBNET IDS
# =========================================================

output "public_subnet_ids" {

  description = "Public subnet IDs"

  value = [

    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

# =========================================================
# PRIVATE SUBNET IDS
# =========================================================

output "private_subnet_ids" {

  description = "Private subnet IDs"

  value = [

    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

# =========================================================
# AVAILABILITY ZONES
# =========================================================

output "availability_zones" {

  description = "Availability zones used"

  value = local.azs
}

# =========================================================
# INTERNET GATEWAY
# =========================================================

output "internet_gateway_id" {

  description = "Internet Gateway ID"

  value = aws_internet_gateway.igw.id
}

# =========================================================
# NAT GATEWAY
# =========================================================

output "nat_gateway_id" {

  description = "NAT Gateway ID"

  value = aws_nat_gateway.nat.id
}

# =========================================================
# ROUTE TABLE IDS
# =========================================================

output "public_route_table_id" {

  description = "Public Route Table ID"

  value = aws_route_table.public.id
}

output "private_route_table_id" {

  description = "Private Route Table ID"

  value = aws_route_table.private.id
}