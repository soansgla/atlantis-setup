# Network Module

This Terraform module will provide:

- VPC
- Private Subnets
- Public Subnets
- Route Tables
- NAT GW (single or per AZ)
- Internet GW

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.59 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.59 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.internet_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route.foreign_transit_gateway_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_internet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_transit_gateway_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private_subnets_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_subnets_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_internet_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_internet_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to be used by subnets | `list(any)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for resources on AWS | `string` | n/a | yes |
| <a name="input_network_acl_private_egress"></a> [network\_acl\_private\_egress](#input\_network\_acl\_private\_egress) | Network ACL Private Egress Rules | <pre>map(object({<br>    action     = string<br>    from_port  = number<br>    protocol   = string<br>    rule_no    = number<br>    to_port    = number<br>    cidr_block = string<br>  }))</pre> | <pre>{<br>  "default": {<br>    "action": "Allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_network_acl_private_ingress"></a> [network\_acl\_private\_ingress](#input\_network\_acl\_private\_ingress) | Network ACL Private Ingress Rules | <pre>map(object({<br>    action     = string<br>    from_port  = number<br>    protocol   = string<br>    rule_no    = number<br>    to_port    = number<br>    cidr_block = string<br>  }))</pre> | <pre>{<br>  "default": {<br>    "action": "Allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_network_acl_public_egress"></a> [network\_acl\_public\_egress](#input\_network\_acl\_public\_egress) | Network ACL Public Egress Rules | <pre>map(object({<br>    action     = string<br>    from_port  = number<br>    protocol   = string<br>    rule_no    = number<br>    to_port    = number<br>    cidr_block = string<br>  }))</pre> | <pre>{<br>  "default": {<br>    "action": "Allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_network_acl_public_ingress"></a> [network\_acl\_public\_ingress](#input\_network\_acl\_public\_ingress) | Network ACL Public Ingress Rules | <pre>map(object({<br>    action     = string<br>    from_port  = number<br>    protocol   = string<br>    rule_no    = number<br>    to_port    = number<br>    cidr_block = string<br>  }))</pre> | <pre>{<br>  "default": {<br>    "action": "Allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>}</pre> | no |
| <a name="input_private_subnets_cidrs_per_availability_zone"></a> [private\_subnets\_cidrs\_per\_availability\_zone](#input\_private\_subnets\_cidrs\_per\_availability\_zone) | List of CIDRs to use on each availability zone for private subnets | `list(any)` | n/a | yes |
| <a name="input_public_subnets_cidrs_per_availability_zone"></a> [public\_subnets\_cidrs\_per\_availability\_zone](#input\_public\_subnets\_cidrs\_per\_availability\_zone) | List of CIDRs to use on each availability zone for public subnets | `list(any)` | n/a | yes |
| <a name="input_single_nat"></a> [single\_nat](#input\_single\_nat) | enable single NAT Gateway | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to use for resources that support them. | `map(any)` | `{}` | no |
| <a name="input_transit_gateway_foreign_rtb_id"></a> [transit\_gateway\_foreign\_rtb\_id](#input\_transit\_gateway\_foreign\_rtb\_id) | Existing Route Table Ids from other VPCs to add route into VPC CIDR via Transit Gateway | `list(string)` | `[]` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | Existing Transit Gateway Id to be attached to the VPC | `string` | `""` | no |
| <a name="input_transit_gateway_private_route_destination_cidr"></a> [transit\_gateway\_private\_route\_destination\_cidr](#input\_transit\_gateway\_private\_route\_destination\_cidr) | CIDR destination on Private Route table Route via Transit Gateway | `string` | `"10.0.0.0/8"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | AWS VPC CIDR Block | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of availability zones used by subnets |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | Default Security Group ID for the VPC |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the generated Internet Gateway |
| <a name="output_nat_gw_ids"></a> [nat\_gw\_ids](#output\_nat\_gw\_ids) | List with the IDs of the NAT Gateways created on public subnets to provide internet to private subnets |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | Route Table IDs for private VPC |
| <a name="output_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#output\_private\_subnet\_cidr\_blocks) | Subnet CIDR blocks for the private subnets |
| <a name="output_private_subnets_ids"></a> [private\_subnets\_ids](#output\_private\_subnets\_ids) | List with the Private Subnets IDs |
| <a name="output_private_subnets_route_table_id"></a> [private\_subnets\_route\_table\_id](#output\_private\_subnets\_route\_table\_id) | ID of the Route Table used on Private networks |
| <a name="output_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#output\_public\_subnet\_cidr\_blocks) | CIDR blocks for the public subnets |
| <a name="output_public_subnets_ids"></a> [public\_subnets\_ids](#output\_public\_subnets\_ids) | List with the Public Subnets IDs |
| <a name="output_public_subnets_route_table_id"></a> [public\_subnets\_route\_table\_id](#output\_public\_subnets\_route\_table\_id) | ID of the Route Tables used on Public networks |
| <a name="output_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#output\_transit\_gateway\_attachment\_id) | Transit Gateway Attachment ID for the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
