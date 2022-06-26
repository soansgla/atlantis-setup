#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "Name prefix for resources on AWS"
}

variable "tags" {
  description = "Tags to use for resources that support them."
  type        = map(any)
  default     = {}
}

#------------------------------------------------------------------------------
# AWS Virtual Private Network
#------------------------------------------------------------------------------
variable "vpc_cidr_block" {
  type        = string
  description = "AWS VPC CIDR Block"
}

#------------------------------------------------------------------------------
# AWS Subnets
#------------------------------------------------------------------------------
variable "availability_zones" {
  type        = list(any)
  description = "List of availability zones to be used by subnets"
}

variable "public_subnets_cidrs_per_availability_zone" {
  type        = list(any)
  description = "List of CIDRs to use on each availability zone for public subnets"
}

variable "private_subnets_cidrs_per_availability_zone" {
  type        = list(any)
  description = "List of CIDRs to use on each availability zone for private subnets"
}

variable "single_nat" {
  type        = bool
  default     = false
  description = "enable single NAT Gateway"
}

# NACL Rules
variable "network_acl_private_ingress" {
  description = "Network ACL Private Ingress Rules"
  type = map(object({
    action     = string
    from_port  = number
    protocol   = string
    rule_no    = number
    to_port    = number
    cidr_block = string
  }))
  default = {
    default = {
      action     = "Allow"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  }
}

variable "network_acl_private_egress" {
  description = "Network ACL Private Egress Rules"
  type = map(object({
    action     = string
    from_port  = number
    protocol   = string
    rule_no    = number
    to_port    = number
    cidr_block = string
  }))
  default = {
    default = {
      action     = "Allow"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  }
}

variable "network_acl_public_ingress" {
  description = "Network ACL Public Ingress Rules"
  type = map(object({
    action     = string
    from_port  = number
    protocol   = string
    rule_no    = number
    to_port    = number
    cidr_block = string
  }))
  default = {
    default = {
      action     = "Allow"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  }
}

variable "network_acl_public_egress" {
  description = "Network ACL Public Egress Rules"
  type = map(object({
    action     = string
    from_port  = number
    protocol   = string
    rule_no    = number
    to_port    = number
    cidr_block = string
  }))
  default = {
    default = {
      action     = "Allow"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  }
}

#------------------------------------------------------------------------------
# AWS Transit Gateway (Optional configuration)
#------------------------------------------------------------------------------
variable "transit_gateway_id" {
  description = "Existing Transit Gateway Id to be attached to the VPC"
  type        = string
  default     = ""
}

variable "transit_gateway_private_route_destination_cidr" {
  description = "CIDR destination on Private Route table Route via Transit Gateway"
  type        = string
  default     = "10.0.0.0/8" # Default all private network traffic
}

variable "transit_gateway_foreign_rtb_id" {
  description = "Existing Route Table Ids from other VPCs to add route into VPC CIDR via Transit Gateway"
  type        = list(string)
  default     = []
}
