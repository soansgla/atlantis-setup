locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env             = local.environment_vars.locals.environment_tags.environment
  vertical        = local.account_vars.locals.common_tags.vertical
  project_name    = local.account_vars.locals.common_tags.project
  region          = local.region_vars.locals.aws_region
  aws_account_id  = local.account_vars.locals.aws_account_id
  service_name    = "atlantis"
  service_version = "latest"

  # Atlantis variables
  atlantis_repo_config    = "/home/atlantis/repos.yaml"
  atlantis_write_creds    = "1"
  atlantis_log_level      = "debug"
  atlantis_automerge      = true
  atlantis_port           = 4141
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform/local_modules//ecs_task_definition"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "efs" {
  config_path = "../efs"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    efs_id = "fs-123"
    efs_access_points = {
      "efs-access" = {
        "id" = "fsap-00000000000000000"
      }
    }
  }
}

inputs = {
  name_prefix                  = "${local.project_name}-${local.env}-${local.service_name}"
  container_image              = "${local.aws_account_id}.dkr.ecr.ap-southeast-2.amazonaws.com/${local.service_name}:${local.service_version}"
  container_name               = local.service_name
  container_memory_reservation = 8192
  container_memory             = 8192
  container_cpu                = 4096

  map_environment = {
    ENVIRONMENT : "${local.env}"
    ATLANTIS_DEFAULT_TF_VERSION : "1.1.4"
  }

  port_mappings = [
    {
      containerPort = "4141"
      hostPort      = "4141"
      protocol      = "tcp"
    }
  ]

  mount_points = [
    {
      containerPath = "/atlantis"
      sourceVolume  = "${local.project_name}-${local.env}-${local.service_name}-volume"
    }
  ]

  volume = [
    {
      name = "${local.project_name}-${local.env}-${local.service_name}-volume"
      efs_volume_configuration = {
        file_system_id = dependency.efs.outputs.efs_id
        root_directory = "/atlantis"
        authorization_config = {
          access_point_id = dependency.efs.outputs.efs_access_points.efs-access.id
        }
      }
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/${local.vertical}/${local.project_name}/${local.env}/${local.service_name}"
      awslogs-region        = local.region
      awslogs-stream-prefix = local.env
    }
  }

  enable_ecr_access = true

 ecs_task_execution_role_custom_policies = [<<-EOD
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["*"],
        "Resource": ["*"]
      }
    ]
  }
  EOD
  ]
}
