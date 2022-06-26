terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_security_group" "this" {
  # checkov:skip=CKV2_AWS_5:This module only create security groups and they will be used in another modules.
  for_each    = var.security_groups
  name        = "${var.name_prefix}-${each.key}"
  vpc_id      = var.vpc_id
  description = each.value.description

  tags = merge(
    var.tags,
    { "Name" = "${var.name_prefix}-${each.key}" }
  )
}

locals {
  ingress = flatten([
    for sg_name, sg in var.security_groups : [
      for i_rule_name, i_rule in(sg.ingress != null ? sg.ingress : {}) : {
        key   = join("-", [sg_name, i_rule_name])
        value = merge(i_rule.template_name != null ? var.security_group_rule_templates[i_rule.template_name] : i_rule, { "security_group_name" = sg_name })
      }
    ]
  ])
  egress = flatten([
    for sg_name, sg in var.security_groups : [
      for e_rule_name, e_rule in(sg.egress != null ? sg.egress : {}) : {
        key   = join("-", [sg_name, e_rule_name])
        value = merge(e_rule.template_name != null ? var.security_group_rule_templates[e_rule.template_name] : e_rule, { "security_group_name" = sg_name })
      }
    ]
  ])
  ingress_map = { for item in local.ingress : item.key => item.value }
  egress_map  = { for item in local.egress : item.key => item.value }
}

resource "aws_security_group_rule" "ingress" {
  for_each         = local.ingress_map
  type             = "ingress"
  from_port        = defaults(each.value, { from_port = each.value.port }).from_port
  to_port          = defaults(each.value, { to_port = each.value.port }).to_port
  protocol         = defaults(each.value, { protocol : "tcp" }).protocol
  cidr_blocks      = each.value.cidr_blocks
  ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
  prefix_list_ids  = each.value.prefix_list_ids
  source_security_group_id = each.value.source_security_group_id == null ? null : (
    # If we provide source_security_group_id as sg id it will pass as is.
    length(regexall("sg-[a-f0-9]+", each.value.source_security_group_id)) > 0 ? each.value.source_security_group_id : (
      # We have second condition to avoud evaluation false part, because aws_security_group.this doesn't have key if it's sg group id.
      # Also it will fail if we provide source_security_group_id refs which isn't in var.security_groups.
      length(regexall("sg-[a-f0-9]+", each.value.source_security_group_id)) == 0 ? aws_security_group.this[each.value.source_security_group_id].id : null
  ))
  self              = each.value.self
  description       = each.value.description
  security_group_id = aws_security_group.this[each.value.security_group_name].id
}

resource "aws_security_group_rule" "egress" {
  for_each         = local.egress_map
  type             = "egress"
  from_port        = defaults(each.value, { from_port = each.value.port }).from_port
  to_port          = defaults(each.value, { to_port = each.value.port }).to_port
  protocol         = defaults(each.value, { protocol : "tcp" }).protocol
  cidr_blocks      = each.value.cidr_blocks
  ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
  prefix_list_ids  = each.value.prefix_list_ids
  source_security_group_id = each.value.source_security_group_id == null ? null : (
    # If we provide source_security_group_id as sg id it will pass as is.
    length(regexall("sg-[a-f0-9]+", each.value.source_security_group_id)) > 0 ? each.value.source_security_group_id : (
      # We have second condition to avoud evaluation false part, because aws_security_group.this doesn't have key if it's sg group id.
      # Also it will fail if we provide source_security_group_id refs which isn't in var.security_groups.
      length(regexall("sg-[a-f0-9]+", each.value.source_security_group_id)) == 0 ? aws_security_group.this[each.value.source_security_group_id].id : null
  ))
  self              = each.value.self
  description       = each.value.description
  security_group_id = aws_security_group.this[each.value.security_group_name].id
}
