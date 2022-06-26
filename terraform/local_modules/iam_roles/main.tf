terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_iam_instance_profile" "this" {
  for_each = {
    for k, v in defaults(var.iam_roles, { "instance_profile" : false }) : k => v
    if v.instance_profile == true
  }

  name = aws_iam_role.this[each.key].name
  role = aws_iam_role.this[each.key].name
}

resource "aws_iam_role" "this" {
  for_each = var.iam_roles

  name                 = "${var.name_prefix}-${each.key}"
  assume_role_policy   = jsonencode(jsondecode(each.value.assume_role_policy))
  path                 = each.value.path
  max_session_duration = each.value.max_session_duration
  description          = each.value.description

  tags = var.tags
}

locals {
  policies = flatten([
    for role_name, role in var.iam_roles : [
      for policy_name, policy_rule in(role.policies != null ? role.policies : null) : {
        key   = join(":", [role_name, policy_name])
        value = policy_rule
      }
    ]
  ])
  policies_arn = flatten([
    for role_name, role in var.iam_roles : [
      for policy_name, policy_rule in(role.policies_arn != null ? role.policies_arn : {}) : {
        key   = join(":", [role_name, policy_name])
        value = policy_rule
      }
    ]
  ])
  policies_map     = { for item in local.policies : item.key => item.value }
  policies_arn_map = { for item in local.policies_arn : item.key => item.value }
}

resource "aws_iam_role_policy" "policy" {
  for_each = local.policies_map
  role     = aws_iam_role.this[split(":", each.key)[0]].name
  policy   = jsonencode(jsondecode(each.value))
}

resource "aws_iam_role_policy_attachment" "policy_arn" {
  for_each   = local.policies_arn_map
  role       = aws_iam_role.this[split(":", each.key)[0]].name
  policy_arn = each.value.policy_arn
}
