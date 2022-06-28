## Atlantis & Infracost Infra

Repository for atlantis and infracost server.

## Pre-requiste
- INFRACOST_API_KEY (Infracost APIKEY : https://www.infracost.io/docs/)
- ATLANTIS_GH_USER (Github USER)
- ATLANTIS_GH_TOKEN (Github APIKEY)
- ATLANTIS_REPO_ALLOWLIST (github repo eg:- github.com/<orgname>/*)

Above parameters should be passed as environment variable in ecs_task_definition : 
```text
terragrunt/prod-build/ap-southeast-1/build/atlantis_ecs_task_definition/terragrunt.hcl
```

## Installation
- Terragrunt
- Terraform
- Precommit

```bash
brew install pre-commit terraform-docs terraform terragrunt
```

## Terragrunt Directory Structure
top-level(terragrunt dir) > account > region > environment > service/component/layer

```text
terragrunt
└── prod-build
    └── ap-southeast-1
        └── build
            ├── atlantis_ecs_service
            ├── atlantis_task_definition
            ├── ecs_cluster
            ├── efs
            ├── iam_self_signed_cert
            ├── network
            ├── security_groups
            ├── service_registry            
```

## Build

- Run docker build
```bash
cd docker/atlantis

docker build -t atlantis .
```
- Push docker image to ecr repo

```bash
docker tag atlantis:latest <aws account number>.dkr.ecr.ap-southeast-2.amazonaws.com/atlantis:latest

aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <aws account number>.dkr.ecr.ap-southeast-2.amazonaws.com

docker push <aws account number>.dkr.ecr.ap-southeast-2.amazonaws.com/atlantis:latest
```
*Above operation can be performed in github actions for future improvement*

## Deploy
- Terragrunt Apply
```code
cd terrgrunt/prod-build/ap-southeast-1/build

terragrunt run-all apply
```