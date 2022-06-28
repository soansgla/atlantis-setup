locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env          = local.environment_vars.locals.environment_tags.environment
  project_name = local.account_vars.locals.common_tags.project
  region       = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform/local_modules//security_groups"
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
    vpc_id                     = "vpc-12345-mock"
    private_subnet_cidr_blocks = ["10.45.0.0/26", "10.46.0.0/26"]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.project_name}-${local.env}"
  vpc_id      = dependency.network.outputs.vpc_id

  security_groups = {
    ecs-services = {
      description = "Atlantis ECS Services Security Group"
      ingress = {
        allow-atlantis = {
          from_port   = 4141
          to_port     = 4141
          protocol    = "tcp"
          cidr_blocks = dependency.network.outputs.public_subnet_cidr_blocks
          description = "Atlantis port"
        }
      }
      egress = {
        allow-source = {
          from_port   = 0
          to_port     = 443
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow tasks to send request to github/gitlab/bitbucket"
        },
        allow-efs = {
          from_port   = 0
          to_port     = 2049
          protocol    = "-1"
          cidr_blocks = dependency.network.outputs.private_subnet_cidr_blocks
          description = "Allow all tasks efs private subnets"
        }
      }
    }

    efs = {
      description = "Atlantis EFS Services Security Group"
      ingress = {
        allow-atlantis = {
          from_port   = 2049
          to_port     = 2049
          protocol    = "tcp"
          cidr_blocks = dependency.network.outputs.private_subnet_cidr_blocks
          description = "EFS inbound port"
        }
      }
    }
  }
}
