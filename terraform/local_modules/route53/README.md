# Route53 Zones Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.60 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.additional_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route53_zone_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_vpcs"></a> [additional\_vpcs](#input\_additional\_vpcs) | List of additional VPCs (VPC Id and Region) to be associated to the Private Route53 Zone. | <pre>list(object({<br>    vpc_id = string<br>    region = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_alias"></a> [alias](#input\_alias) | An alias block. Conflicts with ttl & records. Alias record documented below. | <pre>object({<br>    names                   = list(string)<br>    zone_ids                = list(string)<br>    evaluate_target_healths = list(bool)<br>  })</pre> | <pre>{<br>  "evaluate_target_healths": [],<br>  "names": [],<br>  "zone_ids": []<br>}</pre> | no |
| <a name="input_allow_overwrites"></a> [allow\_overwrites](#input\_allow\_overwrites) | Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. false by default. This configuration is not recommended for most environments. | `list(bool)` | `[]` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | A comment for the hosted zone. Defaults to 'Managed by Terraform'. | `string` | `"Managed by Terraform"` | no |
| <a name="input_delegation_set_id"></a> [delegation\_set\_id](#input\_delegation\_set\_id) | The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones. | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | This is the name of the resource. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create Route53 vpc association, must be true for Private Route53 zone. | `bool` | `false` | no |
| <a name="input_failover_routing_policy"></a> [failover\_routing\_policy](#input\_failover\_routing\_policy) | A block indicating the routing behavior when associated health check fails. Conflicts with any other routing policy. | <pre>object({<br>    type = string<br>  })</pre> | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to destroy all records (possibly managed outside of Terraform) in the zone when destroying the zone. | `bool` | `true` | no |
| <a name="input_geolocation_routing_policy"></a> [geolocation\_routing\_policy](#input\_geolocation\_routing\_policy) | A block indicating a routing policy based on the geolocation of the requestor. Conflicts with any other routing policy. | <pre>object({<br>    continent   = optional(string)<br>    country     = optional(string)<br>    subdivision = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_health_check_ids"></a> [health\_check\_ids](#input\_health\_check\_ids) | The health check the record should be associated with. | `list(string)` | `[]` | no |
| <a name="input_latency_routing_policy"></a> [latency\_routing\_policy](#input\_latency\_routing\_policy) | A block indicating a routing policy based on the latency between the requestor and an AWS region. Conflicts with any other routing policy. | <pre>object({<br>    region = string<br>  })</pre> | `null` | no |
| <a name="input_multivalue_answer_routing_policies"></a> [multivalue\_answer\_routing\_policies](#input\_multivalue\_answer\_routing\_policies) | Set to true to indicate a multivalue answer routing policy. Conflicts with any other routing policy. | `list(bool)` | `[]` | no |
| <a name="input_names"></a> [names](#input\_names) | The name of the record. | `list(string)` | `[]` | no |
| <a name="input_private_enabled"></a> [private\_enabled](#input\_private\_enabled) | Whether to create private Route53 zone. | `bool` | `false` | no |
| <a name="input_public_enabled"></a> [public\_enabled](#input\_public\_enabled) | Whether to create public Route53 zone. | `bool` | `false` | no |
| <a name="input_record_enabled"></a> [record\_enabled](#input\_record\_enabled) | Whether to create Route53 record set. | `bool` | `false` | no |
| <a name="input_secondary_vpc_id"></a> [secondary\_vpc\_id](#input\_secondary\_vpc\_id) | The VPC to associate with the private hosted zone. | `string` | `""` | no |
| <a name="input_set_identifiers"></a> [set\_identifiers](#input\_set\_identifiers) | Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, or weighted routing policies documented below. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be included with the zone created. | `map(string)` | `{}` | no |
| <a name="input_ttls"></a> [ttls](#input\_ttls) | (Required for non-alias records) The TTL of the record. | `list(string)` | `[]` | no |
| <a name="input_types"></a> [types](#input\_types) | The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. | `list(string)` | `[]` | no |
| <a name="input_values"></a> [values](#input\_values) | (Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add "" inside the Terraform configuration string (e.g. "first255characters""morecharacters"). | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for Route53 Private Zone (compulsory for Private Zones). | `string` | `""` | no |
| <a name="input_weighted_routing_policy"></a> [weighted\_routing\_policy](#input\_weighted\_routing\_policy) | A block indicating a weighted routing policy. Conflicts with any other routing policy. | <pre>object({<br>    weight = number<br>  })</pre> | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Zone ID. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Hosted Zone ARN. This can be referenced by zone records. |
| <a name="output_name"></a> [name](#output\_name) | The hosted zone name. |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | A list of name servers in associated (or default) delegation set. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The Hosted Zone ID. This can be referenced by zone records. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
