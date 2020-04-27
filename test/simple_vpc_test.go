package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSimpleVpc(t *testing.T) {
	t.Parallel()

	// Expected values
	expVpcCidr := "10.120.0.0/16"
	expectedName := fmt.Sprintf("vpc-terratest-%s", strings.ToLower(random.UniqueId()))
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple-vpc",
		Upgrade:      true,

		Vars: map[string]interface{}{
			"vpc_name": expectedName,
			"region":   awsRegion,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	// defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	assert.Equal(t, vpcCidr, expVpcCidr)

}
