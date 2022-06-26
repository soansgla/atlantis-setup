locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment_tags.environment
  project_name = local.account_vars.locals.common_tags.project
  service_name = "atlantis"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform/local_modules//ecs_service"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ecs_cluster" {
  config_path = "../ecs_cluster"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    aws_ecs_cluster_cluster_arn = "mock-cluster-arn"
  }
}

dependency "ecs_task_definition" {
  config_path = "../atlantis_ecs_task_definition"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    aws_ecs_task_definition_td_arn = "mock-td-arn"
    container_name                 = "mock-container-name"
  }
}

dependency "network" {
  config_path = "../network"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id              = "vpc-12345-mock"
    private_subnets_ids = ["subnet-1-mock", "subnet-2-mock", "subnet-3-mock"]
  }
}

dependency "security_groups" {
  config_path = "../security_groups"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    security_groups = {
      ecs-services = {
        id = "sg-000000000000"
      }
    }
  }
}

dependency "service_registry" {
  config_path = "../service_registry"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    arn = "arn:service-registry:mock"
    id  = "ns-mock"
  }
}

dependency "iam_self_signed_cert" {
  config_path  = "../iam_self_signed_cert"
  skip_outputs = lookup(local.environment_vars.locals, "skip_outputs", false)

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "state", "destroy"]
  mock_outputs = {
    iam_self_signed_iam = "arn:aws:iam::123456789012:server-certificate/cert"
  }
}


# Variables specific to service.
inputs = {
  name_prefix                    = "atlantis-cluster1"
  vpc_id                         = dependency.network.outputs.vpc_id
  ecs_cluster_arn                = dependency.ecs_cluster.outputs.aws_ecs_cluster_cluster_arn
  task_definition_arn            = dependency.ecs_task_definition.outputs.aws_ecs_task_definition_td_arn
  public_subnets                 = dependency.network.outputs.public_subnets_ids
  container_name                 = local.service_name
  assign_public_ip               = true
  force_new_deployment           = true
  ignore_task_definition_changes = true
  lb_enabled                     = true
  lb_internal                    = false
  lb_enable_deletion_protection  = false
  security_groups                = [dependency.security_groups.outputs.security_groups.ecs-services.id]
  service_registry_namespace_id  = dependency.service_registry.outputs.id

  # When deploying, ensure that the existing instance is stopped before new instances start
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  lb_http_ports           = {
    proxy = {
      type              = "forward"
      listener_port     = 80
      target_group_port = 4141
    }
  }
}
