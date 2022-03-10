terraform {
  required_version = ">= 0.12.21"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.10"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2"
    }
  }
}
