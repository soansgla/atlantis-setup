# Misc
variable "name_prefix" {
  type        = string
  description = "Name prefix for resources on AWS"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# AWS Networking
variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

# AWS ECS SERVICE
variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of an ECS cluster"
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = 100
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running. "
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  type        = bool
  default     = false
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  type        = number
  default     = 0
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. The maximum number of ordered_placement_strategy blocks is 5. This is a list of maps where each map should contain \"id\" and \"field\""
  type        = list(any)
  default     = []
}

variable "placement_constraints" {
  type        = list(any)
  description = "rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10. This is a list of maps, where each map should contain \"type\" and \"expression\""
  default     = []
}

variable "platform_version" {
  description = "The platform version on which to run your service. Defaults to 1.4.0. More information about Fargate platform versions can be found in the AWS ECS User Guide."
  type        = string
  default     = "1.4.0"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION. Default to SERVICE"
  type        = string
  default     = "SERVICE"
}

variable "task_definition_arn" {
  description = "The full ARN of the task definition that you want to run in your service."
  type        = string
  default     = null
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered_placement_strategy and placement_constraints updates."
  type        = bool
  default     = false
}

variable "enable_ecs_exec" {
  description = "whether to enable Amazon ECS Exec for the tasks within the service."
  type        = bool
  default     = false
}

# AWS ECS SERVICE network_configuration
variable "public_subnets" {
  description = "The public subnets associated with the task or service."
  type        = list(any)
  default     = []
}

variable "private_subnets" {
  description = "The private subnets associated with the task or service."
  type        = list(any)
  default     = []
}

variable "security_groups" {
  description = "The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used."
  type        = list(any)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only). If true service will be associated with public subnets. Default false. "
  type        = bool
  default     = false
}

# AWS ECS SERVICE load_balancer BLOCK
variable "container_name" {
  type        = string
  description = "Name of the running container"
}

# AWS LOAD BALANCER
variable "lb_enabled" {
  description = "If true, the LB will be created."
  type        = bool
  default     = true
}

variable "lb_type" {
  description = "If true, the LB will be created."
  type        = string
  default     = "application"
}

variable "lb_internal" {
  description = "If true, the LB will be internal."
  type        = bool
  default     = true
}

variable "lb_security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
  default     = []
}

variable "lb_drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens."
  type        = bool
  default     = true
}

variable "lb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default: 60."
  type        = number
  default     = 60
}

variable "lb_enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = true
}

variable "lb_enable_cross_zone_load_balancing" {
  description = "If true, cross-zone load balancing of the load balancer will be enabled. "
  type        = bool
  default     = false
}

variable "lb_enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in the load balancer. "
  type        = bool
  default     = true
}

variable "lb_ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. Defaults to ipv4"
  type        = string
  default     = "ipv4"
}

# ACCESS CONTROL TO NETWORK LOAD BALANCER

variable "lb_tcp_ports" {
  description = "Map containing objects to define listeners behaviour based listener type TCP."
  type        = map(any)
  default     = {}
}

variable "lb_udp_ports" {
  description = "Map containing objects to define listeners behaviour based listener type UDP."
  type        = map(any)
  default     = {}
}

variable "lb_tcp_udp_ports" {
  description = "Map containing objects to define listeners behaviour based listener type TCP_UDP."
  type        = map(any)
  default     = {}
}

variable "lb_tls_ports" {
  description = "Map containing objects to define listeners behaviour based listener type TLS."
  type        = map(any)
  default     = {}
}

# ACCESS CONTROL TO APPLICATION LOAD BALANCER

variable "lb_http_ports" {
  description = "Map containing objects to define listeners behaviour based on type field. If type field is `forward`, include listener_port and the target_group_port. For `redirect` type, include listener port, host, path, port, protocol, query and status_code. For `fixed-response`, include listener_port, content_type, message_body and status_code"
  type        = map(any)
  default = {
    default_http = {
      type              = "forward"
      listener_port     = 80
      target_group_port = 80
    }
  }
}

variable "lb_http_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "lb_http_ingress_prefix_list_ids" {
  description = "List of prefix list IDs blocks to allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = []
}

variable "lb_https_ports" {
  description = "Map containing objects to define listeners behaviour based on type field. If type field is `forward`, include listener_port and the target_group_port. For `redirect` type, include listener port, host, path, port, protocol, query and status_code. For `fixed-response`, include listener_port, content_type, message_body and status_code"
  type        = map(any)
  default = {
    default_http = {
      type              = "forward"
      listener_port     = 443
      target_group_port = 443
    }
  }
}

variable "lb_https_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "lb_https_ingress_prefix_list_ids" {
  description = "List of prefix list IDs blocks to allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = []
}

# AWS LOAD BALANCER - Target Groups
variable "lb_connection_termination" {
  description = "Indicates whether Connection termination on deregistration are enabled on NLB."
  type        = bool
  default     = false
}

