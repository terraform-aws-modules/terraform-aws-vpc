# Test

Sub-directories within this directory are used to execute tests using `terratest`.

Note: Test execution will create actual resources in AWS and incur somme (negligble) charges during test execution.

## Usage

You will need [go version 1.13](https://github.com/google/go-github) or later to execute the test suite.

To run the test suite, from the repo root execute:

```bash
$ make test

...
TestExamplesComplete 2020-01-12T16:59:52-05:00 command.go:158: Destroy complete! Resources: 20 destroyed.
PASS
ok  	simple_vpc_test.go	215.531s
```

To run a single test with a custom timeout, execute the following from the target test directory:

```bash
go test -count=1 -timeout 30m
```

`-count=1` : Disable test caching

`-timeout 30m` : Timeout and fail tests after 30m

`terratest` will initialize terraform, provision the test resources, and then destroy the test resources. The tests are evaluated for pass/fail based on the outputs compared against what `terratest` is expecting, as defined in the `xxx_test.go` for each sub-directory.

To learn more about `terratest`, visit [here](https://github.com/gruntwork-io/terratest)
