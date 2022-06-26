variable "name_prefix" {
  type        = string
  description = "Name prefix for all security groups"
}

variable "vpc_id" {
  description = "VPC ID to be used by security groups"
  type        = string
}

variable "security_groups" {
  type = map(object({
    description = optional(string)
    ingress = optional(map(object({
      template_name            = optional(string)
      port                     = optional(number)
      from_port                = optional(number)
      to_port                  = optional(number)
      protocol                 = optional(string)
      cidr_blocks              = optional(list(string))
      ipv6_cidr_blocks         = optional(list(string))
      prefix_list_ids          = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })))
    egress = optional(map(object({
      template_name            = optional(string)
      port                     = optional(number)
      from_port                = optional(number)
      to_port                  = optional(number)
      protocol                 = optional(string)
      cidr_blocks              = optional(list(string))
      ipv6_cidr_blocks         = optional(list(string))
      prefix_list_ids          = optional(list(string))
      source_security_group_id = optional(string)
      self                     = optional(bool)
      description              = optional(string)
    })))
  }))
  description = "Map of objects for creation of security groups"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "The map of tags to assign to all resources"
}

variable "security_group_rule_templates" {
  type = map(object({
    template_name            = optional(string)
    port                     = optional(number)
    from_port                = optional(number)
    to_port                  = optional(number)
    protocol                 = optional(string)
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
    description              = optional(string)
  }))
  default     = {}
  description = "Map of template objects for creation of security groups"
}
