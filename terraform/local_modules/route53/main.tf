data "aws_region" "current" {}

resource "aws_route53_zone" "private" {
  count = var.private_enabled ? 1 : 0

  name          = var.domain_name
  comment       = var.comment
  force_destroy = var.force_destroy
  tags          = var.tags
  # Main VPC DNS Association (compulsory)
  vpc {
    vpc_id = var.vpc_id
  }
  # Additional VPCs Association as a list (optional)
  dynamic "vpc" {
    for_each = var.additional_vpcs

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "region", data.aws_region.current.name)
    }
  }
}

resource "aws_route53_zone" "public" {
  count = var.public_enabled ? 1 : 0

  name              = var.domain_name
  delegation_set_id = var.delegation_set_id
  comment           = var.comment
  force_destroy     = var.force_destroy
  tags              = var.tags
}

resource "aws_route53_record" "default" {
  count = var.record_enabled && length(var.ttls) > 0 ? length(var.ttls) : 0

  zone_id                          = var.zone_id != "" ? var.zone_id : (var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : aws_route53_zone.public.*.zone_id[0])
  name                             = element(var.names, count.index)
  type                             = element(var.types, count.index)
  ttl                              = element(var.ttls, count.index)
  records                          = split(",", element(var.values, count.index))
  set_identifier                   = length(var.set_identifiers) > 0 ? element(var.set_identifiers, count.index) : ""
  health_check_id                  = length(var.health_check_ids) > 0 ? element(var.health_check_ids, count.index) : ""
  multivalue_answer_routing_policy = length(var.multivalue_answer_routing_policies) > 0 ? element(var.multivalue_answer_routing_policies, count.index) : null
  allow_overwrite                  = length(var.allow_overwrites) > 0 ? element(var.allow_overwrites, count.index) : false

  dynamic "failover_routing_policy" {
    for_each = var.failover_routing_policy != null ? [var.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = var.geolocation_routing_policy != null ? [var.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = var.latency_routing_policy != null ? [var.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = var.weighted_routing_policy != null ? [var.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }
}

resource "aws_route53_record" "alias" {
  count = var.record_enabled && length(var.alias) > 0 && length(var.alias["names"]) > 0 ? length(var.alias["names"]) : 0

  zone_id                          = var.zone_id
  name                             = element(var.names, count.index)
  type                             = element(var.types, count.index)
  set_identifier                   = length(var.set_identifiers) > 0 ? element(var.set_identifiers, count.index) : ""
  health_check_id                  = length(var.health_check_ids) > 0 ? element(var.health_check_ids, count.index) : ""
  multivalue_answer_routing_policy = length(var.multivalue_answer_routing_policies) > 0 ? element(var.multivalue_answer_routing_policies, count.index) : null
  allow_overwrite                  = length(var.allow_overwrites) > 0 ? element(var.allow_overwrites, count.index) : false

  alias {
    name                   = length(var.alias) > 0 ? element(var.alias["names"], count.index) : ""
    zone_id                = length(var.alias) > 0 ? element(var.alias["zone_ids"], count.index) : ""
    evaluate_target_health = length(var.alias) > 0 ? element(var.alias["evaluate_target_healths"], count.index) : false
  }

  dynamic "failover_routing_policy" {
    for_each = var.failover_routing_policy != null ? [var.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = var.geolocation_routing_policy != null ? [var.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = var.latency_routing_policy != null ? [var.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = var.weighted_routing_policy != null ? [var.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }
}

# Add to a existing Route53 Private Zone VPC association with a list of var.additional_vpcs
resource "aws_route53_zone_association" "additional_vpcs" {
  for_each = {
    for k, v in var.additional_vpcs : k => v
    if v.vpc_id != "" && var.private_enabled == false
  }

  zone_id    = var.zone_id
  vpc_id     = lookup(each.value, "vpc_id")
  vpc_region = lookup(each.value, "region", data.aws_region.current.name)
}

# @todo: Remove secondary_vpc_id variable and this default resource in next major release.
resource "aws_route53_zone_association" "default" {
  count = var.enabled && var.secondary_vpc_id != "" ? 1 : 0

  zone_id = var.private_enabled ? aws_route53_zone.private.*.zone_id[0] : var.zone_id
  vpc_id  = var.secondary_vpc_id
}
