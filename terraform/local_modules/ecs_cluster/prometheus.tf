module "ecs_cloudwatch_agent_service" {
  for_each = var.prometheus_enabled ? toset(["cw"]) : toset([])

  source = "../ecs_service"

  name_prefix                        = "${var.name}-cloudwatch-agent"
  vpc_id                             = var.prometheus_vpc_id
  ecs_cluster_arn                    = aws_ecs_cluster.cluster.arn
  task_definition_arn                = module.ecs_cloudwatch_agent_task[each.key].aws_ecs_task_definition_td_arn
  private_subnets                    = var.prometheus_private_subnet_ids
  container_name                     = "cloudwatch-agent"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  desired_count                      = 1
  lb_enabled                         = false

  security_groups = var.prometheus_security_group_ids
}

module "ecs_cloudwatch_agent_task" {
  for_each = var.prometheus_enabled ? toset(["cw"]) : toset([])

  source = "../ecs_task_definition"

  name_prefix                  = "${var.name}-cloudwatch-agent"
  container_image              = var.prometheus_image
  container_name               = "cloudwatch-agent"
  container_memory_reservation = 512
  container_memory             = 512
  container_cpu                = 256

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = var.prometheus_log_group_name
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "${var.name}-cloudwatch-agent"
    }
  }

  ecs_task_execution_role_custom_policies = [<<-EOD
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "ecs:ListTasks",
          "ecs:ListServices",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeInstances"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
  EOD
  ]
}
