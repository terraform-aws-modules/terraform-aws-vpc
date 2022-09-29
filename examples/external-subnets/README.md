# Simple VPC with External Subnets and Network ACLs

Configuration in this directory creates set of VPC resources along with network ACLs for external subnets.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

