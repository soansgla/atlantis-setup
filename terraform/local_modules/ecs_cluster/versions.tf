terraform {
  required_version = "~> 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.59"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 1.0.0"
    }
  }
}
