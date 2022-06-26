variable "name_prefix" {
  type        = string
  description = "Name prefix for all parameters."
}

variable "iam_roles" {
  type = map(object({
    assume_role_policy   = string
    instance_profile     = optional(bool)
    path                 = optional(string)
    max_session_duration = optional(number)
    description          = optional(string)
    policies             = optional(map(string))
    policies_arn = optional(map(object({
      policy_arn = string
    })))
  }))
  description = "Map of objects for creation of iam roles"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "The map of tags to assign to all resources"
}
