# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region       = local.region_vars.locals.aws_region

  environment_tags = {
    environment = "build"
  }

  # Network
  vpc_cidr_block = "10.69.0.0/24"
  public_subnets_cidrs_per_availability_zone = [
    "10.69.0.0/26",
    "10.69.0.64/26"
  ]
  private_subnets_cidrs_per_availability_zone = [
    "10.69.0.128/26",
    "10.69.0.192/26"
  ]
  availability_zones = [
    "${local.region}a",
    "${local.region}b"
  ]
  tf_modules_version = "v6.2.1"
}
