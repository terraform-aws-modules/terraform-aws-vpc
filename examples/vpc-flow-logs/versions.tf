terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.70"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2"
    }
  }
}
