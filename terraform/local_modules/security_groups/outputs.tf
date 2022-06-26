output "security_groups" {
  value = {
    for key, value in aws_security_group.this :
    key => {
      name        = value.name
      description = value.description
      arn         = value.arn
      id          = value.id
    }
  }
  description = "Map of created security groups"
}
