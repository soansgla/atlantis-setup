# Security groups

This module will create security groups based on a map input of attributes.

It supports the following:

- Ingress/Egress
- IPv4/IPv6 CIDR Blocks as a source/destination
- To/From Ports
- Prefix Lists as a source/destination
- Protocol
- Self
- Security Group as source/destination
- Descriptions per rule

**Note:** This module uses an experimental feature to allow the definition of all object types in the variable `security_groups`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.60 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for all security groups | `string` | n/a | yes |
| <a name="input_security_group_rule_templates"></a> [security\_group\_rule\_templates](#input\_security\_group\_rule\_templates) | Map of template objects for creation of security groups | <pre>map(object({<br>    template_name            = optional(string)<br>    port                     = optional(number)<br>    from_port                = optional(number)<br>    to_port                  = optional(number)<br>    protocol                 = optional(string)<br>    cidr_blocks              = optional(list(string))<br>    ipv6_cidr_blocks         = optional(list(string))<br>    prefix_list_ids          = optional(list(string))<br>    source_security_group_id = optional(string)<br>    self                     = optional(bool)<br>    description              = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of objects for creation of security groups | <pre>map(object({<br>    description = optional(string)<br>    ingress = optional(map(object({<br>      template_name            = optional(string)<br>      port                     = optional(number)<br>      from_port                = optional(number)<br>      to_port                  = optional(number)<br>      protocol                 = optional(string)<br>      cidr_blocks              = optional(list(string))<br>      ipv6_cidr_blocks         = optional(list(string))<br>      prefix_list_ids          = optional(list(string))<br>      source_security_group_id = optional(string)<br>      self                     = optional(bool)<br>      description              = optional(string)<br>    })))<br>    egress = optional(map(object({<br>      template_name            = optional(string)<br>      port                     = optional(number)<br>      from_port                = optional(number)<br>      to_port                  = optional(number)<br>      protocol                 = optional(string)<br>      cidr_blocks              = optional(list(string))<br>      ipv6_cidr_blocks         = optional(list(string))<br>      prefix_list_ids          = optional(list(string))<br>      source_security_group_id = optional(string)<br>      self                     = optional(bool)<br>      description              = optional(string)<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The map of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used by security groups | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | Map of created security groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
