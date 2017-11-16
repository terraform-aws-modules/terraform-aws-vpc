Test fixture of simple VPC
==========

Configuration in this directory creates a set of VPC resources to be tested by test kitchen.

There is a public and private subnet created per availability zone in addition to single NAT Gateway shared between all 3 availability zones.

Usage
=====

To run the tests, from the repo root execute:

```bash
$ kitchen test
```

This will destroy any existing test resources, create the resources afresh, run the tests, report back, and destroy the resources.
