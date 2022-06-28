locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  region_alias = local.region_vars.locals.region_alias
  env          = local.environment_vars.locals.environment_tags.environment
  org          = local.account_vars.locals.common_tags.org

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terraform/local_modules//self_signed_cert"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  country_code = "AU"
  dns_name     = "elb.amazonaws.com"
  org_name     = "AWS"
  validity_cert_hours = 8766 # 1year
  validity_ca_hours = 8766 # 1year
}
