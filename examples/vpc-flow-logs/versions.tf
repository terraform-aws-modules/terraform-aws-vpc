terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
