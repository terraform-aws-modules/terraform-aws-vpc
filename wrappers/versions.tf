terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
  }

  provider_meta "aws" {
    user_agent = [
      "github.com/terraform-aws-modules"
    ]
  }
}
