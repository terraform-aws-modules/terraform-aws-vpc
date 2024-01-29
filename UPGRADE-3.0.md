# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the `examples` directory:

- [Complete-VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc)

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

Previously, VPC endpoints were configured as standalone resources with their own set of variables and attributes. Now, this functionality is provided via a module which loops over a map of maps using `for_each` to generate the desired VPC endpoints. Therefore, to maintain the existing set of functionality while upgrading, you will need to perform the following changes:

1. Move the endpoint resource from the main module to the sub-module. The example state move below is valid for all endpoints you might have configured (reference [`complete-vpc`](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc) example for reference), where `ssmmessages` should be updated for and state move performed for each endpoint configured:

```
terraform state mv 'module.vpc.aws_vpc_endpoint.ssm[0]' 'module.vpc_endpoints.aws_vpc_endpoint.this["ssm"]'
terraform state mv 'module.vpc.aws_vpc_endpoint.ssmmessages[0]' 'module.vpc_endpoints.aws_vpc_endpoint.this["ssmmessages"]'
terraform state mv 'module.vpc.aws_vpc_endpoint.ec2[0]' 'module.vpc_endpoints.aws_vpc_endpoint.this["ec2"]'
...
```

2. Remove the gateway endpoint route table association separate resources. The route table associations are now managed in the VPC endpoint resource itself via the map of maps provided to the VPC endpoint sub-module. Perform the necessary removals for each route table association and for S3 and/or DynamoDB depending on your configuration:

```
terraform state rm 'module.vpc.aws_vpc_endpoint_route_table_association.intra_dynamodb[0]'
terraform state rm 'module.vpc.aws_vpc_endpoint_route_table_association.private_dynamodb[0]'
terraform state rm 'module.vpc.aws_vpc_endpoint_route_table_association.public_dynamodb[0]'
...
```

### Variable and output changes

1. Removed variables:

   - `enable_*_endpoint`
   - `*_endpoint_type`
   - `*_endpoint_security_group_ids`
   - `*_endpoint_subnet_ids`
   - `*_endpoint_private_dns_enabled`
   - `*_endpoint_policy`

2. Renamed variables:

See the [VPC endpoint sub-module](modules/vpc-endpoints) for the more information on the variables to utilize for VPC endpoints

3. Removed outputs:

   - `vpc_endpoint_*`

4. Renamed outputs:

VPC endpoint outputs are now provided via the VPC endpoint sub-module and can be accessed via lookups. See [`complete-vpc`](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc) for further examples of how to access VPC endpoint attributes from outputs
