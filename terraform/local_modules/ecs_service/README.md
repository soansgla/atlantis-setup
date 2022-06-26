# ECS Service Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.60 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_alb"></a> [ecs\_alb](#module\_ecs\_alb) | ../ecs_alb | n/a |
| <a name="module_ecs_nlb"></a> [ecs\_nlb](#module\_ecs\_nlb) | ../ecs_nlb | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_security_group.ecs_tasks_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_prefix_lists](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_through_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_through_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_certificates_arn_for_https_listeners"></a> [additional\_certificates\_arn\_for\_https\_listeners](#input\_additional\_certificates\_arn\_for\_https\_listeners) | List of SSL server certificate ARNs for HTTPS listener. Use it if you need to set additional certificates besides default\_certificate\_arn | `list(any)` | `[]` | no |
| <a name="input_additional_certificates_arn_for_tls_listeners"></a> [additional\_certificates\_arn\_for\_tls\_listeners](#input\_additional\_certificates\_arn\_for\_tls\_listeners) | List of SSL server certificate ARNs for TLS listener. Use it if you need to set additional certificates besides default\_certificate\_arn | `list(any)` | `[]` | no |
| <a name="input_alpn_policy"></a> [alpn\_policy](#input\_alpn\_policy) | The name of the Application-Layer Protocol Negotiation (ALPN) policy for NLB. Can be set if protocol is TLS. | `string` | `"HTTP2Preferred"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only). If true service will be associated with public subnets. Default false. | `bool` | `false` | no |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Autoscaling policies for ECS service | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>    policy = object({<br>      cpu = optional(object({<br>        disable_scale_in   = optional(bool)<br>        scale_in_cooldown  = optional(number)<br>        scale_out_cooldown = optional(number)<br>        target_value       = number<br>      }))<br>      memory = optional(object({<br>        disable_scale_in   = optional(bool)<br>        scale_in_cooldown  = optional(number)<br>        scale_out_cooldown = optional(number)<br>        target_value       = number<br>      }))<br>    })<br>  })</pre> | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the running container | `string` | n/a | yes |
| <a name="input_default_certificate_arn"></a> [default\_certificate\_arn](#input\_default\_certificate\_arn) | The ARN of the default SSL server certificate. Required if var.https\_ports and var.tls\_ports is set. | `string` | `null` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment. | `number` | `100` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running. | `number` | `1` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of an ECS cluster | `string` | n/a | yes |
| <a name="input_enable_ecs_exec"></a> [enable\_ecs\_exec](#input\_enable\_ecs\_exec) | whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `false` | no |
| <a name="input_existing_target_groups"></a> [existing\_target\_groups](#input\_existing\_target\_groups) | Existing target group(s) map to be attached to an ECS Service | <pre>map(object({<br>    arn  = string,<br>    port = number<br>  }))</pre> | `{}` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered\_placement\_strategy and placement\_constraints updates. | `bool` | `false` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers. | `number` | `0` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The launch type of the service. | `string` | `"FARGATE"` | no |
| <a name="input_lb_connection_termination"></a> [lb\_connection\_termination](#input\_lb\_connection\_termination) | Indicates whether Connection termination on deregistration are enabled on NLB. | `bool` | `false` | no |
| <a name="input_lb_deregistration_delay"></a> [lb\_deregistration\_delay](#input\_lb\_deregistration\_delay) | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds. | `number` | `300` | no |
| <a name="input_lb_drop_invalid_header_fields"></a> [lb\_drop\_invalid\_header\_fields](#input\_lb\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. | `bool` | `true` | no |
| <a name="input_lb_egress_cidr"></a> [lb\_egress\_cidr](#input\_lb\_egress\_cidr) | Set the allowed egress CIDR for ALB | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_lb_egress_from_port"></a> [lb\_egress\_from\_port](#input\_lb\_egress\_from\_port) | Set the allowed from which port for ALB | `number` | `0` | no |
| <a name="input_lb_egress_protocol"></a> [lb\_egress\_protocol](#input\_lb\_egress\_protocol) | Set the allowed egress protocol for ALB | `string` | `"-1"` | no |
| <a name="input_lb_egress_to_port"></a> [lb\_egress\_to\_port](#input\_lb\_egress\_to\_port) | Set the allowed to which port for ALB | `number` | `0` | no |
| <a name="input_lb_enable_cross_zone_load_balancing"></a> [lb\_enable\_cross\_zone\_load\_balancing](#input\_lb\_enable\_cross\_zone\_load\_balancing) | If true, cross-zone load balancing of the load balancer will be enabled. | `bool` | `false` | no |
| <a name="input_lb_enable_deletion_protection"></a> [lb\_enable\_deletion\_protection](#input\_lb\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `true` | no |
| <a name="input_lb_enable_http2"></a> [lb\_enable\_http2](#input\_lb\_enable\_http2) | Indicates whether HTTP/2 is enabled in the load balancer. | `bool` | `true` | no |
| <a name="input_lb_enabled"></a> [lb\_enabled](#input\_lb\_enabled) | If true, the LB will be created. | `bool` | `true` | no |
| <a name="input_lb_http_ingress_cidr_blocks"></a> [lb\_http\_ingress\_cidr\_blocks](#input\_lb\_http\_ingress\_cidr\_blocks) | List of CIDR blocks to allowed to access the Load Balancer through HTTP | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_lb_http_ingress_prefix_list_ids"></a> [lb\_http\_ingress\_prefix\_list\_ids](#input\_lb\_http\_ingress\_prefix\_list\_ids) | List of prefix list IDs blocks to allowed to access the Load Balancer through HTTP | `list(string)` | `[]` | no |
| <a name="input_lb_http_ports"></a> [lb\_http\_ports](#input\_lb\_http\_ports) | Map containing objects to define listeners behaviour based on type field. If type field is `forward`, include listener\_port and the target\_group\_port. For `redirect` type, include listener port, host, path, port, protocol, query and status\_code. For `fixed-response`, include listener\_port, content\_type, message\_body and status\_code | `map(any)` | <pre>{<br>  "default_http": {<br>    "listener_port": 80,<br>    "target_group_port": 80,<br>    "type": "forward"<br>  }<br>}</pre> | no |
| <a name="input_lb_https_ingress_cidr_blocks"></a> [lb\_https\_ingress\_cidr\_blocks](#input\_lb\_https\_ingress\_cidr\_blocks) | List of CIDR blocks to allowed to access the Load Balancer through HTTPS | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_lb_https_ingress_prefix_list_ids"></a> [lb\_https\_ingress\_prefix\_list\_ids](#input\_lb\_https\_ingress\_prefix\_list\_ids) | List of prefix list IDs blocks to allowed to access the Load Balancer through HTTPS | `list(string)` | `[]` | no |
| <a name="input_lb_https_ports"></a> [lb\_https\_ports](#input\_lb\_https\_ports) | Map containing objects to define listeners behaviour based on type field. If type field is `forward`, include listener\_port and the target\_group\_port. For `redirect` type, include listener port, host, path, port, protocol, query and status\_code. For `fixed-response`, include listener\_port, content\_type, message\_body and status\_code | `map(any)` | <pre>{<br>  "default_http": {<br>    "listener_port": 443,<br>    "target_group_port": 443,<br>    "type": "forward"<br>  }<br>}</pre> | no |
| <a name="input_lb_idle_timeout"></a> [lb\_idle\_timeout](#input\_lb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. Default: 60. | `number` | `60` | no |
| <a name="input_lb_internal"></a> [lb\_internal](#input\_lb\_internal) | If true, the LB will be internal. | `bool` | `true` | no |
| <a name="input_lb_ip_address_type"></a> [lb\_ip\_address\_type](#input\_lb\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. Defaults to ipv4 | `string` | `"ipv4"` | no |
| <a name="input_lb_load_balancing_algorithm_type"></a> [lb\_load\_balancing\_algorithm\_type](#input\_lb\_load\_balancing\_algorithm\_type) | Determines how the load balancer selects targets when routing requests. The value is round\_robin or least\_outstanding\_requests. The default is round\_robin. | `string` | `"round_robin"` | no |
| <a name="input_lb_preserve_client_ip"></a> [lb\_preserve\_client\_ip](#input\_lb\_preserve\_client\_ip) | Indicates whether Preserve client IP addresses are enabled on NLB. | `bool` | `false` | no |
| <a name="input_lb_proxy_protocol_v2"></a> [lb\_proxy\_protocol\_v2](#input\_lb\_proxy\_protocol\_v2) | Indicates whether Proxy protocol v2 checks are enabled on NLB. | `bool` | `false` | no |
| <a name="input_lb_security_groups"></a> [lb\_security\_groups](#input\_lb\_security\_groups) | A list of security group IDs to assign to the LB. | `list(string)` | `[]` | no |
| <a name="input_lb_slow_start"></a> [lb\_slow\_start](#input\_lb\_slow\_start) | The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds. | `number` | `0` | no |
| <a name="input_lb_stickiness"></a> [lb\_stickiness](#input\_lb\_stickiness) | A Stickiness block. Provide three fields. type, the type of sticky sessions. The only current possible value is lb\_cookie. cookie\_duration, the time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds). enabled, boolean to enable / disable stickiness. Default is true. | <pre>object({<br>    type            = string<br>    cookie_duration = string<br>    enabled         = bool<br>  })</pre> | <pre>{<br>  "cookie_duration": 86400,<br>  "enabled": true,<br>  "type": "lb_cookie"<br>}</pre> | no |
| <a name="input_lb_target_group_health_check_enabled"></a> [lb\_target\_group\_health\_check\_enabled](#input\_lb\_target\_group\_health\_check\_enabled) | Indicates whether health checks are enabled. | `bool` | `true` | no |
| <a name="input_lb_target_group_health_check_healthy_threshold"></a> [lb\_target\_group\_health\_check\_healthy\_threshold](#input\_lb\_target\_group\_health\_check\_healthy\_threshold) | The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3. | `number` | `3` | no |
| <a name="input_lb_target_group_health_check_interval"></a> [lb\_target\_group\_health\_check\_interval](#input\_lb\_target\_group\_health\_check\_interval) | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds. | `number` | `30` | no |
| <a name="input_lb_target_group_health_check_matcher"></a> [lb\_target\_group\_health\_check\_matcher](#input\_lb\_target\_group\_health\_check\_matcher) | The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, "200,202") or a range of values (for example, "200-299"). Default is 200. | `string` | `"200"` | no |
| <a name="input_lb_target_group_health_check_path"></a> [lb\_target\_group\_health\_check\_path](#input\_lb\_target\_group\_health\_check\_path) | The destination for the health check request. | `string` | `"/"` | no |
| <a name="input_lb_target_group_health_check_port"></a> [lb\_target\_group\_health\_check\_port](#input\_lb\_target\_group\_health\_check\_port) | The port number for the health check request. | `number` | `null` | no |
| <a name="input_lb_target_group_health_check_protocol"></a> [lb\_target\_group\_health\_check\_protocol](#input\_lb\_target\_group\_health\_check\_protocol) | The protocol for the health check request. | `string` | `"HTTP"` | no |
| <a name="input_lb_target_group_health_check_timeout"></a> [lb\_target\_group\_health\_check\_timeout](#input\_lb\_target\_group\_health\_check\_timeout) | The amount of time, in seconds, during which no response means a failed health check. The range is 2 to 120 seconds, and the default is 5 seconds. | `number` | `5` | no |
| <a name="input_lb_target_group_health_check_unhealthy_threshold"></a> [lb\_target\_group\_health\_check\_unhealthy\_threshold](#input\_lb\_target\_group\_health\_check\_unhealthy\_threshold) | The number of consecutive health check failures required before considering the target unhealthy. | `number` | `3` | no |
| <a name="input_lb_tcp_ports"></a> [lb\_tcp\_ports](#input\_lb\_tcp\_ports) | Map containing objects to define listeners behaviour based listener type TCP. | `map(any)` | `{}` | no |
| <a name="input_lb_tcp_udp_ports"></a> [lb\_tcp\_udp\_ports](#input\_lb\_tcp\_udp\_ports) | Map containing objects to define listeners behaviour based listener type TCP\_UDP. | `map(any)` | `{}` | no |
| <a name="input_lb_tls_ports"></a> [lb\_tls\_ports](#input\_lb\_tls\_ports) | Map containing objects to define listeners behaviour based listener type TLS. | `map(any)` | `{}` | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | If true, the LB will be created. | `string` | `"application"` | no |
| <a name="input_lb_udp_ports"></a> [lb\_udp\_ports](#input\_lb\_udp\_ports) | Map containing objects to define listeners behaviour based listener type UDP. | `map(any)` | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for resources on AWS | `string` | n/a | yes |
| <a name="input_ordered_placement_strategy"></a> [ordered\_placement\_strategy](#input\_ordered\_placement\_strategy) | Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. The maximum number of ordered\_placement\_strategy blocks is 5. This is a list of maps where each map should contain "id" and "field" | `list(any)` | `[]` | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | rules that are taken into consideration during task placement. Maximum number of placement\_constraints is 10. This is a list of maps, where each map should contain "type" and "expression" | `list(any)` | `[]` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | The platform version on which to run your service. Defaults to 1.4.0. More information about Fargate platform versions can be found in the AWS ECS User Guide. | `string` | `"1.4.0"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | The private subnets associated with the task or service. | `list(any)` | `[]` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION. Default to SERVICE | `string` | `"SERVICE"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | The public subnets associated with the task or service. | `list(any)` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. | `list(any)` | `[]` | no |
| <a name="input_service_registry_namespace_id"></a> [service\_registry\_namespace\_id](#input\_service\_registry\_namespace\_id) | ID of the Service Registry namespace if applicable. | `string` | `""` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The name of the SSL Policy for the listener. . Required if var.https\_ports and var.tls\_ports is set. | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | The full ARN of the task definition that you want to run in your service. | `string` | `null` | no |
| <a name="input_tasks_egress_cidr"></a> [tasks\_egress\_cidr](#input\_tasks\_egress\_cidr) | Set the allowed egress CIDR for tasks | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tasks_egress_prefix_list_ids"></a> [tasks\_egress\_prefix\_list\_ids](#input\_tasks\_egress\_prefix\_list\_ids) | Allow tasks to talk to prefix lists | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecs_service_service_cluster"></a> [aws\_ecs\_service\_service\_cluster](#output\_aws\_ecs\_service\_service\_cluster) | The Amazon Resource Name (ARN) of cluster which the service runs on. |
| <a name="output_aws_ecs_service_service_desired_count"></a> [aws\_ecs\_service\_service\_desired\_count](#output\_aws\_ecs\_service\_service\_desired\_count) | The number of instances of the task definition |
| <a name="output_aws_ecs_service_service_id"></a> [aws\_ecs\_service\_service\_id](#output\_aws\_ecs\_service\_service\_id) | The Amazon Resource Name (ARN) that identifies the service. |
| <a name="output_aws_ecs_service_service_name"></a> [aws\_ecs\_service\_service\_name](#output\_aws\_ecs\_service\_service\_name) | The name of the service. |
| <a name="output_aws_lb_lb_arn"></a> [aws\_lb\_lb\_arn](#output\_aws\_lb\_lb\_arn) | The ARN of the load balancer (matches id). |
| <a name="output_aws_lb_lb_arn_suffix"></a> [aws\_lb\_lb\_arn\_suffix](#output\_aws\_lb\_lb\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_aws_lb_lb_dns_name"></a> [aws\_lb\_lb\_dns\_name](#output\_aws\_lb\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_aws_lb_lb_id"></a> [aws\_lb\_lb\_id](#output\_aws\_lb\_lb\_id) | The ARN of the load balancer (matches arn). |
| <a name="output_aws_lb_lb_zone_id"></a> [aws\_lb\_lb\_zone\_id](#output\_aws\_lb\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
| <a name="output_aws_lb_nlb_arn"></a> [aws\_lb\_nlb\_arn](#output\_aws\_lb\_nlb\_arn) | The ARN of the load balancer (matches id). |
| <a name="output_aws_lb_nlb_arn_suffix"></a> [aws\_lb\_nlb\_arn\_suffix](#output\_aws\_lb\_nlb\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_aws_lb_nlb_dns_name"></a> [aws\_lb\_nlb\_dns\_name](#output\_aws\_lb\_nlb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_aws_lb_nlb_id"></a> [aws\_lb\_nlb\_id](#output\_aws\_lb\_nlb\_id) | The ARN of the load balancer (matches arn). |
| <a name="output_aws_lb_nlb_zone_id"></a> [aws\_lb\_nlb\_zone\_id](#output\_aws\_lb\_nlb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
| <a name="output_aws_security_group_lb_access_sg_arn"></a> [aws\_security\_group\_lb\_access\_sg\_arn](#output\_aws\_security\_group\_lb\_access\_sg\_arn) | The ARN of the security group for ALB |
| <a name="output_aws_security_group_lb_access_sg_description"></a> [aws\_security\_group\_lb\_access\_sg\_description](#output\_aws\_security\_group\_lb\_access\_sg\_description) | The description of the security group for ALB |
| <a name="output_aws_security_group_lb_access_sg_egress"></a> [aws\_security\_group\_lb\_access\_sg\_egress](#output\_aws\_security\_group\_lb\_access\_sg\_egress) | The egress rules of the security group for ALB. |
| <a name="output_aws_security_group_lb_access_sg_id"></a> [aws\_security\_group\_lb\_access\_sg\_id](#output\_aws\_security\_group\_lb\_access\_sg\_id) | The ID of the security group for ALB |
| <a name="output_aws_security_group_lb_access_sg_ingress"></a> [aws\_security\_group\_lb\_access\_sg\_ingress](#output\_aws\_security\_group\_lb\_access\_sg\_ingress) | The ingress rules of the security group for ALB. |
| <a name="output_aws_security_group_lb_access_sg_name"></a> [aws\_security\_group\_lb\_access\_sg\_name](#output\_aws\_security\_group\_lb\_access\_sg\_name) | The name of the security group for ALB |
| <a name="output_aws_security_group_lb_access_sg_owner_id"></a> [aws\_security\_group\_lb\_access\_sg\_owner\_id](#output\_aws\_security\_group\_lb\_access\_sg\_owner\_id) | The owner ID. |
| <a name="output_aws_security_group_lb_access_sg_vpc_id"></a> [aws\_security\_group\_lb\_access\_sg\_vpc\_id](#output\_aws\_security\_group\_lb\_access\_sg\_vpc\_id) | The VPC ID. |
| <a name="output_ecs_tasks_sg_arn"></a> [ecs\_tasks\_sg\_arn](#output\_ecs\_tasks\_sg\_arn) | ${var.name\_prefix} ECS Tasks Security Group - The ARN of the security group |
| <a name="output_ecs_tasks_sg_description"></a> [ecs\_tasks\_sg\_description](#output\_ecs\_tasks\_sg\_description) | ${var.name\_prefix} ECS Tasks Security Group - The description of the security group |
| <a name="output_ecs_tasks_sg_id"></a> [ecs\_tasks\_sg\_id](#output\_ecs\_tasks\_sg\_id) | ${var.name\_prefix} ECS Tasks Security Group - The ID of the security group |
| <a name="output_ecs_tasks_sg_name"></a> [ecs\_tasks\_sg\_name](#output\_ecs\_tasks\_sg\_name) | ${var.name\_prefix} ECS Tasks Security Group - The name of the security group |
| <a name="output_lb_http_listeners_arns"></a> [lb\_http\_listeners\_arns](#output\_lb\_http\_listeners\_arns) | List of HTTP Listeners ARNs for ALB |
| <a name="output_lb_http_listeners_ids"></a> [lb\_http\_listeners\_ids](#output\_lb\_http\_listeners\_ids) | List of HTTP Listeners IDs for ALB |
| <a name="output_lb_http_tgs_arns"></a> [lb\_http\_tgs\_arns](#output\_lb\_http\_tgs\_arns) | List of HTTP Target Groups ARNs for ALB |
| <a name="output_lb_http_tgs_ids"></a> [lb\_http\_tgs\_ids](#output\_lb\_http\_tgs\_ids) | List of HTTP Target Groups IDs for ALB |
| <a name="output_lb_http_tgs_names"></a> [lb\_http\_tgs\_names](#output\_lb\_http\_tgs\_names) | List of HTTP Target Groups Names for ALB |
| <a name="output_lb_https_listeners_arns"></a> [lb\_https\_listeners\_arns](#output\_lb\_https\_listeners\_arns) | List of HTTPS Listeners ARNs for ALB |
| <a name="output_lb_https_listeners_ids"></a> [lb\_https\_listeners\_ids](#output\_lb\_https\_listeners\_ids) | List of HTTPS Listeners IDs for ALB |
| <a name="output_lb_https_tgs_arns"></a> [lb\_https\_tgs\_arns](#output\_lb\_https\_tgs\_arns) | List of HTTPS Target Groups ARNs for ALB |
| <a name="output_lb_https_tgs_ids"></a> [lb\_https\_tgs\_ids](#output\_lb\_https\_tgs\_ids) | List of HTTPS Target Groups IDs for ALB |
| <a name="output_lb_https_tgs_names"></a> [lb\_https\_tgs\_names](#output\_lb\_https\_tgs\_names) | List of HTTPS Target Groups Names for ALB |
| <a name="output_lb_tcp_listeners_arns"></a> [lb\_tcp\_listeners\_arns](#output\_lb\_tcp\_listeners\_arns) | List of TCP Listeners ARNs for NLB |
| <a name="output_lb_tcp_listeners_ids"></a> [lb\_tcp\_listeners\_ids](#output\_lb\_tcp\_listeners\_ids) | List of TCP Listeners IDs for NLB |
| <a name="output_lb_tcp_tgs_arns"></a> [lb\_tcp\_tgs\_arns](#output\_lb\_tcp\_tgs\_arns) | List of TCP Target Groups ARNs for NLB |
| <a name="output_lb_tcp_tgs_ids"></a> [lb\_tcp\_tgs\_ids](#output\_lb\_tcp\_tgs\_ids) | List of TCP Target Groups IDs for NLB |
| <a name="output_lb_tcp_tgs_names"></a> [lb\_tcp\_tgs\_names](#output\_lb\_tcp\_tgs\_names) | List of TCP Target Groups Names for NLB |
| <a name="output_lb_tcp_udp_listeners_arns"></a> [lb\_tcp\_udp\_listeners\_arns](#output\_lb\_tcp\_udp\_listeners\_arns) | List of TCP\_UDP Listeners ARNs for NLB |
| <a name="output_lb_tcp_udp_listeners_ids"></a> [lb\_tcp\_udp\_listeners\_ids](#output\_lb\_tcp\_udp\_listeners\_ids) | List of TCP\_UDP Listeners IDs for NLB |
| <a name="output_lb_tcp_udp_tgs_arns"></a> [lb\_tcp\_udp\_tgs\_arns](#output\_lb\_tcp\_udp\_tgs\_arns) | List of TCP\_UDP Target Groups ARNs for NLB |
| <a name="output_lb_tcp_udp_tgs_ids"></a> [lb\_tcp\_udp\_tgs\_ids](#output\_lb\_tcp\_udp\_tgs\_ids) | List of TCP\_UDP Target Groups IDs for NLB |
| <a name="output_lb_tcp_udp_tgs_names"></a> [lb\_tcp\_udp\_tgs\_names](#output\_lb\_tcp\_udp\_tgs\_names) | List of TCP\_UDP Target Groups Names for NLB |
| <a name="output_lb_tls_listeners_arns"></a> [lb\_tls\_listeners\_arns](#output\_lb\_tls\_listeners\_arns) | List of TLS Listeners ARNs for NLB |
| <a name="output_lb_tls_listeners_ids"></a> [lb\_tls\_listeners\_ids](#output\_lb\_tls\_listeners\_ids) | List of TLS Listeners IDs for NLB |
| <a name="output_lb_tls_tgs_arns"></a> [lb\_tls\_tgs\_arns](#output\_lb\_tls\_tgs\_arns) | List of TLS Target Groups ARNs for NLB |
| <a name="output_lb_tls_tgs_ids"></a> [lb\_tls\_tgs\_ids](#output\_lb\_tls\_tgs\_ids) | List of TLS Target Groups IDs for NLB |
| <a name="output_lb_tls_tgs_names"></a> [lb\_tls\_tgs\_names](#output\_lb\_tls\_tgs\_names) | List of TLS Target Groups Names for NLB |
| <a name="output_lb_udp_listeners_arns"></a> [lb\_udp\_listeners\_arns](#output\_lb\_udp\_listeners\_arns) | List of UDP Listeners ARNs for NLB |
| <a name="output_lb_udp_listeners_ids"></a> [lb\_udp\_listeners\_ids](#output\_lb\_udp\_listeners\_ids) | List of UDP Listeners IDs for NLB |
| <a name="output_lb_udp_tgs_arns"></a> [lb\_udp\_tgs\_arns](#output\_lb\_udp\_tgs\_arns) | List of UDP Target Groups ARNs for NLB |
| <a name="output_lb_udp_tgs_ids"></a> [lb\_udp\_tgs\_ids](#output\_lb\_udp\_tgs\_ids) | List of UDP Target Groups IDs for NLB |
| <a name="output_lb_udp_tgs_names"></a> [lb\_udp\_tgs\_names](#output\_lb\_udp\_tgs\_names) | List of UDP Target Groups Names for NLB |
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | Name prefix for ECS service |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
