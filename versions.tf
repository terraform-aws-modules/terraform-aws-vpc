terraform {
  required_version = ">= 0.12.7, < 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.68, < 4.0"
    }
  }
}
