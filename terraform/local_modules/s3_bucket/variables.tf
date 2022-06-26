variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration. Pass `{}` to disable."
  type        = any
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

variable "intelligent_tiering_configurations" {
  description = "Map containingIntelligent-Tiering Archive configurations."
  type = map(object({
    enabled = bool
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    archive_access_tier_days      = number
    deep_archive_access_tier_days = number
  }))
  default = {}
}

variable "lifecycle_rules" {
  description = "Map containing access bucket lifecycle rules configuration."
  type = map(object({
    abort_incomplete_multipart_upload_days = optional(number)
    prefix                                 = optional(string)
    enabled                                = optional(bool)
    current_version_expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(string)
    }))
    current_version_transition = optional(map(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    })))
    noncurrent_version_expiration = optional(object({
      days = number
    }))
    noncurrent_version_transition = optional(map(object({
      days          = number
      storage_class = string
    })))
  }))
  default = {}
}

variable "replication_rules" {
  description = "Map containing access bucket lifecycle rules configuration."
  type = map(object({
    prefix                  = optional(string)
    priority                = optional(number)
    status                  = optional(string)
    destination_bucket_name = string
    storage_class           = optional(string)
    replica_kms_key_id      = optional(string)
    account_id              = optional(string)
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    enable_rtc = optional(bool)
  }))
  default = {}
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default = {
    enabled = true
  }
}

variable "force_destroy" {
  description = "Indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Tags to be included with the zone created."
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'. Conflicts with `grant`"
  type        = string
  default     = "private"
}

variable "bucket" {
  description = "The name of the bucket."
  type        = string
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Bucket policy JSON document."
  type        = string
  default     = null
}

variable "website" {
  description = "Map containing static web-site hosting configuration."
  type        = map(string)
  default     = {}
}

variable "object_lock_configuration" {
  description = "Controls object lock and its retention configuration"
  type = object({
    object_lock_enabled = string
    rule = object({
      default_retention = object({
        days  = optional(number)
        mode  = string
        years = optional(number)
      })
    })
  })
  default = null
}
