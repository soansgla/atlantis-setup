data "aws_region" "current" {}

# AWS ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy = file("${path.module}/files/iam/ecs_task_execution_iam_role.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_service_ec2_role" {
  count      = var.enable_ecr_access == true ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "ecs_task_execution_role_custom_policy" {
  for_each    = toset(var.ecs_task_execution_role_custom_policies)
  name        = "${var.name_prefix}-ecs-task-execution-role-custom-policy"
  description = "A custom policy for ${var.name_prefix}-ecs-task-execution-role IAM Role"
  policy      = each.value
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_custom_policy" {
  for_each   = aws_iam_policy.ecs_task_execution_role_custom_policy
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value.arn
}

resource "aws_iam_policy" "ssm" {
  count       = var.enable_ecs_exec == true ? 1 : 0
  name        = "${var.name_prefix}-ecs_task_execution_role_ssm"
  description = "All tasks to connect to ssm for ECS Exec"
  policy      = file("${path.module}/files/iam/ecs_task_execution_role_ssm.json")
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ecs_exec == true ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = one(aws_iam_policy.ssm[*].arn)
}

locals {
  log_configuration = var.log_configuration == null ? null : {
    logDriver = var.log_configuration.logDriver
    options = {
      awslogs-group         = one(aws_cloudwatch_log_group.this.*.name)
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = var.log_configuration.options.awslogs-stream-prefix
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:We don't need to add the extra complexity of using a CMK as it would mean a fairly major refactor for FunctionBeat/ECS services.
  count = var.log_configuration != null ? 1 : 0

  name              = var.log_configuration.options.awslogs-group
  retention_in_days = var.cloudwatch_logs_retention_in_days
}

# ECS Task Definition
# Container Definition
module "container_definition" {
  source = "./container_definition"

  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_definition         = var.container_definition
  port_mappings                = var.port_mappings
  healthcheck                  = var.healthcheck
  container_cpu                = var.container_cpu
  essential                    = var.essential
  entrypoint                   = var.entrypoint
  command                      = var.command
  working_directory            = var.working_directory
  environment                  = var.environment
  extra_hosts                  = var.extra_hosts
  map_environment              = var.map_environment
  environment_files            = var.environment_files
  secrets                      = var.secrets
  readonly_root_filesystem     = var.readonly_root_filesystem
  linux_parameters             = var.linux_parameters
  log_configuration            = local.log_configuration
  firelens_configuration       = var.firelens_configuration
  mount_points                 = var.mount_points
  dns_servers                  = var.dns_servers
  dns_search_domains           = var.dns_search_domains
  ulimits                      = var.ulimits
  repository_credentials       = var.repository_credentials
  volumes_from                 = var.volumes_from
  links                        = var.links
  user                         = var.user
  container_depends_on         = var.container_depends_on
  docker_labels                = var.docker_labels
  start_timeout                = var.start_timeout
  stop_timeout                 = var.stop_timeout
  privileged                   = var.privileged
  system_controls              = var.system_controls
  hostname                     = var.hostname
  disable_networking           = var.disable_networking
  interactive                  = var.interactive
  pseudo_terminal              = var.pseudo_terminal
  docker_security_options      = var.docker_security_options
}

# Task Definition
resource "aws_ecs_task_definition" "default" {
  family                   = "${var.name_prefix}-td"
  container_definitions    = "[${module.container_definition.json_map_encoded}]"
  task_role_arn            = var.task_role_arn == null ? aws_iam_role.ecs_task_execution_role.arn : var.task_role_arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc" # When using the Fargate launch type, the awsvpc network mode is required.
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = var.requires_compatibilities

  dynamic "volume" {
    for_each = var.volume
    content {
      name = volume.value.name

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", null) != null ? [volume.value.docker_volume_configuration] : []

        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", false)
          scope         = lookup(docker_volume_configuration.value, "scope", "shared")
          driver        = lookup(docker_volume_configuration.value, "driver", "rexray/ebs")
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", { volumetype = "gp3", size = "5" })
        }
      }
      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", null) != null ? [volume.value.efs_volume_configuration] : []

        content {
          file_system_id     = efs_volume_configuration.value.file_system_id
          transit_encryption = "ENABLED"
          authorization_config {
            access_point_id = efs_volume_configuration.value.authorization_config.access_point_id
          }
        }
      }
    }
  }

  tags = merge(var.tags, { "Name" = "${var.name_prefix}-td" })
}

data "aws_ecs_task_definition" "default" {
  task_definition = "${var.name_prefix}-td"
  depends_on      = [aws_ecs_task_definition.default] # ensures at least one task def exists
}
