locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment_tags.environment
  project_name = local.account_vars.locals.common_tags.project
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform/local_modules//efs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id              = "vpc-09e98a3e5cf4e57e7"
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
      efs = {
        id = "sg-000000000000"
      }
    }
  }
}

# Variables specific to service.
inputs = {
  name_prefix     = "${local.project_name}-${local.env}"
  environment     = "${local.env}"
  vpc_id          = dependency.network.outputs.vpc_id
  security_groups = [dependency.security_groups.outputs.security_groups.efs.id]
  subnet_ids      = dependency.network.outputs.private_subnets_ids
  access_points = {
    efs-access = {
      access_path = "/atlantis"
    }
  }
}
