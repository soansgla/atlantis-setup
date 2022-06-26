output "arn" {
  value       = var.zone_id != "" ? "" : (var.public_enabled ? join("", aws_route53_zone.public.*.arn) : join("", aws_route53_zone.private.*.arn))
  description = "The Hosted Zone ARN. This can be referenced by zone records."
}

output "name" {
  value       = var.zone_id != "" ? "" : (var.public_enabled ? join("", aws_route53_zone.public.*.name) : join("", aws_route53_zone.private.*.name))
  description = "The hosted zone name."
}

output "zone_id" {
  value       = var.zone_id != "" ? "" : (var.public_enabled ? join("", aws_route53_zone.public.*.zone_id) : join("", aws_route53_zone.private.*.zone_id))
  description = "The Hosted Zone ID. This can be referenced by zone records."
}

output "name_servers" {
  value       = var.zone_id != "" ? [] : (var.public_enabled ? aws_route53_zone.public.*.name_servers : aws_route53_zone.private.*.name_servers)
  description = "A list of name servers in associated (or default) delegation set."
}
