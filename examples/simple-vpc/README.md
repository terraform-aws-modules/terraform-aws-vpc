Simple VPC
==========

Configuration in this directory creates set of VPC resources which may be sufficient for development environment.

There is a public and private subnet created per availability zone in addition to single NAT Gateway shared between all 3 availability zones.

Usage
=====

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
