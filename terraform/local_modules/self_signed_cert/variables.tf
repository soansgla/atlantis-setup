variable "dns_name" {
  description = "DNS name to use for self-signed certificate"
  type        = string
}

variable "validity_ca_hours" {
  description = "Validity period for CA in hours"
  type        = number
  default     = 740
}

variable "validity_cert_hours" {
  description = "Validity period for Certificate in hours"
  type        = number
  default     = 730
}

variable "country_code" {
  description = "Country Code for Certificate."
  type        = string
  validation {
    condition     = length(var.country_code) == 2
    error_message = "The country code must be 2 characters."
  }
}
variable "org_name" {
  description = "Org name for Certificate."
  type        = string
}
