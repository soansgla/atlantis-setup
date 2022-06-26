output "iam_roles" {
  value = {
    for key, value in aws_iam_role.this :
    key => {
      name        = value.name
      description = value.description
      arn         = value.arn
      id          = value.id
    }
  }
  description = "The map of created roles"
}
