package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-west-2", "eu-west-1", "eu-north-1", "ap-south-1", "ap-northeast-2"}, nil)

	// Expected values
	expVpcCidr := "10.99.0.0/16"
	var expAvailabilityZones []string
	for _, az := range []string{"a", "b", "c"} {
		expAvailabilityZones = append(expAvailabilityZones, fmt.Sprintf("%s%s", awsRegion, az))
	}
	expPrivateSubnetCidrs := []string{"10.99.1.0/24", "10.99.2.0/24", "10.99.3.0/24"}
	expPublicSubnetCidrs := []string{"10.99.101.0/24", "10.99.102.0/24", "10.99.103.0/24"}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/simple-vpc",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":          awsRegion,
			"cidr":            expVpcCidr,
			"azs":             expAvailabilityZones,
			"private_subnets": expPrivateSubnetCidrs,
			"public_subnets":  expPublicSubnetCidrs,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	assert.Equal(t, vpcCidr, expVpcCidr)

	availabilityZones := terraform.OutputList(t, terraformOptions, "azs")
	assert.Equal(t, expAvailabilityZones, availabilityZones)

	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnets")
	require.Equal(t, len(expPrivateSubnetCidrs), len(privateSubnets))
	// Verify if the network that is supposed to be private is really private
	assert.False(t, aws.IsPublicSubnet(t, privateSubnets[0], awsRegion))

	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnets_cidr_blocks")
	assert.Equal(t, expPrivateSubnetCidrs, privateSubnetCidrs)

	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnets")
	require.Equal(t, len(expPublicSubnetCidrs), len(publicSubnets))
	// Verify if the network that is supposed to be public is really public
	assert.True(t, aws.IsPublicSubnet(t, publicSubnets[0], awsRegion))

	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnets_cidr_blocks")
	assert.Equal(t, expPublicSubnetCidrs, publicSubnetCidrs)
}
