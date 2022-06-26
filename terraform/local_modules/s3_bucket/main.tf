resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_143:Not company policy
  #checkov:skip=CKV_AWS_144:This feature needs to be written.
  #checkov:skip=CKV_AWS_52:This is not company policy and not suitable for a module.
  #checkov:skip=CKV_AWS_18:Logging is configurable.
  #checkov:skip=CKV_AWS_21:Versioning is configurable.
  #checkov:skip=CKV_AWS_145:We are already encrypting at-rest using AES256 by default.
  #checkov:skip=CKV2_AWS_6:We want to allow public access.
  #checkov:skip=CKV_AWS_19:We are already encrypting at-rest using AES256 by default.
  #checkov:skip=CKV2_AWS_40:We are already encrypting at-rest using AES256 by default.
  #checkov:skip=CKV2_AWS_37:We don't need to enable versioning by default.
  bucket        = var.bucket
  acl           = var.acl
  tags          = merge(var.tags, { "Name" = var.bucket })
  force_destroy = var.force_destroy

  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = length(keys(var.server_side_encryption_configuration)) == 0 ? [] : [var.server_side_encryption_configuration]

    content {

      dynamic "rule" {
        for_each = length(keys(lookup(server_side_encryption_configuration.value, "rule", {}))) == 0 ? [] : [lookup(server_side_encryption_configuration.value, "rule", {})]

        content {
          bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)

          dynamic "apply_server_side_encryption_by_default" {
            for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
            lookup(rule.value, "apply_server_side_encryption_by_default", {})]

            content {
              sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_configuration != null ? [var.object_lock_configuration] : []

    content {
      object_lock_enabled = lookup(object_lock_configuration.value, "object_lock_enabled", null)

      dynamic "rule" {
        for_each = length(var.object_lock_configuration.rule) != 0 ? [var.object_lock_configuration.rule] : []

        content {
          default_retention {
            mode  = rule.value.default_retention.mode
            days  = rule.value.default_retention.days
            years = rule.value.default_retention.years
          }
        }
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      id      = lifecycle_rule.key
      prefix  = lifecycle_rule.value.prefix
      enabled = lifecycle_rule.value.enabled != null ? lifecycle_rule.value.enabled : true

      dynamic "expiration" {
        for_each = lifecycle_rule.value.current_version_expiration != null ? [lifecycle_rule.value.current_version_expiration] : []

        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }
      dynamic "transition" {
        for_each = defaults(lifecycle_rule.value.current_version_transition, {})

        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration != null ? [lifecycle_rule.value.noncurrent_version_expiration] : []

        content {
          days = noncurrent_version_expiration.value.days
        }
      }
      dynamic "noncurrent_version_transition" {
        for_each = defaults(lifecycle_rule.value.noncurrent_version_transition, {})

        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = length(var.replication_rules) > 0 ? [1] : []

    content {
      role = module.s3_roles[0].iam_roles.replication-role.arn

      dynamic "rules" {
        for_each = var.replication_rules

        content {
          id       = rules.key
          prefix   = rules.value.filter == null ? rules.value.prefix : null
          priority = rules.value.account_id == null ? rules.value.priority : null
          status   = rules.value.status != null ? rules.value.status : "Enabled"

          destination {
            bucket             = format("arn:aws:s3:::%s", rules.value.destination_bucket_name)
            storage_class      = rules.value.storage_class
            replica_kms_key_id = rules.value.replica_kms_key_id
            account_id         = rules.value.account_id

            dynamic "access_control_translation" {
              for_each = rules.value.account_id != null ? [1] : []

              content {
                owner = "Destination"
              }
            }

            dynamic "replication_time" {
              for_each = (rules.value.enable_rtc == true && rules.value.filter != null) ? [1] : []

              content {
                status  = "Enabled"
                minutes = 15
              }
            }

            dynamic "metrics" {
              for_each = (rules.value.enable_rtc == true && rules.value.filter != null) ? [1] : []

              content {
                status  = "Enabled"
                minutes = 15
              }
            }
          }

          dynamic "filter" {
            for_each = rules.value.filter != null ? [rules.value.filter] : []

            content {
              prefix = filter.value.prefix
              tags   = filter.value.tags
            }
          }

          dynamic "source_selection_criteria" {
            for_each = rules.value.replica_kms_key_id != null ? [rules.value.replica_kms_key_id] : []

            content {
              sse_kms_encrypted_objects {
                enabled = true
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = var.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_policy ? var.policy : ""
  ])
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.this]
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = var.intelligent_tiering_configurations

  bucket = aws_s3_bucket.this.id
  name   = each.key
  status = each.value.enabled ? "Enabled" : "Disabled"

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "tiering" {
    for_each = each.value.archive_access_tier_days >= 90 ? [1] : []

    content {
      access_tier = "ARCHIVE_ACCESS"
      days        = each.value.archive_access_tier_days
    }
  }

  dynamic "tiering" {
    for_each = each.value.deep_archive_access_tier_days >= 180 ? [1] : []

    content {
      access_tier = "DEEP_ARCHIVE_ACCESS"
      days        = each.value.deep_archive_access_tier_days
    }
  }
}
