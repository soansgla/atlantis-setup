#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "availability_zones" {
  description = "List of availability zones used by subnets"
  value       = var.availability_zones
}

#------------------------------------------------------------------------------
# AWS Internet Gateway
#------------------------------------------------------------------------------
output "internet_gateway_id" {
  description = "ID of the generated Internet Gateway"
  value       = aws_internet_gateway.internet_gw.id
}

#------------------------------------------------------------------------------
# AWS Subnets - Public
#------------------------------------------------------------------------------
output "public_subnets_ids" {
  description = "List with the Public Subnets IDs"
  value       = aws_subnet.public_subnets.*.id
}

output "public_subnets_route_table_id" {
  description = "ID of the Route Tables used on Public networks"
  value       = aws_route_table.public_subnets_route_table.*.id
}

output "nat_gw_ids" {
  description = "List with the IDs of the NAT Gateways created on public subnets to provide internet to private subnets"
  value       = aws_nat_gateway.nat_gw.*.id
}

#------------------------------------------------------------------------------
# AWS Subnets - Private
#------------------------------------------------------------------------------
output "private_subnets_ids" {
  description = "List with the Private Subnets IDs"
  value       = aws_subnet.private_subnets.*.id
}

output "private_subnets_route_table_id" {
  description = "ID of the Route Table used on Private networks"
  value       = aws_route_table.private_subnets_route_table.*.id
}

#------------------------------------------------------------------------------
# AWS Default Security Group
#------------------------------------------------------------------------------
output "default_security_group_id" {
  description = "Default Security Group ID for the VPC"
  value       = aws_default_security_group.default.id
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets"
  value       = length(var.public_subnets_cidrs_per_availability_zone) > 0 ? aws_subnet.public_subnets.*.cidr_block : null
}

output "private_subnet_cidr_blocks" {
  description = "Subnet CIDR blocks for the private subnets"
  value       = length(var.private_subnets_cidrs_per_availability_zone) > 0 ? aws_subnet.private_subnets.*.cidr_block : null
}

output "private_route_table_id" {
  description = "Route Table IDs for private VPC"
  value       = aws_vpc.vpc.main_route_table_id
}

#------------------------------------------------------------------------------
# AWS Transit Gateway Attachment
#------------------------------------------------------------------------------
output "transit_gateway_attachment_id" {
  description = "Transit Gateway Attachment ID for the VPC"
  value       = length(aws_ec2_transit_gateway_vpc_attachment.vpc) > 0 ? aws_ec2_transit_gateway_vpc_attachment.vpc.*.id : null
}
