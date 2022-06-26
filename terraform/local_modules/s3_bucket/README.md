# S3 Bucket Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.65 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_roles"></a> [s3\_roles](#module\_s3\_roles) | ../iam_roles | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_iam_policy_document.s3_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | The canned ACL to apply. Defaults to 'private'. Conflicts with `grant` | `string` | `"private"` | no |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the bucket. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. | `bool` | `false` | no |
| <a name="input_intelligent_tiering_configurations"></a> [intelligent\_tiering\_configurations](#input\_intelligent\_tiering\_configurations) | Map containingIntelligent-Tiering Archive configurations. | <pre>map(object({<br>    enabled = bool<br>    filter = optional(object({<br>      prefix = optional(string)<br>      tags   = optional(map(string))<br>    }))<br>    archive_access_tier_days      = number<br>    deep_archive_access_tier_days = number<br>  }))</pre> | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Map containing access bucket lifecycle rules configuration. | <pre>map(object({<br>    abort_incomplete_multipart_upload_days = optional(number)<br>    prefix                                 = optional(string)<br>    enabled                                = optional(bool)<br>    current_version_expiration = optional(object({<br>      date                         = optional(string)<br>      days                         = optional(number)<br>      expired_object_delete_marker = optional(string)<br>    }))<br>    current_version_transition = optional(map(object({<br>      date          = optional(string)<br>      days          = optional(number)<br>      storage_class = string<br>    })))<br>    noncurrent_version_expiration = optional(object({<br>      days = number<br>    }))<br>    noncurrent_version_transition = optional(map(object({<br>      days          = number<br>      storage_class = string<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Map containing access bucket logging configuration. | `map(string)` | `{}` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Controls object lock and its retention configuration | <pre>object({<br>    object_lock_enabled = string<br>    rule = object({<br>      default_retention = object({<br>        days  = optional(number)<br>        mode  = string<br>        years = optional(number)<br>      })<br>    })<br>  })</pre> | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Bucket policy JSON document. | `string` | `null` | no |
| <a name="input_replication_rules"></a> [replication\_rules](#input\_replication\_rules) | Map containing access bucket lifecycle rules configuration. | <pre>map(object({<br>    prefix                  = optional(string)<br>    priority                = optional(number)<br>    status                  = optional(string)<br>    destination_bucket_name = string<br>    storage_class           = optional(string)<br>    replica_kms_key_id      = optional(string)<br>    account_id              = optional(string)<br>    filter = optional(object({<br>      prefix = optional(string)<br>      tags   = optional(map(string))<br>    }))<br>    enable_rtc = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | Map containing server-side encryption configuration. Pass `{}` to disable. | `any` | <pre>{<br>  "rule": {<br>    "apply_server_side_encryption_by_default": {<br>      "sse_algorithm": "AES256"<br>    }<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be included with the zone created. | `map(any)` | `{}` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Map containing versioning configuration. | `map(string)` | <pre>{<br>  "enabled": true<br>}</pre> | no |
| <a name="input_website"></a> [website](#input\_website) | Map containing static web-site hosting configuration. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. |
| <a name="output_s3_bucket_bucket_domain_name"></a> [s3\_bucket\_bucket\_domain\_name](#output\_s3\_bucket\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_s3_bucket_bucket_regional_domain_name"></a> [s3\_bucket\_bucket\_regional\_domain\_name](#output\_s3\_bucket\_bucket\_regional\_domain\_name) | The bucket domain name including the region name. |
| <a name="output_s3_bucket_hosted_zone_id"></a> [s3\_bucket\_hosted\_zone\_id](#output\_s3\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this bucket resides in. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
