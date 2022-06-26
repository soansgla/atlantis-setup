# Route53 Zone and Records
variable "alias" {
  description = "An alias block. Conflicts with ttl & records. Alias record documented below."
  type = object({
    names                   = list(string)
    zone_ids                = list(string)
    evaluate_target_healths = list(bool)
  })
  default = {
    names                   = []
    zone_ids                = []
    evaluate_target_healths = []
  }
}

variable "additional_vpcs" {
  description = "List of additional VPCs (VPC Id and Region) to be associated to the Private Route53 Zone."
  type = list(object({
    vpc_id = string
    region = optional(string)
  }))
  default = []
}

variable "allow_overwrites" {
  description = "Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. false by default. This configuration is not recommended for most environments."
  type        = list(bool)
  default     = []
}

variable "comment" {
  description = "A comment for the hosted zone. Defaults to 'Managed by Terraform'."
  type        = string
  default     = "Managed by Terraform"
}

variable "delegation_set_id" {
  description = "The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "This is the name of the resource."
  type        = string
}

variable "enabled" {
  description = "Whether to create Route53 vpc association, must be true for Private Route53 zone."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone."
  type        = bool
  default     = true
}

variable "health_check_ids" {
  description = "The health check the record should be associated with."
  type        = list(string)
  default     = []
}

variable "multivalue_answer_routing_policies" {
  description = "Set to true to indicate a multivalue answer routing policy. Conflicts with any other routing policy."
  type        = list(bool)
  default     = []
}

variable "names" {
  description = "The name of the record."
  type        = list(string)
  default     = []
}

variable "private_enabled" {
  description = "Whether to create private Route53 zone."
  type        = bool
  default     = false
}

variable "public_enabled" {
  type        = bool
  default     = false
  description = "Whether to create public Route53 zone."
}

variable "record_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "secondary_vpc_id" {
  description = "The VPC to associate with the private hosted zone."
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be included with the zone created."
}

variable "ttls" {
  type        = list(string)
  default     = []
  description = "(Required for non-alias records) The TTL of the record."
}

variable "types" {
  type        = list(string)
  default     = []
  description = "The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
}

variable "values" {
  description = "(Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string (e.g. \"first255characters\"\"morecharacters\")."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for Route53 Private Zone (compulsory for Private Zones)."
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Zone ID."
  type        = string
  default     = ""
}

# Routing Policy variables
variable "set_identifiers" {
  description = "Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, or weighted routing policies documented below."
  type        = list(string)
  default     = []
}

variable "failover_routing_policy" {
  description = "A block indicating the routing behavior when associated health check fails. Conflicts with any other routing policy."
  type = object({
    type = string
  })
  default = null
}

variable "geolocation_routing_policy" {
  description = "A block indicating a routing policy based on the geolocation of the requestor. Conflicts with any other routing policy."
  type = object({
    continent   = optional(string)
    country     = optional(string)
    subdivision = optional(string)
  })
  default = null
}

variable "latency_routing_policy" {
  description = "A block indicating a routing policy based on the latency between the requestor and an AWS region. Conflicts with any other routing policy."
  type = object({
    region = string
  })
  default = null
}

variable "weighted_routing_policy" {
  description = "A block indicating a weighted routing policy. Conflicts with any other routing policy."
  type = object({
    weight = number
  })
  default = null
}
