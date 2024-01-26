terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "terraform-aws-vpc-terraform-state-prod-597947213367-eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    key            = "prod/eu-west-1/prod/terraform-aws-vpc/terraform.tfstate"
    region         = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20"
    }
  }
}
