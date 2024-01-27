terraform {
  required_version = ">= 1.0"

  backend "s3" {
    dynamodb_table = "terraform-locks"
    encrypt        = true
    region         = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20"
    }
  }

}
