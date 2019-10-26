# Test fixture of simple VPC

Configuration in this directory creates a set of VPC resources to be tested by test kitchen.

There is a public and private subnet created per availability zone in addition to single NAT Gateway shared between 2 availability zones.

## Usage

To run the tests, from the repo root execute:

```bash
$ kitchen test
...
Finished in 4.25 seconds (files took 2.75 seconds to load)
20 examples, 0 failures

       Finished verifying <default-aws> (0m9.03s).
-----> Kitchen is finished. (0m9.40s)
```

This will destroy any existing test resources, create the resources afresh, run the tests, report back, and destroy the resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region |  | string | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| region | Region we created the resources in. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
