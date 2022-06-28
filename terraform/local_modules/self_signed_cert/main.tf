terraform {
  required_version = "~> 1.2.0"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.59"
    }
  }
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "ca"
    organization = var.org_name
    country      = var.country_code
  }

  validity_period_hours = var.validity_ca_hours

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "default" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = var.dns_name
    organization = var.org_name
    country      = var.country_code
  }
}

resource "tls_locally_signed_cert" "default" {
  cert_request_pem = tls_cert_request.default.cert_request_pem

  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.validity_cert_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_iam_server_certificate" "cert" {
  # TODO add switch
  name_prefix      = var.dns_name
  certificate_body = tls_locally_signed_cert.default.cert_pem
  private_key      = tls_private_key.default.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}
