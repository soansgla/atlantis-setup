# AWS Virtual Private Network
resource "aws_vpc" "vpc" {
  #checkov:skip=CKV2_AWS_11: We may not always want vpc flow logs (test environments).
  #checkov:skip=CKV2_AWS_12: We have a default security group which blocks all traffic.
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# AWS Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name_prefix}-internet-gw"
  }
}

# AWS Subnets - Public
resource "aws_subnet" "public_subnets" {
  # checkov:skip=CKV_AWS_130: These are explicitly public subnets.
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.public_subnets_cidrs_per_availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-net-${element(var.availability_zones, count.index)}"
  }
}

# Elastic IPs for NAT
resource "aws_eip" "nat_eip" {
  #checkov:skip=CKV2_AWS_19: This is conditional.
  count = var.single_nat ? 1 : length(var.availability_zones)
  vpc   = true
  tags = {
    Name = "${var.name_prefix}-nat-eip-${element(var.availability_zones, count.index)}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count         = var.single_nat ? 1 : length(var.availability_zones)
  allocation_id = var.single_nat ? aws_eip.nat_eip[0].id : element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = var.single_nat ? aws_subnet.public_subnets[0].id : element(aws_subnet.public_subnets.*.id, count.index)

  tags = {
    Name = "${var.name_prefix}-nat-gw-${element(var.availability_zones, count.index)}"
  }

  depends_on = [
    aws_internet_gateway.internet_gw
  ]
}

# Public route table
resource "aws_route_table" "public_subnets_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name_prefix}-public-rt-${element(var.availability_zones, count.index)}"
  }
}

# Public route to access internet
resource "aws_route" "public_internet_route" {
  count = length(var.availability_zones)
  depends_on = [
    aws_internet_gateway.internet_gw,
    aws_route_table.public_subnets_route_table,
  ]
  route_table_id         = element(aws_route_table.public_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

# Association of Route Table to Subnets
resource "aws_route_table_association" "public_internet_route_table_associations" {
  count          = length(var.public_subnets_cidrs_per_availability_zone)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.public_subnets_route_table.*.id, count.index)
}

# AWS Subnets - Private
resource "aws_subnet" "private_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.private_subnets_cidrs_per_availability_zone, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name_prefix}-private-net-${element(var.availability_zones, count.index)}"
  }
}

# Private route table
resource "aws_route_table" "private_subnets_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name_prefix}-private-rt-${element(var.availability_zones, count.index)}"
  }
}

# Private route to access internet
resource "aws_route" "private_internet_route" {
  count = length(var.availability_zones)
  depends_on = [
    aws_internet_gateway.internet_gw,
    aws_route_table.private_subnets_route_table,
  ]
  route_table_id         = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat ? aws_nat_gateway.nat_gw[0].id : element(aws_nat_gateway.nat_gw.*.id, count.index)
}

# Association of Route Table to Subnets
resource "aws_route_table_association" "private_internet_route_table_associations" {
  count     = length(var.private_subnets_cidrs_per_availability_zone)
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(
    aws_route_table.private_subnets_route_table.*.id,
    count.index,
  )
}

# Default SG for VPC - Ensures the default SG restricts all traffic.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ensure NACL are attached to subnets
resource "aws_network_acl" "private" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.private_subnets[count.index].id]

  dynamic "ingress" {
    for_each = var.network_acl_private_ingress
    content {
      action     = lookup(ingress.value, "action", null)
      from_port  = lookup(ingress.value, "from_port", null)
      protocol   = lookup(ingress.value, "protocol", null)
      rule_no    = lookup(ingress.value, "rule_no", null)
      to_port    = lookup(ingress.value, "to_port", null)
      cidr_block = lookup(ingress.value, "cidr_block", null)
    }
  }

  dynamic "egress" {
    for_each = var.network_acl_private_egress
    content {
      action     = lookup(egress.value, "action", null)
      from_port  = lookup(egress.value, "from_port", null)
      protocol   = lookup(egress.value, "protocol", null)
      rule_no    = lookup(egress.value, "rule_no", null)
      to_port    = lookup(egress.value, "to_port", null)
      cidr_block = lookup(egress.value, "cidr_block", null)
    }
  }

  tags = var.tags
}

resource "aws_network_acl" "public" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public_subnets[count.index].id]

  dynamic "ingress" {
    for_each = var.network_acl_public_ingress
    content {
      action     = lookup(ingress.value, "action", null)
      from_port  = lookup(ingress.value, "from_port", null)
      protocol   = lookup(ingress.value, "protocol", null)
      rule_no    = lookup(ingress.value, "rule_no", null)
      to_port    = lookup(ingress.value, "to_port", null)
      cidr_block = lookup(ingress.value, "cidr_block", null)
    }
  }

  dynamic "egress" {
    for_each = var.network_acl_public_egress
    content {
      action     = lookup(egress.value, "action", null)
      from_port  = lookup(egress.value, "from_port", null)
      protocol   = lookup(egress.value, "protocol", null)
      rule_no    = lookup(egress.value, "rule_no", null)
      to_port    = lookup(egress.value, "to_port", null)
      cidr_block = lookup(egress.value, "cidr_block", null)
    }
  }

  tags = var.tags
}

# Transit Gateway Attachment on Private Subnet and Route on Private Route Table
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  count = var.transit_gateway_id != "" ? 1 : 0

  subnet_ids         = aws_subnet.private_subnets.*.id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    { "Name" : "Transit Gateway Attachment ${var.name_prefix}-vpc" }
  )
}

resource "aws_route" "private_transit_gateway_route" {
  count = var.transit_gateway_id != "" ? length(var.availability_zones) : 0

  route_table_id         = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = var.transit_gateway_private_route_destination_cidr
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [
    aws_route_table.private_subnets_route_table,
    aws_ec2_transit_gateway_vpc_attachment.vpc
  ]
}

resource "aws_route" "foreign_transit_gateway_route" {
  count = (length(var.transit_gateway_foreign_rtb_id) > 0 && var.transit_gateway_id != "") ? length(var.transit_gateway_foreign_rtb_id) : 0

  route_table_id         = element(var.transit_gateway_foreign_rtb_id, count.index)
  destination_cidr_block = aws_vpc.vpc.cidr_block
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.vpc
  ]
}
