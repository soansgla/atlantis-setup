terraform {
  experiments = [module_variable_optional_attrs]
}

# AWS LOAD BALANCER

module "ecs_alb" {
  source   = "../ecs_alb"

  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id

  # Application Load Balancer
  internal                         = var.lb_internal
  security_groups                  = var.lb_security_groups
  drop_invalid_header_fields       = var.lb_drop_invalid_header_fields
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  idle_timeout                     = var.lb_idle_timeout
  enable_deletion_protection       = var.lb_enable_deletion_protection
  enable_cross_zone_load_balancing = var.lb_enable_cross_zone_load_balancing
  enable_http2                     = var.lb_enable_http2
  ip_address_type                  = var.lb_ip_address_type
  lb_egress_from_port              = var.lb_egress_from_port
  lb_egress_to_port                = var.lb_egress_to_port
  lb_egress_protocol               = var.lb_egress_protocol
  lb_egress_cidr                   = var.lb_egress_cidr

  # Access Control to Application Load Balancer
  http_ports                    = var.lb_http_ports
  http_ingress_cidr_blocks      = var.lb_http_ingress_cidr_blocks
  http_ingress_prefix_list_ids  = var.lb_http_ingress_prefix_list_ids

  # Target Groups
  deregistration_delay                          = var.lb_deregistration_delay
  slow_start                                    = var.lb_slow_start
  load_balancing_algorithm_type                 = var.lb_load_balancing_algorithm_type
  stickiness                                    = var.lb_stickiness
  target_group_health_check_enabled             = var.lb_target_group_health_check_enabled
  target_group_health_check_interval            = var.lb_target_group_health_check_interval
  target_group_health_check_path                = var.lb_target_group_health_check_path
  target_group_health_check_timeout             = var.lb_target_group_health_check_timeout
  target_group_health_check_healthy_threshold   = var.lb_target_group_health_check_healthy_threshold
  target_group_health_check_unhealthy_threshold = var.lb_target_group_health_check_unhealthy_threshold
  target_group_health_check_matcher             = var.lb_target_group_health_check_matcher

  # Certificates
  default_certificate_arn                         = var.default_certificate_arn
  ssl_policy                                      = var.ssl_policy

  tags = var.tags
}


# AWS ECS SERVICE
resource "aws_ecs_service" "default" {
  name                               = "${var.name_prefix}-service"
  cluster                            = var.ecs_cluster_arn
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = var.launch_type
  enable_execute_command             = var.enable_ecs_exec
  force_new_deployment               = var.force_new_deployment

  dynamic "load_balancer" {
    for_each = module.ecs_alb.lb_http_tgs_map_arn_port 
    content {
      target_group_arn = load_balancer.key
      container_name   = var.container_name
      container_port   = load_balancer.value
    }
  }
  
  network_configuration {
    security_groups = concat([
      aws_security_group.ecs_tasks_sg.id], var.security_groups
    )
    subnets          = var.assign_public_ip ? var.public_subnets : var.private_subnets
    assign_public_ip = var.assign_public_ip
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = lookup(ordered_placement_strategy.value, "field", null)
    }
  }
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }
  platform_version = var.launch_type == "FARGATE" ? var.platform_version : null
  propagate_tags   = var.propagate_tags

  dynamic "service_registries" {
    for_each = length(var.service_registry_namespace_id) > 0 ? [
    var.service_registry_namespace_id] : []
    content {
      registry_arn = length(var.service_registry_namespace_id) > 0 ? aws_service_discovery_service.default[0].arn : null
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  task_definition = var.task_definition_arn

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-ecs-tasks"
    }
  )
}

# AWS SECURITY GROUP - ECS Tasks, allow traffic only from the Application Load Balancer
resource "aws_security_group" "ecs_tasks_sg" {
  #checkov:skip=CKV2_AWS_5: This SG is referenced and used by the tasks/alb.

  name        = "${var.name_prefix}-ecs-tasks"
  description = "Allow inbound access from the LB only"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-ecs-tasks"
    }
  )
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.ecs_tasks_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = var.tasks_egress_cidr
  description       = "Allow all tasks to egress on defined ports/protocols/cidr blocks"
}

resource "aws_security_group_rule" "egress_prefix_lists" {
  count = length(var.tasks_egress_prefix_list_ids) > 0 ? 1 : 0

  security_group_id = aws_security_group.ecs_tasks_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  prefix_list_ids   = var.tasks_egress_prefix_list_ids
  description       = "Allow all tasks to egress to managed prefix lists."
}

resource "aws_security_group_rule" "ingress_through_http" {
  for_each = toset(module.ecs_alb.lb_http_tgs_ports)

  security_group_id        = aws_security_group.ecs_tasks_sg.id
  type                     = "ingress"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  source_security_group_id = module.ecs_alb.aws_security_group_lb_access_sg_id
  description              = "Ingress through HTTP for port ${each.key}"
}

# Service Discovery

resource "aws_service_discovery_service" "default" {
  count = length(var.service_registry_namespace_id) > 0 ? 1 : 0

  name        = var.name_prefix
  description = "${var.name_prefix} discovery service"

  dns_config {
    namespace_id = var.service_registry_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# AWS Application AutoScaling

resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling != null ? 1 : 0

  max_capacity       = var.autoscaling.max_capacity
  min_capacity       = var.autoscaling.min_capacity
  resource_id        = split(":", aws_ecs_service.default.id)[5]
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

locals {
  predefined_metric_type = {
    "cpu"    = "ECSServiceAverageCPUUtilization"
    "memory" = "ECSServiceAverageMemoryUtilization"
  }
}

resource "aws_appautoscaling_policy" "this" {
  for_each = length(try(var.autoscaling.policy, {})) > 0 ? {
    for policy_name, policy_value in var.autoscaling.policy :
    policy_name => policy_value if policy_value != null
  } : {}

  name               = each.key
  policy_type        = "TargetTrackingScaling"
  resource_id        = one(aws_appautoscaling_target.this[*].resource_id)
  scalable_dimension = one(aws_appautoscaling_target.this[*].scalable_dimension)
  service_namespace  = one(aws_appautoscaling_target.this[*].service_namespace)

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = defaults(each.value, { disable_scale_in = true }).disable_scale_in
    scale_in_cooldown  = defaults(each.value, { scale_in_cooldown = 300 }).scale_in_cooldown
    scale_out_cooldown = defaults(each.value, { scale_out_cooldown = 300 }).scale_out_cooldown
    target_value       = each.value.target_value
    predefined_metric_specification {
      predefined_metric_type = local.predefined_metric_type[each.key]
    }
  }
}
