data "aws_region" "current" {}

resource "null_resource" "scale_down_asg" {
  count = var.asg_name != null ? 1 : 0
  triggers = {
    asg_name   = var.asg_name,
    asg_region = data.aws_region.current.name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws autoscaling update-auto-scaling-group --auto-scaling-group-name=${self.triggers.asg_name} --min-size 0 --desired-capacity 0 --region=${self.triggers.asg_region}"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy
    content {
      capacity_provider = lookup(strategy.value, "capacity_provider", null)
      weight            = lookup(strategy.value, "weight", null)
      base              = lookup(strategy.value, "base", null)
    }
  }

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}
