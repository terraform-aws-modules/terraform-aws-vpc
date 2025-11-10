# EC2 Instance Connect Endpoint

Configuration in this directory creates a **VPC** with **EC2 Instance Connect Endpoints (EICE)** deployed in private subnets.
This allows secure SSH or RDP access to instances **without using a bastion host** or assigning public IPs.

## Features

This example demonstrates:

- Deployment of a VPC with public and private subnets across multiple Availability Zones
- Creation of a **NAT Gateway** for outbound internet access
- Deployment of **EC2 Instance Connect Endpoints** in private subnets
- Creation of a security group allowing SSH access
- Demonstration of the `preserve_client_ip` and tagging features for EICE resources

---

## Usage

To run this example, execute:

```bash
terraform init
terraform plan
terraform apply
```

⚠️ Note:
This example may create resources that incur costs (such as VPCs, NAT Gateways, and EC2 endpoints).
Run terraform destroy when you no longer need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.allow_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_connect_endpoints"></a> [instance\_connect\_endpoints](#output\_instance\_connect\_endpoints) | Map of EC2 Instance Connect Endpoints created |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->

##Example Output

Example output after deployment:

```bash
instance_connect_endpoints = {
  "0" = {
    "id"        = "eice-0c123456789abcd"
    "arn"       = "arn:aws:ec2:us-east-1:123456789012:ec2-instance-connect-endpoint/eice-0c123456789abcd"
    "subnet_id" = "subnet-0123456789abcdef"
    "sg_ids"    = ["sg-0123456789abcdef"]
  }
}
```
