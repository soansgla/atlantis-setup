# ECS Module

## Pre-requirements

AWS CLI:
If you want to use an ECS cluster with the EC2 capacity provider.
AWS CLI is used for scale-in ASG before deletion of the cluster.
You may skip this if you want to do it manually.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.59 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.59 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_cloudwatch_agent_service"></a> [ecs\_cloudwatch\_agent\_service](#module\_ecs\_cloudwatch\_agent\_service) | ../ecs_service | n/a |
| <a name="module_ecs_cloudwatch_agent_task"></a> [ecs\_cloudwatch\_agent\_task](#module\_ecs\_cloudwatch\_agent\_task) | ../ecs_task_definition | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [null_resource.scale_down_asg](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | an ASG name that will be deleted when cluster destroy | `string` | `null` | no |
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | <pre>[<br>  "FARGATE",<br>  "FARGATE_SPOT"<br>]</pre> | no |
| <a name="input_container_insights"></a> [container\_insights](#input\_container\_insights) | Controls if ECS Cluster has container insights enabled | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | Default capacity provider strategy. | <pre>map(object({<br>    capacity_provider = string<br>    weight            = number<br>  }))</pre> | <pre>{<br>  "fargate": {<br>    "capacity_provider": "FARGATE",<br>    "weight": 0<br>  },<br>  "fargate_spot": {<br>    "capacity_provider": "FARGATE_SPOT",<br>    "weight": 100<br>  }<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier, also the name of the ECS cluster | `string` | n/a | yes |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Controls if a cloudwatch agent is deployed to scrape Prometheus endpoints for tasks running within the cluster | `bool` | `false` | no |
| <a name="input_prometheus_image"></a> [prometheus\_image](#input\_prometheus\_image) | Docker image to use for the cloudwatch prometheus agent task definition | `string` | `""` | no |
| <a name="input_prometheus_log_group_name"></a> [prometheus\_log\_group\_name](#input\_prometheus\_log\_group\_name) | If Prometheus is enabled, log-group name | `string` | `null` | no |
| <a name="input_prometheus_private_subnet_ids"></a> [prometheus\_private\_subnet\_ids](#input\_prometheus\_private\_subnet\_ids) | The private subnet IDs associated with the prometheus cloudwatch agent task | `list(string)` | `[]` | no |
| <a name="input_prometheus_security_group_ids"></a> [prometheus\_security\_group\_ids](#input\_prometheus\_security\_group\_ids) | A list of security group IDs to attach to the cloudwatch prometheus agent service | `list(string)` | `[]` | no |
| <a name="input_prometheus_vpc_id"></a> [prometheus\_vpc\_id](#input\_prometheus\_vpc\_id) | VPC ID used for the cloudwatch prometheus agent service | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecs_cluster_cluster_arn"></a> [aws\_ecs\_cluster\_cluster\_arn](#output\_aws\_ecs\_cluster\_cluster\_arn) | The Amazon Resource Name (ARN) that identifies the cluster |
| <a name="output_aws_ecs_cluster_cluster_id"></a> [aws\_ecs\_cluster\_cluster\_id](#output\_aws\_ecs\_cluster\_cluster\_id) | The Amazon ID that identifies the cluster |
| <a name="output_aws_ecs_cluster_cluster_name"></a> [aws\_ecs\_cluster\_cluster\_name](#output\_aws\_ecs\_cluster\_cluster\_name) | The name of the cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
