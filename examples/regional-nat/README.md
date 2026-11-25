# Regional NAT Gateway Example

This example demonstrates how to use the **Regional NAT Gateway** feature in the Terraform AWS VPC module. Regional NAT Gateways provide a highly available NAT solution that automatically scales across multiple Availability Zones within your VPC.

## Key Features of Regional NAT Gateway

- **Single NAT Gateway**: One NAT Gateway serves all Availability Zones in your VPC
- **Automatic High Availability**: Automatically expands and contracts across AZs based on workload distribution
- **No Public Subnets Required**: Regional NAT Gateways operate without requiring public subnets (though we include them here for demonstration)
- **Simplified Management**: Single NAT Gateway ID for consistent route entries across all subnets
- **Increased Capacity**: Supports up to 32 Elastic IP addresses per AZ (compared to 8 for zonal NAT Gateways)

## Architecture

This example creates:

- **VPC**: Single VPC with CIDR block `10.0.0.0/16`
- **Private Subnets**: 3 private subnets (one per Availability Zone)
- **Public Subnets**: 3 public subnets (one per Availability Zone)
- **Database Subnets**: 3 database subnets (one per Availability Zone)
- **Regional NAT Gateway**: Single NAT Gateway that automatically scales across all AZs
- **Internet Gateway**: For outbound internet connectivity

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, NAT Gateway, etc.). Run `terraform destroy` when you don't need these resources.

## Configuration

The key configuration for Regional NAT Gateway is:

```hcl
enable_nat_gateway = true
nat_gateway_connectivity_type = {
  availability_mode = "regional" # "regional" or "zonal" (default)
  eip_allocation    = "auto"     # "auto" (default) or "manual"
}
```

With `eip_allocation = "auto"` (used in this example) the module creates no Elastic IPs: AWS allocates and manages them as the NAT Gateway expands into an Availability Zone. With `eip_allocation = "manual"` the module creates one Elastic IP per Availability Zone in `azs`, or uses the ones you pass via `external_nat_ip_ids` when `reuse_nat_ips = true`.

## Comparison: Regional vs Zonal NAT Gateway

### Regional NAT Gateway (This Example)
- **Count**: 1 NAT Gateway for entire VPC
- **Route Tables**: One route table per private subnet (all route to the same NAT Gateway)
- **Subnet Requirement**: No public subnets required
- **Use Case**: Simplified management, automatic scaling, high availability across all AZs

### Zonal NAT Gateway (Traditional)
- **Count**: 1 NAT Gateway per AZ (or per subnet)
- **Route Tables**: Route tables match NAT Gateway count
- **Subnet Requirement**: Requires public subnets
- **Use Case**: Fine-grained control, per-AZ NAT Gateways

## Important Notes

1. **Expansion Timing**: When deploying workloads in a new AZ, the regional NAT Gateway typically takes 15-20 minutes (up to 60 minutes) to expand to that AZ. During this period, traffic may be temporarily routed through existing AZs.

2. **Private Connectivity**: Regional NAT Gateways do not support private connectivity. For workloads requiring private connectivity, continue using zonal NAT Gateways.

3. **Availability**: This feature is available in all commercial AWS Regions, except for AWS GovCloud (US) Regions and China Regions.

4. **Cost Considerations**: If you choose to create a NAT gateway with regional availability in your VPC, you are charged for each hour that the NAT Gateway is configured in each availability zone. For example, if your regional NAT is running across three Availability Zones(AZs) for one hour, you'll be billed for three 'NAT Gateway-hours'.
From: https://aws.amazon.com/vpc/pricing/

## Outputs

After applying this configuration, you can see:
- Single NAT Gateway ID in `natgw_ids` output (list with one element)
- All private route tables route to the same NAT Gateway (`private_nat_gateway_route_ids`)
- The addresses of the regional NAT Gateway in `natgw_regional_addresses`: one entry per Availability Zone the NAT Gateway is active in, with the allocation ID, network interface ID and public IP assigned by AWS
- `nat_ids` and `nat_public_ips` are empty: with `eip_allocation = "auto"` the module creates no Elastic IPs. They are only populated with `eip_allocation = "manual"`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.24.0 (required for regional NAT gateway support) |

## References

- [AWS Regional NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html)
- [AWS Blog: Introducing Amazon VPC Regional NAT Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-amazon-vpc-regional-nat-gateway/)
