#!/bin/bash

# This will run a `terragrunt run-all plan` against the project folder (usually the environment's region) while also
# outputting nice logging. Terragrunt by default won't buffer stdout from Terraform, therefore the logs can be
# intermingled. This will output the plan for each module separately and combine the logs at the end.

set -eou pipefail


# TERRAFORM
terraform init -no-color
terraform plan -no-color -lock=false -compact-warnings -refresh -input=false 

# INFRACOST:
infracost breakdown --path . --format json --no-color --out-file infracost-base.json
infracost comment github --path infracost-base.json --no-color --repo $BASE_REPO_OWNER/$BASE_REPO_NAME --pull-request $PULL_NUM --github-token $ATLANTIS_GH_TOKEN --behavior update
MONTHLY_COST=`jq -r '.totalMonthlyCost' infracost-base.json`
export MONTHLY_COST
echo $MONTHLY_COST
if (( $(echo "$MONTHLY_COST > 10" | bc -l) ));
then
    echo "Monthly cost is above the allocated limit. Please obtain manager's approval"
else
    echo "Monthly cost is within limits"
fi
