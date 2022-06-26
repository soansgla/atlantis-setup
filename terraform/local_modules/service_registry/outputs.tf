output "arn" {
  description = "ARN of Service Registry Namespace"
  value       = aws_service_discovery_private_dns_namespace.default.arn
}

output "hosted_zone" {
  description = "Route53 Hosted Zone of Service Registry Namespace"
  value       = aws_service_discovery_private_dns_namespace.default.hosted_zone
}

output "id" {
  description = "ID of Service Registry Namespace"
  value       = aws_service_discovery_private_dns_namespace.default.id
}

output "name" {
  description = "Name of Service Registry Namespace"
  value       = aws_service_discovery_private_dns_namespace.default.name
}
