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

# APPLICATION LOAD BALANCER
variable "internal" {
  description = "If true, the LB will be internal."
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
  default     = []
}

variable "drop_invalid_header_fields" {
  description = <<-EOD
  Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false).
  Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens.
  EOD
  type        = bool
  default     = true
}

variable "private_subnets" {
  description = "A list of private subnet IDs to attach to the LB if it is INTERNAL."
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnet IDs to attach to the LB if it is NOT internal."
  type        = list(string)
  default     = []
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default: 60."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = <<-EOD
  If true, deletion of the load balancer will be disabled via the AWS API.
  This will prevent Terraform from deleting the load balancer.
  EOD
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "If true, cross-zone load balancing of the load balancer will be enabled."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in the load balancer."
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
  type        = string
  default     = "ipv4"
}

# ACCESS CONTROL TO APPLICATION LOAD BALANCER
variable "http_ports" {
  description = <<-EOD
  Map containing objects to define listeners behaviour based on type field. If type field is `forward`, include listener_port and the target_group_port.
  For `redirect` type, include listener port, host, path, port, protocol, query and status_code. For `fixed-response`,
  include listener_port, content_type, message_body and status_code.
  EOD
  type        = map(any)
  default = {
    default_http = {
      type              = "forward"
      listener_port     = 80
      target_group_port = 80
    }
  }
}

variable "https_ports" {
  description = <<-EOD
  Map containing objects to define listeners behaviour based on type field.
  If type field is `forward`, include listener_port and the target_group_port.
  For `redirect` type, include listener port, host, path, port, protocol, query and status_code.
  For `fixed-response`, include listener_port, content_type, message_body and status_code.
  EOD
  type        = map(any)
  default = {
    default_http = {
      type              = "forward"
      listener_port     = 443
      target_group_port = 443
    }
  }
}

variable "http_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_prefix_list_ids" {
  description = "List of prefix list IDs blocks to allowed to access the Load Balancer through HTTP"
  type        = list(string)
  default     = []
}

variable "https_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_prefix_list_ids" {
  description = "List of prefix list IDs blocks to allowed to access the Load Balancer through HTTPS"
  type        = list(string)
  default     = []
}

# AWS LOAD BALANCER - Target Groups
variable "deregistration_delay" {
  description = <<-EOD
  The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused.
  The range is 0-3600 seconds. The default value is 300 seconds.
  EOD
  type        = number
  default     = 300
}

variable "slow_start" {
  description = <<-EOD
  The amount time for targets to warm up before the load balancer sends them a full share of requests.
  The range is 30-900 seconds or 0 to disable.
  EOD
  type        = number
  default     = 0
}

variable "load_balancing_algorithm_type" {
  description = <<-EOD
  Determines how the load balancer selects targets when routing requests.
  The value is round_robin or least_outstanding_requests.
  EOD
  type        = string
  default     = "round_robin"
}

variable "stickiness" {
  description = <<-EOD
  A Stickiness block. Provide three fields. type, the type of sticky sessions.
  The only current possible value is lb_cookie. cookie_duration, the time period, in seconds, during which requests
  from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale.
  The range is 1 second to 1 week (604800 seconds).
  EOD
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

variable "target_group_health_check_enabled" {
  description = "Indicates whether health checks are enabled."
  type        = bool
  default     = true
}

variable "target_group_health_check_interval" {
  description = <<-EOD
  The approximate amount of time, in seconds, between health checks of an individual target.
  Minimum value 5 seconds, Maximum value 300 seconds.
  EOD
  type        = number
  default     = 30
}

variable "target_group_health_check_path" {
  description = "The destination for the health check request."
  type        = string
  default     = "/"
}

variable "target_group_health_check_timeout" {
  description = <<-EOD
  The amount of time, in seconds, during which no response means a failed health check.
  The range is 2 to 120 seconds.
  EOD
  type        = number
  default     = 5
}

variable "target_group_health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
  type        = number
  default     = 3
}

variable "target_group_health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy."
  type        = number
  default     = 3
}

variable "target_group_health_check_matcher" {
  description = <<-EOD
  The HTTP codes to use when checking for a successful response from a target.
  You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\").
  EOD
  type        = string
  default     = "200"
}

variable "ssl_policy" {
  description = "The name of the SSL Policy for the listener. . Required if var.https_ports is set."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "default_certificate_arn" {
  description = "The ARN of the default SSL server certificate. Required if var.https_ports is set."
  type        = string
  default     = null
}

variable "additional_certificates_arn_for_https_listeners" {
  description = "List of SSL server certificate ARNs for HTTPS listener. Use it if you need to set additional certificates besides default_certificate_arn"
  type        = list(any)
  default     = []
}

variable "s3_force_destroy" {
  description = "Whether or not to allow force destroy of the S3 bucket for ALB logs."
  type        = bool
  default     = true
}

# Security Group - Outbound
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
