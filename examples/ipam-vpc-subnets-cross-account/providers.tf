################################################################################
# Provider Configuration for Cross-Account Access
################################################################################

# Provider for networking account (where IPAM resources are created)
provider "aws" {
  alias  = "networking"
  region = var.region

  # Option 1: Use AWS profile (for local development)
  # Uncomment the line below and configure ~/.aws/credentials with [networking] profile
  # profile = "networking"

  # Option 2: Use assume role (for CI/CD or cross-account access)
  # Uncomment the block below and ensure trust relationship is configured
  # assume_role {
  #   role_arn     = "arn:aws:iam::${var.networking_account_id}:role/TerraformNetworkingRole"
  #   session_name = "terraform-networking-session"
  # }
}

# Provider for application account (where VPC and subnets are created)
provider "aws" {
  alias  = "application"
  region = var.region

  # Option 1: Use AWS profile (for local development)
  # Uncomment the line below and configure ~/.aws/credentials with [application] profile
  # profile = "application"

  # Option 2: Use assume role (for CI/CD or cross-account access)
  # Uncomment the block below and ensure trust relationship is configured
  # assume_role {
  #   role_arn     = "arn:aws:iam::${var.application_account_id}:role/TerraformApplicationRole"
  #   session_name = "terraform-application-session"
  # }
}
