# Service Registry
resource "aws_service_discovery_private_dns_namespace" "default" {
  name        = "registry.${var.name}.local"
  description = var.description
  vpc         = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" : "registry.${var.name}.local" }
  )
}

# Route53 Private Zone with a list of VPC Id and region to associate
module "route53" {
  source = "../route53"

  zone_id         = aws_service_discovery_private_dns_namespace.default.hosted_zone
  additional_vpcs = var.additional_vpcs
  domain_name     = ""
}