variable "lb_deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  type        = number
  default     = 300
}

variable "lb_proxy_protocol_v2" {
  description = "Indicates whether Proxy protocol v2 checks are enabled on NLB."
  type        = bool
  default     = false
}

variable "lb_preserve_client_ip" {
  description = "Indicates whether Preserve client IP addresses are enabled on NLB."
  type        = bool
  default     = false
}

variable "lb_slow_start" {
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds."
  type        = number
  default     = 0
}

variable "lb_load_balancing_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests. The value is round_robin or least_outstanding_requests. The default is round_robin."
  type        = string
  default     = "round_robin"
}

variable "lb_stickiness" {
  description = "A Stickiness block. Provide three fields. type, the type of sticky sessions. The only current possible value is lb_cookie. cookie_duration, the time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds). enabled, boolean to enable / disable stickiness. Default is true."
  type = object({
    type            = string
    cookie_duration = string
    enabled         = bool
  })
  default = {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
}

variable "lb_target_group_health_check_enabled" {
  description = "Indicates whether health checks are enabled. "
  type        = bool
  default     = true
}

variable "lb_target_group_health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. Default 30 seconds."
  type        = number
  default     = 30
}

variable "lb_target_group_health_check_path" {
  description = "The destination for the health check request."
  type        = string
  default     = "/"
}

variable "lb_target_group_health_check_protocol" {
  description = "The protocol for the health check request."
  type        = string
  default     = "HTTP"
}

variable "lb_target_group_health_check_port" {
  description = "The port number for the health check request."
  type        = number
  default     = null
}

variable "lb_target_group_health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check. The range is 2 to 120 seconds, and the default is 5 seconds."
  type        = number
  default     = 5
}

variable "lb_target_group_health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  type        = number
  default     = 3
}

variable "lb_target_group_health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy. "
  type        = number
  default     = 3
}

variable "lb_target_group_health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\"). Default is 200."
  type        = string
  default     = "200"
}

# AWS LOAD BALANCER - Target Groups
variable "ssl_policy" {
  description = "The name of the SSL Policy for the listener. . Required if var.https_ports and var.tls_ports is set."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alpn_policy" {
  description = "The name of the Application-Layer Protocol Negotiation (ALPN) policy for NLB. Can be set if protocol is TLS."
  type        = string
  default     = "HTTP2Preferred"
}

variable "default_certificate_arn" {
  description = "The ARN of the default SSL server certificate. Required if var.https_ports and var.tls_ports is set."
  type        = string
  default     = null
}

variable "additional_certificates_arn_for_https_listeners" {
  description = "List of SSL server certificate ARNs for HTTPS listener. Use it if you need to set additional certificates besides default_certificate_arn"
  type        = list(any)
  default     = []
}

variable "additional_certificates_arn_for_tls_listeners" {
  description = "List of SSL server certificate ARNs for TLS listener. Use it if you need to set additional certificates besides default_certificate_arn"
  type        = list(any)
  default     = []
}

# AWS ECS existing Target Group to attach
variable "existing_target_groups" {
  description = "Existing target group(s) map to be attached to an ECS Service"
  type = map(object({
    arn  = string,
    port = number
  }))
  default = {}
}

# Service Discovery
variable "service_registry_namespace_id" {
  description = "ID of the Service Registry namespace if applicable."
  type        = string
  default     = ""
}

variable "launch_type" {
  description = "The launch type of the service."
  type        = string
  default     = "FARGATE"
}

# Security Group - Egress - Tasks
variable "tasks_egress_cidr" {
  description = "Set the allowed egress CIDR for tasks"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "tasks_egress_prefix_list_ids" {
  description = "Allow tasks to talk to prefix lists"
  type        = list(string)
  default     = []
}

# Security Group - Egress - ALB
variable "lb_egress_cidr" {
  description = "Set the allowed egress CIDR for ALB"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "lb_egress_from_port" {
  description = "Set the allowed from which port for ALB"
  type        = number
  default     = 0
}

variable "lb_egress_to_port" {
  description = "Set the allowed to which port for ALB"
  type        = number
  default     = 0
}

variable "lb_egress_protocol" {
  description = "Set the allowed egress protocol for ALB"
  type        = string
  default     = "-1"
}

variable "autoscaling" {
  type = object({
    min_capacity = number
    max_capacity = number
    policy = object({
      cpu = optional(object({
        disable_scale_in   = optional(bool)
        scale_in_cooldown  = optional(number)
        scale_out_cooldown = optional(number)
        target_value       = number
      }))
      memory = optional(object({
        disable_scale_in   = optional(bool)
        scale_in_cooldown  = optional(number)
        scale_out_cooldown = optional(number)
        target_value       = number
      }))
    })
  })
  default     = null
  description = "Autoscaling policies for ECS service"
}
