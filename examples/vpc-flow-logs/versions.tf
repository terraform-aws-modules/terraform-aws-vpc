terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2"
    }
  }
}
