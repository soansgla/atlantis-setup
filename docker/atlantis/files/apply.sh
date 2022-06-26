#!/bin/bash

set -eou pipefail

# # shellcheck disable=SC1091
# AWS_ACCOUNT_ID=$1 . /home/atlantis/assume_role.sh

# TERRAGRUNT_TFPATH="terraform${ATLANTIS_TERRAFORM_VERSION}"
# export TERRAGRUNT_TFPATH

# # Apply Terragrunt - Not from plan, because it will use mock outputs. @todo
terraform init -no-color
terraform apply -auto-approve -no-color  -lock=false
