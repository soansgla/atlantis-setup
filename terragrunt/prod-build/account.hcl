# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "prod-build"
  aws_account_id = "XXXX"
  aws_profile    = "prod-build"

  common_tags = {
    vertical = "devops"
    project  = "atlantis"
    org      = "AWS"
  }
}
