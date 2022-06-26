variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
  validation {
    condition     = length(var.name) < 255
    error_message = "The name of the ECS Cluster must be less than 255 characters."
  }
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy."
  type = map(object({
    capacity_provider = string
    weight            = number
  }))
  default = {
    fargate = {
      capacity_provider = "FARGATE"
      weight            = 0
    },
    fargate_spot = {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  }
}

variable "container_insights" {
  description = "Controls if ECS Cluster has container insights enabled"
  type        = bool
  default     = true
}

variable "prometheus_enabled" {
  description = "Controls if a cloudwatch agent is deployed to scrape Prometheus endpoints for tasks running within the cluster"
  type        = bool
  default     = false
}

variable "prometheus_image" {
  description = "Docker image to use for the cloudwatch prometheus agent task definition"
  type        = string
  default     = ""
}

variable "prometheus_vpc_id" {
  description = "VPC ID used for the cloudwatch prometheus agent service"
  type        = string
  default     = null
}

variable "prometheus_private_subnet_ids" {
  description = "The private subnet IDs associated with the prometheus cloudwatch agent task"
  type        = list(string)
  default     = []
}

variable "prometheus_security_group_ids" {
  description = "A list of security group IDs to attach to the cloudwatch prometheus agent service"
  type        = list(string)
  default     = []
}

variable "prometheus_log_group_name" {
  description = "If Prometheus is enabled, log-group name"
  type        = string
  default     = null

  validation {
    condition     = var.prometheus_log_group_name != null ? can(regex("^(/[a-zA-Z0-9-]*){4,}$", var.prometheus_log_group_name)) : true
    error_message = "The awslogs-group must have next pattern:\nawslogs-group: \"/vertical/project_name/env/service_name[/custom]\"."
  }
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

variable "asg_name" {
  description = "an ASG name that will be deleted when cluster destroy"
  type        = string
  default     = null
}
