variable "description" {
  type        = string
  description = "Description of the Service Registry"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name of the Service Registry"
}

variable "tags" {
  description = "Tags to be attached to applicable resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the Service Registry"
}

variable "additional_vpcs" {
  description = "List of additional VPCs (VPC Id and Region) to be associated to the Private Route53 Zone created by Service Registry."
  type = list(object({
    vpc_id = string
    region = optional(string)
  }))
  default = []
}
