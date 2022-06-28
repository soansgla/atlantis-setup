# Self-Signed TLS certificate module.

This will generate Self-Signed certificates and store them in IAM.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.59 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.59 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_server_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_server_certificate) | resource |
| [tls_cert_request.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_country_code"></a> [country\_code](#input\_country\_code) | Country Code for Certificate. | `string` | n/a | yes |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | DNS name to use for self-signed certificate | `string` | n/a | yes |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Org name for Certificate. | `string` | n/a | yes |
| <a name="input_validity_ca_hours"></a> [validity\_ca\_hours](#input\_validity\_ca\_hours) | Validity period for CA in hours | `number` | `740` | no |
| <a name="input_validity_cert_hours"></a> [validity\_cert\_hours](#input\_validity\_cert\_hours) | Validity period for Certificate in hours | `number` | `730` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_self_signed_iam"></a> [iam\_self\_signed\_iam](#output\_iam\_self\_signed\_iam) | ARN for the Self-Signed certificate on IAM |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
