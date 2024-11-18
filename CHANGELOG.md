# Changelog

All notable changes to this project will be documented in this file.

## [5.16.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.15.0...v5.16.0) (2024-11-18)


### Features

* Added additional conditions into Flow Log IAM Role Assumption Policy ([#1138](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1138)) ([7744d3f](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/7744d3fea63db36bcb15485f3694c0646be44da0))

## [5.15.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.14.0...v5.15.0) (2024-11-03)


### Features

* Add option to create/delete NAT Gateway route for private route tables ([#1127](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1127)) ([f02a1af](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/f02a1af5aedc550c81048cfa880153bedf2a006d))

## [5.14.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.13.0...v5.14.0) (2024-10-18)


### Features

* Add outputs for the full list of subnets created and their attributes ([#1116](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1116)) ([e212245](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/e2122450fa816fb844e987485f2b8804606576dd))


### Bug Fixes

* Update CI workflow versions to latest ([#1125](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1125)) ([b1f2125](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/b1f2125bf1015bfc3900feda290ade8bd0a7b871))

## [5.13.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.12.1...v5.13.0) (2024-08-16)


### Features

* Add support for `ip_address_type` for VPC endpoint ([#1096](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1096)) ([d868303](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/d868303bd78b8c56cf76e2495672d42b256a1387))

## [5.12.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.12.0...v5.12.1) (2024-08-09)


### Bug Fixes

* Update flow log ARNs to use partition from aws_partition data source ([#1112](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1112)) ([72cde38](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/72cde38fb5c500323858bb44eaed2924c7f826f9))

## [5.12.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.11.0...v5.12.0) (2024-08-03)


### Features

* Restrict flow log policy to use log group ARNs ([#1088](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1088)) ([9256722](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/92567225dc73ef939b86a241b9607cb13329fb75))

## [5.11.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.10.0...v5.11.0) (2024-08-03)


### Features

* Add route to `0.0.0.0/0` & `::/0` (when IPv6 is enabled) on all public route tables ([#1100](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1100)) ([b3e7803](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/b3e78033bbee8346341a523f78f762ade41eb93b))

## [5.10.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.9.0...v5.10.0) (2024-08-02)


### Features

* Added ipv6_address_preferred_lease_time parameter to aws_vpc_dhcp_options resource ([#1105](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1105)) ([3adb594](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/3adb594bc794468c80a99c5c1808056a88767f45))

## [5.9.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.8.1...v5.9.0) (2024-07-05)


### Features

* Allow custom VPC Flow Log IAM Role name and IAM Policy name ([#1089](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1089)) ([f8cd168](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/f8cd1681837c8c4a24af6fe73035724a03e1e66e))

## [5.8.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.8.0...v5.8.1) (2024-04-26)


### Bug Fixes

* Do not replace NAT gateways when additional subnets are added ([#1055](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1055)) ([cf18c37](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/cf18c37591f860908e2223b4f488787e8a5f74f3))

## [5.8.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.7.2...v5.8.0) (2024-04-25)


### Features

* Add support for multiple route tables to public and intra subnets ([#1051](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1051)) ([da05f24](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/da05f24c5c603a31d320d5ad92493bb39fea9f3d))

## [5.7.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.7.1...v5.7.2) (2024-04-24)


### Bug Fixes

* Create private_ipv6_egress routes only when having at least one private subnet ([#1062](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1062)) ([8701204](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/8701204c28a0ff984c5ade71400c6208c6953bfc))

## [5.7.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.7.0...v5.7.1) (2024-04-06)


### Bug Fixes

* Create the same number of IPv6 egress only gateway routes as the number of NAT gateways that are enabled/created ([#1059](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1059)) ([77df552](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/77df552a8aa43bb3711243a3a5ef3e29f70a4068))

## [5.7.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.6.0...v5.7.0) (2024-03-22)


### Features

* Allow setting vpc endpoints as an input for each endpoint ([#1056](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1056)) ([9163310](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/9163310db647ed98094319980bd8eef72bee492b))

## [5.6.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.5.3...v5.6.0) (2024-03-14)


### Features

* Support VPC flow log cloudwatch log group class ([#1053](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1053)) ([e2970fd](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/e2970fd747bbf5d0b1539f7bbbdced56977a1bdf))

## [5.5.3](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.5.2...v5.5.3) (2024-03-06)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#1052](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1052)) ([3b5b7f1](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/3b5b7f1fea768c6c933ea1ce2f8ee11250fa94cb))

### [5.5.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.5.1...v5.5.2) (2024-02-09)


### Bug Fixes

* Added create_before_destroy to aws_customer_gateway ([#1036](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1036)) ([5f5df57](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/5f5df571925895ad1fdf5a3bd04e539aa13f5a1d))

### [5.5.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.5.0...v5.5.1) (2024-01-13)


### Bug Fixes

* Correct VPC endpoint private DNS resolver `for_each` key ([#1029](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1029)) ([a837be1](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/a837be12882c8f74984620752937b4806da2d6d4))

## [5.5.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.4.0...v5.5.0) (2024-01-09)


### Features

* Add support for `dns_options` on VPC endpoints ([#1023](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1023)) ([32f853f](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/32f853f4c099ad134d9c739d585c42a7c06a797b))

## [5.4.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.3.0...v5.4.0) (2023-12-11)


### Features

* Add Cross Account Flow Support ([#1014](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1014)) ([6e25437](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/6e25437b16955b9393348d91965ead2f755fb2e0))

## [5.3.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.2.0...v5.3.0) (2023-12-11)


### Features

* Add NAT gateway interface ids output ([#1006](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1006)) ([898bbaf](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/898bbaf46ba8ebad54983d63fa9e8eac6456903b))

## [5.2.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.1.2...v5.2.0) (2023-11-18)


### Features

* Add `skip_destroy` to vpc flow log cloudwatch log group ([#1009](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1009)) ([abe2c0f](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/abe2c0fcd23f1adfcb6e3a7739811e2482e2d197))

### [5.1.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.1.1...v5.1.2) (2023-09-07)


### Bug Fixes

* The number of intra subnets should not influence the number of NAT gateways provisioned ([#968](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/968)) ([1e36f9f](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/1e36f9f8a01eb26be83d8e1ce2227a6890390b0e))

### [5.1.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.1.0...v5.1.1) (2023-07-25)


### Bug Fixes

* Ensure database route table output works ([#926](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/926)) ([e4c48d4](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/e4c48d4675718d5bd8c72c6b934c70c0f4bf1670)), closes [#857](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/857)

## [5.1.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v5.0.0...v5.1.0) (2023-07-15)


### Features

* Add support for creating a security group for VPC endpoint(s) ([#962](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/962)) ([802d5f1](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/802d5f14c29db4e50b3f2aaf87950845594a31bd))

## [5.0.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v4.0.2...v5.0.0) (2023-05-30)


### ⚠ BREAKING CHANGES

* Bump Terraform AWS Provider version to 5.0 (#941)

### Features

* Bump Terraform AWS Provider version to 5.0 ([#941](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/941)) ([2517eb9](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/2517eb98a39500897feecd27178994055ee2eb5e))

### [4.0.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v4.0.1...v4.0.2) (2023-05-15)


### Bug Fixes

* Add dns64 routes ([#924](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/924)) ([743798d](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/743798daa14b8a5b827b37053ca7e3c5b8865c06))

### [4.0.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v4.0.0...v4.0.1) (2023-04-07)


### Bug Fixes

* Add missing private subnets to max subnet length local ([#920](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/920)) ([6f51f34](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/6f51f34d9c91d62984ff985aad6b5ef03eb2a75a))

## [4.0.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.19.0...v4.0.0) (2023-04-07)


### ⚠ BREAKING CHANGES

* Support enabling NAU metrics in "aws_vpc" resource (#838)

### Features

* Support enabling NAU metrics in "aws_vpc" resource ([#838](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/838)) ([44e6eaa](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/44e6eaa154a9e78c8d6e86d1c735f95825b270db))

## [3.19.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.18.1...v3.19.0) (2023-01-13)


### Features

* Add public and private tags per az ([#860](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/860)) ([a82c9d3](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/a82c9d3272e3a83d22f70f174133dd26c24eee21))


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#876](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/876)) ([2a0319e](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/2a0319ec3244169997c6dac0d7850897ba9b9162))

### [3.18.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.18.0...v3.18.1) (2022-10-27)


### Bug Fixes

* Update CI configuration files to use latest version ([#850](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/850)) ([b94561d](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/b94561dc61b8bbedb5e36e0334e030edf03a1c7b))

## [3.18.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.17.0...v3.18.0) (2022-10-21)


### Features

* Added ability to specify CloudWatch Log group name for VPC Flow logs ([#847](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/847)) ([80d6318](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/80d631884126075e1adbe2d410f46ef6b9ea8a19))

## [3.17.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.16.1...v3.17.0) (2022-10-21)


### Features

* Add custom subnet names ([#816](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/816)) ([4416e37](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/4416e379ed9a9b650a12a629441410f326b44c0c))

### [3.16.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.16.0...v3.16.1) (2022-10-14)


### Bug Fixes

* Prevent an error when VPC Flow log log_group and role is not created ([#844](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/844)) ([b0c81ad](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/b0c81ad61214069f8fa6d35492716c9d4cac9096))

## [3.16.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.15.0...v3.16.0) (2022-09-26)


### Features

* Add IPAM IPv6 support ([#718](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/718)) ([4fe7745](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/4fe7745ddb675af3bd50daf335ad3ffa16d08a98))

## [3.15.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.14.4...v3.15.0) (2022-09-25)


### Features

* Add IPAM IPv4 support ([#716](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/716)) ([6eddcad](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/6eddcad72867cd9df536d13ea8fdac15e0eebbd4))

### [3.14.4](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.14.3...v3.14.4) (2022-09-05)


### Bug Fixes

* Remove EC2-classic deprecation warnings by hardcoding classiclink values to `null` ([#826](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/826)) ([736931b](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/736931b0a707115a1fbeb45e0d6f784199cba95e))

### [3.14.3](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.14.2...v3.14.3) (2022-09-02)


### Bug Fixes

* Allow `security_group_ids` to take `null` values ([#825](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/825)) ([67ef09a](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/67ef09a1717f155d9a2f22a867230bf872af4cef))

### [3.14.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.14.1...v3.14.2) (2022-06-20)


### Bug Fixes

* Compact CIDR block outputs to avoid empty diffs ([#802](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/802)) ([c3fd156](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/c3fd1566df23cc4a2d3447b1964956964b9830a3))

### [3.14.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.14.0...v3.14.1) (2022-06-16)


### Bug Fixes

* Declare data resource only for requested VPC endpoints ([#800](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/800)) ([024fbc0](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/024fbc01bf468240213666dfd4428f5b425794d1))

## [3.14.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.13.0...v3.14.0) (2022-03-31)


### Features

* Change to allow create variable within specific vpc objects ([#773](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/773)) ([5913d7e](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/5913d7ebe9805c8c5f39a7afb6b28bf1c4e9505e))

## [3.13.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.12.0...v3.13.0) (2022-03-11)


### Features

* Made it clear that we stand with Ukraine ([acb0ae5](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/acb0ae548d7c6dd0594565c7a6087f65b4c45f93))

## [3.12.0](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.5...v3.12.0) (2022-02-07)


### Features

* Added custom route for NAT gateway ([#748](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/748)) ([728a4d1](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/728a4d114000f256a24d8d4bc9895184df533d0c))

### [3.11.5](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.4...v3.11.5) (2022-01-28)


### Bug Fixes

* Addresses persistent diff with manage_default_network_acl ([#737](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/737)) ([d247d8e](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/d247d8e44728a86d0024a2da9b0cd34ad218c33a))

### [3.11.4](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.3...v3.11.4) (2022-01-26)


### Bug Fixes

* Fixed redshift_route_table_ids outputs ([#739](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/739)) ([7c8df92](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/7c8df92f471af5f40ac126f2bb194722d92228f3))

### [3.11.3](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.2...v3.11.3) (2022-01-13)


### Bug Fixes

* Update tags for default resources to correct spurious plan diffs ([#730](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/730)) ([d1adf74](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/d1adf743b27ef131b559ec15c7aadc37466a74b9))

### [3.11.2](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.1...v3.11.2) (2022-01-11)


### Bug Fixes

* Correct `for_each` map on VPC endpoints to propagate endpoint maps correctly ([#729](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/729)) ([19fcf0d](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/19fcf0d68027dea10ecaa456ccea1cb50567e388))

### [3.11.1](https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.0...v3.11.1) (2022-01-10)


### Bug Fixes

* update CI/CD process to enable auto-release workflow ([#711](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/711)) ([57ba0ef](https://github.com/terraform-aws-modules/terraform-aws-vpc/commit/57ba0ef08063390636daedcf88f71443281c2b84))

<a name="v3.11.0"></a>
## [v3.11.0] - 2021-11-04

- feat: Add tags to VPC flow logs IAM policy ([#706](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/706))


<a name="v3.10.0"></a>
## [v3.10.0] - 2021-10-15

- fix: Enabled destination_options only for VPC Flow Logs on S3 ([#703](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/703))


<a name="v3.9.0"></a>
## [v3.9.0] - 2021-10-15

- feat: Added timeout block to aws_default_route_table resource ([#701](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/701))


<a name="v3.8.0"></a>
## [v3.8.0] - 2021-10-14

- feat: Added support for VPC Flow Logs in Parquet format ([#700](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/700))
- docs: Fixed docs in simple-vpc
- chore: Updated outputs in example ([#690](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/690))
- Updated pre-commit


<a name="v3.7.0"></a>
## [v3.7.0] - 2021-08-31

- feat: Add support for naming and tagging subnet groups ([#688](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/688))


<a name="v3.6.0"></a>
## [v3.6.0] - 2021-08-18

- feat: Added device_name to customer gateway object. ([#681](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/681))


<a name="v3.5.0"></a>
## [v3.5.0] - 2021-08-15

- fix: Return correct route table when enable_public_redshift is set ([#337](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/337))


<a name="v3.4.0"></a>
## [v3.4.0] - 2021-08-13

- fix: Update the terraform to support new provider signatures ([#678](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/678))


<a name="v3.3.0"></a>
## [v3.3.0] - 2021-08-10

- docs: Added ID of aws_vpc_dhcp_options to outputs ([#669](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/669))
- fix: Fixed mistake in separate private route tables example ([#664](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/664))
- fix: Fixed SID for assume role policy for flow logs ([#670](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/670))


<a name="v3.2.0"></a>
## [v3.2.0] - 2021-06-28

- feat: Added database_subnet_group_name variable ([#656](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/656))


<a name="v3.1.0"></a>
## [v3.1.0] - 2021-06-07

- chore: Removed link to cloudcraft
- chore: Private DNS cannot be used with S3 endpoint ([#651](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/651))
- chore: update CI/CD to use stable `terraform-docs` release artifact and discoverable Apache2.0 license ([#643](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/643))


<a name="v3.0.0"></a>
## [v3.0.0] - 2021-04-26

- refactor: remove existing vpc endpoint configurations from base module and move into sub-module ([#635](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/635))


<a name="v2.78.0"></a>
## [v2.78.0] - 2021-04-06

- feat: Add outpost support (subnet, NACL, IPv6) ([#542](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/542))
- chore: update documentation and pin `terraform_docs` version to avoid future changes ([#619](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/619))
- chore: align ci-cd static checks to use individual minimum Terraform versions ([#606](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/606))


<a name="v2.77.0"></a>
## [v2.77.0] - 2021-02-23

- feat: add default route table resource to manage default route table, its tags, routes, etc. ([#599](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/599))


<a name="v2.76.0"></a>
## [v2.76.0] - 2021-02-23

- fix: Remove CreateLogGroup permission from service role ([#550](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/550))


<a name="v2.75.0"></a>
## [v2.75.0] - 2021-02-23

- feat: add vpc endpoint policies to supported services ([#601](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/601))


<a name="v2.74.0"></a>
## [v2.74.0] - 2021-02-22

- fix: use filter for getting service type for S3 endpoint and update to allow s3 to use interface endpoint types ([#597](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/597))
- chore: Updated the conditional creation section of the README ([#584](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/584))


<a name="v2.73.0"></a>
## [v2.73.0] - 2021-02-22

- chore: Adds database_subnet_group_name as an output variable ([#592](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/592))
- fix: aws_default_security_group was always dirty when manage_default_security_group was set  ([#591](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/591))


<a name="v2.72.0"></a>
## [v2.72.0] - 2021-02-22

- fix: Correctly manage route tables for database subnets when multiple NAT gateways present ([#518](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/518))
- chore: add ci-cd workflow for pre-commit checks ([#598](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/598))


<a name="v2.71.0"></a>
## [v2.71.0] - 2021-02-20

- chore: update documentation based on latest `terraform-docs` which includes module and resource sections ([#594](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/594))
- feat: Upgraded minimum required versions of AWS provider to 3.10 ([#574](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/574))
- fix: Specify an endpoint type for S3 VPC endpoint ([#573](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/573))
- fix: Fixed wrong count in DMS endpoint ([#566](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/566))
- feat: Adding VPC endpoint for DMS ([#564](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/564))
- fix: Adding missing RDS endpoint to output.tf ([#563](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/563))
- docs: Clarifies default_vpc attributes ([#552](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/552))
- feat: Adding vpc_flow_log_permissions_boundary ([#536](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/536))
- docs: Updated README and pre-commit ([#537](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/537))
- feat: Lambda VPC Endpoint ([#534](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/534))
- Updated README
- feat: Added Codeartifact API/Repo vpc endpoints ([#515](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/515))
- fix: Updated min required version of Terraform to 0.12.21 ([#532](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/532))
- Fixed circleci configs
- fix: Resource aws_default_network_acl orphaned subnet_ids ([#530](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/530))
- fix: Removed ignore_changes to work with Terraform 0.14 ([#526](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/526))
- feat: Added support for Terraform 0.14 ([#525](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/525))
- revert: Create only required number of NAT gateways ([#492](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/492)) ([#517](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/517))
- fix: Create only required number of NAT gateways ([#492](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/492))
- docs: Updated docs with pre-commit
- feat: Added Textract vpc endpoint ([#509](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/509))
- fix: Split appstream to appstream_api and appstream_streaming ([#508](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/508))
- feat: Add support for security groups ids in default sg's rules ([#491](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/491))
- feat: Added tflint as pre-commit hook ([#507](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/507))
- feat: add enable_public_s3_endpoint variable for S3 VPC Endpoint for public subnets ([#502](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/502))
- feat: Add ability to create CodeDeploy endpoint to VPC ([#501](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/501))
- feat: Add ability to create RDS endpoint to VPC ([#499](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/499))
- fix: Use database route table instead of private route table for NAT gateway route ([#476](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/476))
- feat: add arn outputs for: igw, cgw, vgw, default vpc, acls ([#471](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/471))
- fix: InvalidServiceName for elasticbeanstalk_health ([#484](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/484))
- feat: bump version of aws provider version to support 3.* ([#479](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/479))
- fix: bumping terraform version from 0.12.6 to 0.12.7 in circleci to include regexall function ([#474](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/474))
- docs: Fix typo in nat_public_ips ([#460](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/460))
- feat: manage default security group ([#382](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/382))
- feat: add support for disabling IGW for public subnets ([#457](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/457))
- fix: Reorder tags to allow overriding Name tag in route tables ([#458](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/458))
- fix: Output list of external_nat_ips when using external eips ([#432](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/432))
- Updated pre-commit hooks
- feat: Add support for VPC flow log max_aggregation_interval ([#431](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/431))
- feat: Add support for tagging egress only internet gateway ([#430](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/430))
- feat: Enable support for Terraform 0.13 as a valid version by setting minimum version required ([#455](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/455))
- feat: add vpc_owner_id to outputs ([#428](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/428))
- docs: Fixed README
- Merge branch 'master' into master
- Updated description of vpc_owner_id
- fix: Fix wrong ACM PCA output ([#450](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/450))
- feat: Added support for more VPC endpoints ([#369](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/369))
- feat: Add VPC Endpoint for SES ([#449](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/449))
- feat: Add routes table association and route attachment outputs ([#398](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/398))
- fix: Updated outputs in ipv6 example ([#375](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/375))
- added owner_id output ([#1](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1))
- docs: Updated required versions of Terraform
- feat: Add EC2 Auto Scaling VPC endpoint ([#374](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/374))
- docs: Document create_database_subnet_group requiring database_subnets ([#424](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/424))
- feat: Add intra subnet VPN route propagation ([#421](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/421))
- chore: Add badge for latest version number ([#384](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/384))
- Added tagging for VPC Flow Logs ([#407](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/407))
- Add support for specifying AZ in VPN Gateway ([#401](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/401))
- Fixed output of aws_flow_log
- Add VPC Flow Logs capabilities ([#316](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/316))
- Added support for both types of values in azs (names and ids) ([#370](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/370))
- Set minimum terraform version to 0.12.6 (fixes circleci) ([#390](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/390))
- Updated pre-commit-terraform with terraform-docs 0.8.0 support ([#388](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/388))
- Added note about Transit Gateway integration ([#386](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/386))
- fix ipv6 enable ([#340](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/340))
- Added Customer Gateway resource ([#360](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/360))
- Update TFLint to v0.12.1 for circleci ([#351](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/351))
- Add Elastic File System & Cloud Directory VPC Endpoints ([#355](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/355))
- Fixed spelling mistakes
- Updated network-acls example with IPv6 rules
- Added support for `ipv6_cidr_block` in network acls ([#329](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/329))
- Added VPC Endpoints for AppStream, Athena & Rekognition ([#335](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/335))
- Add VPC endpoints for CloudFormation, CodePipeline, Storage Gateway, AppMesh, Transfer, Service Catalog & SageMaker(Runtime & API) ([#324](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/324))
- Added support for EC2 ClassicLink ([#322](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/322))
- Added support for ICMP rules in Network ACL ([#286](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/286))
- Added tags to VPC Endpoints ([#292](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/292))
- Added more VPC endpoints (Glue, STS, Sagemaker Notebook), and all missing outputs ([#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311))
- Add IPv6 support ([#317](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/317))
- Fixed README after merge
- Output var.name ([#303](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/303))
- Fixed README after merge
- Additional VPC Endpoints ([#302](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/302))
- Added Kinesis streams and firehose VPC endpoints ([#301](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/301))
- adding transfer server vpc end point support
- adding codebuild, codecommit and git-codecommit vpc end point support
- adding config vpc end point support
- adding secrets manager vpc end point support
- Updated version of pre-commit-terraform
- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12 ([#288](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/288))
- Updated VPC endpoint example (fixed [#249](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/249))
- Update tflint to 0.8.2 for circleci task ([#280](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/280))
- Fixed broken 2.3.0
- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)
- Updated Terraform versions in README
- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))
- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.73.0"></a>
## [v1.73.0] - 2021-02-04

- fix: Fixed multiple VPC endpoint error for S3
- Add VPC endpoints for AppStream, Athena & Rekognition ([#336](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/336))
- Fixed Sagemaker resource name in VPC endpoint ([#323](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/323))
- Fixed name of appmesh VPC endpoint ([#320](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/320))
- Allow ICMP Network ACL rules ([#252](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/252))
- Added VPC endpoints from [#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311) to Terraform 0.11 branch ([#319](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/319))
- Add tags to VPC Endpoints ([#293](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/293))
- Add VPC endpoints for ELB, CloudTrail, CloudWatch and SNS ([#274](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/274))


<a name="v2.70.0"></a>
## [v2.70.0] - 2021-02-02

- feat: Upgraded minimum required versions of AWS provider to 3.10 ([#574](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/574))


<a name="v2.69.0"></a>
## [v2.69.0] - 2021-02-02

- fix: Specify an endpoint type for S3 VPC endpoint ([#573](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/573))


<a name="v2.68.0"></a>
## [v2.68.0] - 2021-01-29

- fix: Fixed wrong count in DMS endpoint ([#566](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/566))


<a name="v2.67.0"></a>
## [v2.67.0] - 2021-01-29

- feat: Adding VPC endpoint for DMS ([#564](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/564))
- fix: Adding missing RDS endpoint to output.tf ([#563](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/563))


<a name="v2.66.0"></a>
## [v2.66.0] - 2021-01-14

- docs: Clarifies default_vpc attributes ([#552](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/552))


<a name="v2.65.0"></a>
## [v2.65.0] - 2021-01-14

- feat: Adding vpc_flow_log_permissions_boundary ([#536](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/536))


<a name="v2.64.0"></a>
## [v2.64.0] - 2020-11-04

- docs: Updated README and pre-commit ([#537](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/537))


<a name="v2.63.0"></a>
## [v2.63.0] - 2020-10-26

- feat: Lambda VPC Endpoint ([#534](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/534))


<a name="v2.62.0"></a>
## [v2.62.0] - 2020-10-22

- Updated README
- feat: Added Codeartifact API/Repo vpc endpoints ([#515](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/515))


<a name="v2.61.0"></a>
## [v2.61.0] - 2020-10-22

- fix: Updated min required version of Terraform to 0.12.21 ([#532](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/532))
- Fixed circleci configs


<a name="v2.60.0"></a>
## [v2.60.0] - 2020-10-21

- fix: Resource aws_default_network_acl orphaned subnet_ids ([#530](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/530))


<a name="v2.59.0"></a>
## [v2.59.0] - 2020-10-19

- fix: Removed ignore_changes to work with Terraform 0.14 ([#526](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/526))


<a name="v2.58.0"></a>
## [v2.58.0] - 2020-10-16

- feat: Added support for Terraform 0.14 ([#525](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/525))


<a name="v2.57.0"></a>
## [v2.57.0] - 2020-10-06

- revert: Create only required number of NAT gateways ([#492](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/492)) ([#517](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/517))


<a name="v2.56.0"></a>
## [v2.56.0] - 2020-10-06

- fix: Create only required number of NAT gateways ([#492](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/492))


<a name="v2.55.0"></a>
## [v2.55.0] - 2020-09-28

- docs: Updated docs with pre-commit
- feat: Added Textract vpc endpoint ([#509](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/509))


<a name="v2.54.0"></a>
## [v2.54.0] - 2020-09-23

- fix: Split appstream to appstream_api and appstream_streaming ([#508](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/508))


<a name="v2.53.0"></a>
## [v2.53.0] - 2020-09-23

- feat: Add support for security groups ids in default sg's rules ([#491](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/491))


<a name="v2.52.0"></a>
## [v2.52.0] - 2020-09-22

- feat: Added tflint as pre-commit hook ([#507](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/507))


<a name="v2.51.0"></a>
## [v2.51.0] - 2020-09-15

- feat: add enable_public_s3_endpoint variable for S3 VPC Endpoint for public subnets ([#502](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/502))


<a name="v2.50.0"></a>
## [v2.50.0] - 2020-09-11

- feat: Add ability to create CodeDeploy endpoint to VPC ([#501](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/501))


<a name="v2.49.0"></a>
## [v2.49.0] - 2020-09-11

- feat: Add ability to create RDS endpoint to VPC ([#499](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/499))


<a name="v2.48.0"></a>
## [v2.48.0] - 2020-08-17

- fix: Use database route table instead of private route table for NAT gateway route ([#476](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/476))


<a name="v2.47.0"></a>
## [v2.47.0] - 2020-08-13

- feat: add arn outputs for: igw, cgw, vgw, default vpc, acls ([#471](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/471))


<a name="v2.46.0"></a>
## [v2.46.0] - 2020-08-13

- fix: InvalidServiceName for elasticbeanstalk_health ([#484](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/484))


<a name="v2.45.0"></a>
## [v2.45.0] - 2020-08-13

- feat: bump version of aws provider version to support 3.* ([#479](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/479))
- fix: bumping terraform version from 0.12.6 to 0.12.7 in circleci to include regexall function ([#474](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/474))
- docs: Fix typo in nat_public_ips ([#460](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/460))


<a name="v2.44.0"></a>
## [v2.44.0] - 2020-06-21

- feat: manage default security group ([#382](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/382))


<a name="v2.43.0"></a>
## [v2.43.0] - 2020-06-20

- feat: add support for disabling IGW for public subnets ([#457](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/457))


<a name="v2.42.0"></a>
## [v2.42.0] - 2020-06-20

- fix: Reorder tags to allow overriding Name tag in route tables ([#458](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/458))


<a name="v2.41.0"></a>
## [v2.41.0] - 2020-06-20

- fix: Output list of external_nat_ips when using external eips ([#432](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/432))


<a name="v2.40.0"></a>
## [v2.40.0] - 2020-06-20

- Updated pre-commit hooks
- feat: Add support for VPC flow log max_aggregation_interval ([#431](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/431))
- feat: Add support for tagging egress only internet gateway ([#430](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/430))


<a name="v2.39.0"></a>
## [v2.39.0] - 2020-06-06

- feat: Enable support for Terraform 0.13 as a valid version by setting minimum version required ([#455](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/455))


<a name="v2.38.0"></a>
## [v2.38.0] - 2020-05-25

- feat: add vpc_owner_id to outputs ([#428](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/428))
- docs: Fixed README
- Merge branch 'master' into master
- Updated description of vpc_owner_id
- added owner_id output ([#1](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1))


<a name="v2.37.0"></a>
## [v2.37.0] - 2020-05-25

- fix: Fix wrong ACM PCA output ([#450](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/450))


<a name="v2.36.0"></a>
## [v2.36.0] - 2020-05-25

- feat: Added support for more VPC endpoints ([#369](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/369))


<a name="v2.35.0"></a>
## [v2.35.0] - 2020-05-25

- feat: Add VPC Endpoint for SES ([#449](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/449))


<a name="v2.34.0"></a>
## [v2.34.0] - 2020-05-25

- feat: Add routes table association and route attachment outputs ([#398](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/398))
- fix: Updated outputs in ipv6 example ([#375](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/375))


<a name="v2.33.0"></a>
## [v2.33.0] - 2020-04-02

- docs: Updated required versions of Terraform
- feat: Add EC2 Auto Scaling VPC endpoint ([#374](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/374))
- docs: Document create_database_subnet_group requiring database_subnets ([#424](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/424))


<a name="v2.32.0"></a>
## [v2.32.0] - 2020-03-24

- feat: Add intra subnet VPN route propagation ([#421](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/421))


<a name="v2.31.0"></a>
## [v2.31.0] - 2020-03-20

- chore: Add badge for latest version number ([#384](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/384))


<a name="v2.30.0"></a>
## [v2.30.0] - 2020-03-19



<a name="v2.29.0"></a>
## [v2.29.0] - 2020-03-13

- Added tagging for VPC Flow Logs ([#407](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/407))


<a name="v2.28.0"></a>
## [v2.28.0] - 2020-03-11

- Add support for specifying AZ in VPN Gateway ([#401](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/401))


<a name="v2.27.0"></a>
## [v2.27.0] - 2020-03-11

- Fixed output of aws_flow_log


<a name="v2.26.0"></a>
## [v2.26.0] - 2020-03-11

- Add VPC Flow Logs capabilities ([#316](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/316))


<a name="v2.25.0"></a>
## [v2.25.0] - 2020-03-02

- Added support for both types of values in azs (names and ids) ([#370](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/370))


<a name="v2.24.0"></a>
## [v2.24.0] - 2020-01-23

- Set minimum terraform version to 0.12.6 (fixes circleci) ([#390](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/390))


<a name="v2.23.0"></a>
## [v2.23.0] - 2020-01-21

- Updated pre-commit-terraform with terraform-docs 0.8.0 support ([#388](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/388))


<a name="v2.22.0"></a>
## [v2.22.0] - 2020-01-16

- Added note about Transit Gateway integration ([#386](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/386))


<a name="v2.21.0"></a>
## [v2.21.0] - 2019-11-27

- fix ipv6 enable ([#340](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/340))


<a name="v2.20.0"></a>
## [v2.20.0] - 2019-11-27

- Added Customer Gateway resource ([#360](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/360))
- Update TFLint to v0.12.1 for circleci ([#351](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/351))


<a name="v2.19.0"></a>
## [v2.19.0] - 2019-11-27

- Add Elastic File System & Cloud Directory VPC Endpoints ([#355](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/355))


<a name="v2.18.0"></a>
## [v2.18.0] - 2019-11-04

- Fixed spelling mistakes
- Updated network-acls example with IPv6 rules
- Added support for `ipv6_cidr_block` in network acls ([#329](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/329))
- Added VPC Endpoints for AppStream, Athena & Rekognition ([#335](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/335))
- Add VPC endpoints for CloudFormation, CodePipeline, Storage Gateway, AppMesh, Transfer, Service Catalog & SageMaker(Runtime & API) ([#324](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/324))
- Added support for EC2 ClassicLink ([#322](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/322))
- Added support for ICMP rules in Network ACL ([#286](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/286))
- Added tags to VPC Endpoints ([#292](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/292))
- Added more VPC endpoints (Glue, STS, Sagemaker Notebook), and all missing outputs ([#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311))
- Add IPv6 support ([#317](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/317))
- Fixed README after merge
- Output var.name ([#303](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/303))
- Fixed README after merge
- Additional VPC Endpoints ([#302](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/302))
- Added Kinesis streams and firehose VPC endpoints ([#301](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/301))
- adding transfer server vpc end point support
- adding codebuild, codecommit and git-codecommit vpc end point support
- adding config vpc end point support
- adding secrets manager vpc end point support
- Updated version of pre-commit-terraform
- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12 ([#288](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/288))
- Updated VPC endpoint example (fixed [#249](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/249))
- Update tflint to 0.8.2 for circleci task ([#280](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/280))
- Fixed broken 2.3.0
- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)
- Updated Terraform versions in README
- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))
- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.72.0"></a>
## [v1.72.0] - 2019-09-30

- Add VPC endpoints for AppStream, Athena & Rekognition ([#336](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/336))
- Fixed Sagemaker resource name in VPC endpoint ([#323](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/323))
- Fixed name of appmesh VPC endpoint ([#320](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/320))
- Allow ICMP Network ACL rules ([#252](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/252))
- Added VPC endpoints from [#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311) to Terraform 0.11 branch ([#319](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/319))
- Add tags to VPC Endpoints ([#293](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/293))
- Add VPC endpoints for ELB, CloudTrail, CloudWatch and SNS ([#274](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/274))


<a name="v2.17.0"></a>
## [v2.17.0] - 2019-09-30

- Updated network-acls example with IPv6 rules
- Added support for `ipv6_cidr_block` in network acls ([#329](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/329))


<a name="v2.16.0"></a>
## [v2.16.0] - 2019-09-30

- Added VPC Endpoints for AppStream, Athena & Rekognition ([#335](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/335))


<a name="v2.15.0"></a>
## [v2.15.0] - 2019-09-03

- Add VPC endpoints for CloudFormation, CodePipeline, Storage Gateway, AppMesh, Transfer, Service Catalog & SageMaker(Runtime & API) ([#324](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/324))
- Added support for EC2 ClassicLink ([#322](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/322))
- Added support for ICMP rules in Network ACL ([#286](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/286))
- Added tags to VPC Endpoints ([#292](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/292))
- Added more VPC endpoints (Glue, STS, Sagemaker Notebook), and all missing outputs ([#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311))
- Add IPv6 support ([#317](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/317))
- Fixed README after merge
- Output var.name ([#303](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/303))
- Fixed README after merge
- Additional VPC Endpoints ([#302](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/302))
- Added Kinesis streams and firehose VPC endpoints ([#301](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/301))
- adding transfer server vpc end point support
- adding codebuild, codecommit and git-codecommit vpc end point support
- adding config vpc end point support
- adding secrets manager vpc end point support
- Updated version of pre-commit-terraform
- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12 ([#288](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/288))
- Updated VPC endpoint example (fixed [#249](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/249))
- Update tflint to 0.8.2 for circleci task ([#280](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/280))
- Fixed broken 2.3.0
- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)
- Updated Terraform versions in README
- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))
- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.71.0"></a>
## [v1.71.0] - 2019-09-03

- Fixed Sagemaker resource name in VPC endpoint ([#323](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/323))
- Fixed name of appmesh VPC endpoint ([#320](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/320))
- Allow ICMP Network ACL rules ([#252](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/252))
- Added VPC endpoints from [#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311) to Terraform 0.11 branch ([#319](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/319))
- Add tags to VPC Endpoints ([#293](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/293))
- Add VPC endpoints for ELB, CloudTrail, CloudWatch and SNS ([#274](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/274))


<a name="v2.14.0"></a>
## [v2.14.0] - 2019-09-03

- Added support for EC2 ClassicLink ([#322](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/322))


<a name="v2.13.0"></a>
## [v2.13.0] - 2019-09-03

- Added support for ICMP rules in Network ACL ([#286](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/286))
- Added tags to VPC Endpoints ([#292](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/292))
- Added more VPC endpoints (Glue, STS, Sagemaker Notebook), and all missing outputs ([#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311))
- Add IPv6 support ([#317](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/317))
- Fixed README after merge
- Output var.name ([#303](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/303))
- Fixed README after merge
- Additional VPC Endpoints ([#302](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/302))
- Added Kinesis streams and firehose VPC endpoints ([#301](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/301))
- adding transfer server vpc end point support
- adding codebuild, codecommit and git-codecommit vpc end point support
- adding config vpc end point support
- adding secrets manager vpc end point support
- Updated version of pre-commit-terraform
- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12 ([#288](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/288))
- Updated VPC endpoint example (fixed [#249](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/249))
- Update tflint to 0.8.2 for circleci task ([#280](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/280))
- Fixed broken 2.3.0
- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)
- Updated Terraform versions in README
- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))
- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.70.0"></a>
## [v1.70.0] - 2019-09-03

- Allow ICMP Network ACL rules ([#252](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/252))


<a name="v1.69.0"></a>
## [v1.69.0] - 2019-09-03

- Added VPC endpoints from [#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311) to Terraform 0.11 branch ([#319](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/319))


<a name="v1.68.0"></a>
## [v1.68.0] - 2019-09-02

- Add tags to VPC Endpoints ([#293](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/293))
- Add VPC endpoints for ELB, CloudTrail, CloudWatch and SNS ([#274](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/274))


<a name="v2.12.0"></a>
## [v2.12.0] - 2019-09-02

- Added tags to VPC Endpoints ([#292](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/292))


<a name="v2.11.0"></a>
## [v2.11.0] - 2019-09-02

- Added more VPC endpoints (Glue, STS, Sagemaker Notebook), and all missing outputs ([#311](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/311))


<a name="v2.10.0"></a>
## [v2.10.0] - 2019-09-02

- Add IPv6 support ([#317](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/317))


<a name="v2.9.0"></a>
## [v2.9.0] - 2019-07-21

- Fixed README after merge
- Output var.name ([#303](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/303))


<a name="v2.8.0"></a>
## [v2.8.0] - 2019-07-21

- Fixed README after merge
- Additional VPC Endpoints ([#302](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/302))
- Added Kinesis streams and firehose VPC endpoints ([#301](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/301))
- adding transfer server vpc end point support
- adding codebuild, codecommit and git-codecommit vpc end point support
- adding config vpc end point support
- adding secrets manager vpc end point support
- Updated version of pre-commit-terraform


<a name="v2.7.0"></a>
## [v2.7.0] - 2019-06-17

- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12 ([#288](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/288))


<a name="v2.6.0"></a>
## [v2.6.0] - 2019-06-13

- Updated VPC endpoint example (fixed [#249](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/249))
- Update tflint to 0.8.2 for circleci task ([#280](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/280))
- Fixed broken 2.3.0
- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)
- Updated Terraform versions in README
- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))
- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.67.0"></a>
## [v1.67.0] - 2019-06-13

- Add VPC endpoints for ELB, CloudTrail, CloudWatch and SNS ([#274](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/274))


<a name="v2.5.0"></a>
## [v2.5.0] - 2019-06-05



<a name="v2.4.0"></a>
## [v2.4.0] - 2019-06-05

- Fixed broken 2.3.0


<a name="v2.3.0"></a>
## [v2.3.0] - 2019-06-04

- Fixed opportunity to create the vpc, vpn gateway routes (bug during upgrade to 0.12)


<a name="v2.2.0"></a>
## [v2.2.0] - 2019-05-28

- Updated Terraform versions in README


<a name="v2.1.0"></a>
## [v2.1.0] - 2019-05-27

- Added VPC Endpoints for SNS, Cloudtrail, ELB, Cloudwatch ([#269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/269))
- Upgrade Docker Image to fix CI ([#270](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/270))


<a name="v2.0.0"></a>
## [v2.0.0] - 2019-05-24

- Fixed merge conflicts
- Finally, Terraform 0.12 support ([#266](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/266))


<a name="v1.66.0"></a>
## [v1.66.0] - 2019-05-24

- Added VPC endpoints for SQS (closes [#248](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/248))
- ECS endpoint ([#261](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/261))


<a name="v1.65.0"></a>
## [v1.65.0] - 2019-05-21

- Improving DHCP options docs ([#260](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/260))


<a name="v1.64.0"></a>
## [v1.64.0] - 2019-04-25

- Fixed formatting
- Add Output Of Subnet ARNs ([#242](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/242))


<a name="v1.63.0"></a>
## [v1.63.0] - 2019-04-25

- Fixed formatting
- Added ARN of VPC in module output ([#245](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/245))


<a name="v1.62.0"></a>
## [v1.62.0] - 2019-04-25

- Add support for KMS VPC endpoint creation ([#243](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/243))


<a name="v1.61.0"></a>
## [v1.61.0] - 2019-04-25

- Added missing VPC endpoints outputs (resolves [#246](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/246)) ([#247](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/247))


<a name="v1.60.0"></a>
## [v1.60.0] - 2019-03-22

- Network ACLs ([#238](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/238))


<a name="v1.59.0"></a>
## [v1.59.0] - 2019-03-05

- Updated changelog
- Resolved conflicts after merge
- Redshift public subnets ([#222](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/222))
- Redshift public subnets ([#222](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/222))
- docs: Update comment in docs ([#226](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/226))


<a name="v1.58.0"></a>
## [v1.58.0] - 2019-03-01

- Updated changelog
- API gateway Endpoint ([#225](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/225))


<a name="v1.57.0"></a>
## [v1.57.0] - 2019-02-21

- Bump version


<a name="v1.56.0"></a>
## [v1.56.0] - 2019-02-21

- Added intra subnet suffix. ([#220](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/220))


<a name="v1.55.0"></a>
## [v1.55.0] - 2019-02-14

- Fixed formatting after [#213](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/213)
- Added subnet ids to ecr endpoints
- Added option to create ECR api and dkr endpoints


<a name="v1.54.0"></a>
## [v1.54.0] - 2019-02-14

- Fixed formatting after [#205](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/205)
- switch to terraform-docs v0.6.0
- add files updated by pre-commit
- add additional endpoints to examples
- fix typo
- add endpoints ec2messages, ssmmessages as those are required by Systems Manager in addition to ec2 and ssm.


<a name="v1.53.0"></a>
## [v1.53.0] - 2019-01-18

- Reordered vars in count for database_nat_gateway route
- adding option to create a route to nat gateway in database subnets


<a name="v1.52.0"></a>
## [v1.52.0] - 2019-01-17

- Added SSM and EC2 VPC endpoints (fixes [#195](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/195), [#194](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/194))


<a name="v1.51.0"></a>
## [v1.51.0] - 2019-01-10

- Added possibility to control creation of elasticache and redshift subnet groups


<a name="v1.50.0"></a>
## [v1.50.0] - 2018-12-27

- Added azs to outputs which is an argument


<a name="v1.49.0"></a>
## [v1.49.0] - 2018-12-12

- Reverted complete-example
- Added IGW route for DB subnets (based on [#179](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/179))


<a name="v1.48.0"></a>
## [v1.48.0] - 2018-12-11

- Updated pre-commit version with new terraform-docs script


<a name="v1.47.0"></a>
## [v1.47.0] - 2018-12-11

- Fix for the error: module.vpc.aws_redshift_subnet_group.redshift: only lowercase alphanumeric characters and hyphens allowed in name


<a name="v1.46.0"></a>
## [v1.46.0] - 2018-10-06

- Fixed [#177](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/177) - public_subnets should not always be validated


<a name="v1.45.0"></a>
## [v1.45.0] - 2018-10-01

- Updated README.md after merge
- Added amazon_side_asn to vpn_gateway ([#159](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/159))


<a name="v1.44.0"></a>
## [v1.44.0] - 2018-09-18

- Reordering tag merging ([#148](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/148))


<a name="v1.43.2"></a>
## [v1.43.2] - 2018-09-17

- Updated link to cloudcraft


<a name="v1.43.1"></a>
## [v1.43.1] - 2018-09-17

- Updated link to cloudcraft


<a name="v1.43.0"></a>
## [v1.43.0] - 2018-09-16

- Removed comments starting from # to fix README
- Added cloudcraft.co as a sponsor for this module
- Added cloudcraft.co as a sponsor for this module


<a name="v1.42.0"></a>
## [v1.42.0] - 2018-09-14

- add vars for custom subnet and route table names ([#168](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/168))


<a name="v1.41.0"></a>
## [v1.41.0] - 2018-09-04

- Add secondary CIDR block support ([#163](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/163))


<a name="v1.40.0"></a>
## [v1.40.0] - 2018-08-19

- Removed IPv6 from outputs (fixed [#157](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/157)) ([#158](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/158))


<a name="v1.39.0"></a>
## [v1.39.0] - 2018-08-19

- Add minimum support for IPv6 to VPC ([#156](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/156))


<a name="v1.38.0"></a>
## [v1.38.0] - 2018-08-18

- Provide separate route tables for db/elasticache/redshift ([#155](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/155))
- Fixing typo overriden -> overridden ([#150](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/150))


<a name="v1.37.0"></a>
## [v1.37.0] - 2018-06-22

- Removed obsolete default_route_table_tags (fixed [#146](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/146))


<a name="v1.36.0"></a>
## [v1.36.0] - 2018-06-20

- Allow tags override for all resources (fix for [#138](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/138)) ([#145](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/145))


<a name="v1.35.0"></a>
## [v1.35.0] - 2018-06-20

- Updated README after [#141](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/141)
- Add `nat_gateway_tags` input ([#141](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/141))


<a name="v1.34.0"></a>
## [v1.34.0] - 2018-06-05

- Fixed creation of aws_vpc_endpoint_route_table_association when intra_subnets are not set (fixes 137)


<a name="v1.33.0"></a>
## [v1.33.0] - 2018-06-04

- Added missing route_table for intra_subnets, and prepare the release
- Adding "intra subnets" as a class ([#135](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/135))


<a name="v1.32.0"></a>
## [v1.32.0] - 2018-05-24

- Prepared release, updated README a bit
- Fix [#117](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/117) - Add `one_nat_gateway_per_az` functionality ([#129](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/129))


<a name="v1.31.0"></a>
## [v1.31.0] - 2018-05-16

- Added pre-commit hook to autogenerate terraform-docs ([#127](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/127))


<a name="v1.30.0"></a>
## [v1.30.0] - 2018-04-09

- Fixed formatting
- Added longer timeouts for aws_route create ([#113](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/113))


<a name="v1.29.0"></a>
## [v1.29.0] - 2018-04-05

- Creates a single private route table when single_nat_gateway is true ([#83](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/83))


<a name="v1.28.0"></a>
## [v1.28.0] - 2018-04-05

- Ensures the correct number of S3 and DDB VPC Endpoint associations ([#90](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/90))


<a name="v1.27.0"></a>
## [v1.27.0] - 2018-04-05

- Removed aws_default_route_table and aws_main_route_table_association, added potentially failed example ([#111](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/111))


<a name="v1.26.0"></a>
## [v1.26.0] - 2018-03-06

- Added default CIDR block as 0.0.0.0/0 ([#93](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/93))


<a name="v1.25.0"></a>
## [v1.25.0] - 2018-03-02

- Fixed complete example
- Make terraform recognize lists when uring variables ([#92](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/92))


<a name="v1.24.0-pre"></a>
## [v1.24.0-pre] - 2018-03-01

- Fixed description
- Fixed aws_vpn_gateway_route_propagation for default route table


<a name="v1.23.0"></a>
## [v1.23.0] - 2018-02-10

- Extended aws_vpn_gateway use case. ([#67](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/67))


<a name="v1.22.1"></a>
## [v1.22.1] - 2018-02-10

- Removed classiclink from outputs because it is not present in recent regions ([#78](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/78))


<a name="v1.22.0"></a>
## [v1.22.0] - 2018-02-09

- Added support for default VPC resource ([#75](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/75))


<a name="v1.21.0"></a>
## [v1.21.0] - 2018-02-09

- Added possibility to create VPC conditionally ([#74](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/74))


<a name="v1.20.0"></a>
## [v1.20.0] - 2018-02-09

- Manage Default Route Table under Terraform ([#69](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/69))


<a name="v1.19.0"></a>
## [v1.19.0] - 2018-02-09

- Only create one public route association for s3 endpoint ([#73](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/73))


<a name="v1.18.0"></a>
## [v1.18.0] - 2018-02-05

- Adding tests for vpc, subnets, and route tables ([#31](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/31))
- Improve documentation about the usage of external NAT gateway IPs ([#66](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/66))


<a name="v1.17.0"></a>
## [v1.17.0] - 2018-01-21

- Issue [#58](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/58): Add ElastiCache subnet group name output. ([#60](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/60))


<a name="v1.16.0"></a>
## [v1.16.0] - 2018-01-21

- Terraform fmt
- Issue [#56](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/56): Added tags for elastic ips ([#61](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/61))


<a name="v1.15.0"></a>
## [v1.15.0] - 2018-01-19

- Lowercase database subnet group name ([#57](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/57))


<a name="v1.14.0"></a>
## [v1.14.0] - 2018-01-11

- Add Redshift subnets ([#54](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/54))


<a name="v1.13.0"></a>
## [v1.13.0] - 2018-01-03

- Ignore changes to propagating_vgws of private routing table ([#50](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/50))


<a name="v1.12.0"></a>
## [v1.12.0] - 2017-12-12

- Downgraded require_version from 0.10.13 to 0.10.3 ([#48](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/48))


<a name="v1.11.0"></a>
## [v1.11.0] - 2017-12-11

- Added fix for issue when no private subnets are defined ([#47](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/47))


<a name="v1.10.0"></a>
## [v1.10.0] - 2017-12-11

- Fixing edge case when VPC is not symmetrical with few private subnets ([#45](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/45))


<a name="v1.9.1"></a>
## [v1.9.1] - 2017-12-07

- Minor fix in README


<a name="v1.9.0"></a>
## [v1.9.0] - 2017-12-07

- Allow passing in EIPs for the NAT Gateways ([#38](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/38))


<a name="v1.8.0"></a>
## [v1.8.0] - 2017-12-06

- change conditional private routes ([#36](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/36))


<a name="v1.7.0"></a>
## [v1.7.0] - 2017-12-06

- Add extra tags for DHCP option set ([#42](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/42))
- Add "default_route_table_id" to outputs ([#41](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/41))


<a name="v1.6.0"></a>
## [v1.6.0] - 2017-12-06

- Add support for additional tags on VPC ([#43](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/43))
- Reverted bad merge, fixed [#33](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/33)
- Set enable_dns_support=true by default


<a name="v1.4.1"></a>
## [v1.4.1] - 2017-11-23

- Reverted bad merge, fixed [#33](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/33)


<a name="v1.5.1"></a>
## [v1.5.1] - 2017-11-23



<a name="v1.5.0"></a>
## [v1.5.0] - 2017-11-23

- Reverted bad merge, fixed [#33](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/33)
- Set enable_dns_support=true by default
- Updated descriptions for DNS variables (closes [#14](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/14))


<a name="v1.4.0"></a>
## [v1.4.0] - 2017-11-22

- Add version requirements in README.md (fixes [#32](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/32))
- Add version requirements in README.md


<a name="v1.3.0"></a>
## [v1.3.0] - 2017-11-16

- make sure outputs are always valid ([#29](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/29))
- Add tags to the aws_vpc_dhcp_options resource ([#30](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/30))


<a name="v1.2.0"></a>
## [v1.2.0] - 2017-11-11

- Add support for DHCP options set ([#20](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/20))


<a name="v1.1.0"></a>
## [v1.1.0] - 2017-11-11

- [#22](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/22) add vpn gateway feature ([#24](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/24))
- Add cidr_block outputs to public and private subnets ([#19](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/19))
- Add AZ to natgateway name


<a name="v1.0.4"></a>
## [v1.0.4] - 2017-10-20

- NAT gateway should be tagged too.


<a name="v1.0.3"></a>
## [v1.0.3] - 2017-10-12

- Make aws_vpc_endpoint_service conditional
- Improve variable descriptions


<a name="v1.0.2"></a>
## [v1.0.2] - 2017-09-27

- disable dynamodb data source when not needed


<a name="v1.0.1"></a>
## [v1.0.1] - 2017-09-26

- Updated link in README
- Allow the user to define custom tags for route tables


<a name="v1.0.0"></a>
## v1.0.0 - 2017-09-12

- Updated README
- Updated README
- Aded examples and updated names
- Added descriptions, applied fmt
- Removed parts of readme
- Initial commit
- Initial commit


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.11.0...HEAD
[v3.11.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.10.0...v3.11.0
[v3.10.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.9.0...v3.10.0
[v3.9.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.8.0...v3.9.0
[v3.8.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.7.0...v3.8.0
[v3.7.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.6.0...v3.7.0
[v3.6.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.5.0...v3.6.0
[v3.5.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.4.0...v3.5.0
[v3.4.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.3.0...v3.4.0
[v3.3.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.2.0...v3.3.0
[v3.2.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.1.0...v3.2.0
[v3.1.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v3.0.0...v3.1.0
[v3.0.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.78.0...v3.0.0
[v2.78.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.77.0...v2.78.0
[v2.77.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.76.0...v2.77.0
[v2.76.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.75.0...v2.76.0
[v2.75.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.74.0...v2.75.0
[v2.74.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.73.0...v2.74.0
[v2.73.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.72.0...v2.73.0
[v2.72.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.71.0...v2.72.0
[v2.71.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.73.0...v2.71.0
[v1.73.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.70.0...v1.73.0
[v2.70.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.69.0...v2.70.0
[v2.69.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.68.0...v2.69.0
[v2.68.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.67.0...v2.68.0
[v2.67.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.66.0...v2.67.0
[v2.66.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.65.0...v2.66.0
[v2.65.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.64.0...v2.65.0
[v2.64.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.63.0...v2.64.0
[v2.63.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.62.0...v2.63.0
[v2.62.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.61.0...v2.62.0
[v2.61.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.60.0...v2.61.0
[v2.60.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.59.0...v2.60.0
[v2.59.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.58.0...v2.59.0
[v2.58.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.57.0...v2.58.0
[v2.57.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.56.0...v2.57.0
[v2.56.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.55.0...v2.56.0
[v2.55.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.54.0...v2.55.0
[v2.54.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.53.0...v2.54.0
[v2.53.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.52.0...v2.53.0
[v2.52.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.51.0...v2.52.0
[v2.51.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.50.0...v2.51.0
[v2.50.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.49.0...v2.50.0
[v2.49.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.48.0...v2.49.0
[v2.48.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.47.0...v2.48.0
[v2.47.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.46.0...v2.47.0
[v2.46.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.45.0...v2.46.0
[v2.45.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.44.0...v2.45.0
[v2.44.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.43.0...v2.44.0
[v2.43.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.42.0...v2.43.0
[v2.42.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.41.0...v2.42.0
[v2.41.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.40.0...v2.41.0
[v2.40.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.39.0...v2.40.0
[v2.39.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.38.0...v2.39.0
[v2.38.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.37.0...v2.38.0
[v2.37.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.36.0...v2.37.0
[v2.36.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.35.0...v2.36.0
[v2.35.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.34.0...v2.35.0
[v2.34.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.33.0...v2.34.0
[v2.33.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.32.0...v2.33.0
[v2.32.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.31.0...v2.32.0
[v2.31.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.30.0...v2.31.0
[v2.30.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.29.0...v2.30.0
[v2.29.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.28.0...v2.29.0
[v2.28.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.27.0...v2.28.0
[v2.27.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.26.0...v2.27.0
[v2.26.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.25.0...v2.26.0
[v2.25.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.24.0...v2.25.0
[v2.24.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.23.0...v2.24.0
[v2.23.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.22.0...v2.23.0
[v2.22.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.21.0...v2.22.0
[v2.21.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.20.0...v2.21.0
[v2.20.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.19.0...v2.20.0
[v2.19.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.18.0...v2.19.0
[v2.18.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.72.0...v2.18.0
[v1.72.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.17.0...v1.72.0
[v2.17.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.16.0...v2.17.0
[v2.16.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.15.0...v2.16.0
[v2.15.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.71.0...v2.15.0
[v1.71.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.14.0...v1.71.0
[v2.14.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.13.0...v2.14.0
[v2.13.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.70.0...v2.13.0
[v1.70.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.69.0...v1.70.0
[v1.69.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.68.0...v1.69.0
[v1.68.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.12.0...v1.68.0
[v2.12.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.11.0...v2.12.0
[v2.11.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.10.0...v2.11.0
[v2.10.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.9.0...v2.10.0
[v2.9.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.8.0...v2.9.0
[v2.8.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.7.0...v2.8.0
[v2.7.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.6.0...v2.7.0
[v2.6.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.67.0...v2.6.0
[v1.67.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.5.0...v1.67.0
[v2.5.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.4.0...v2.5.0
[v2.4.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.3.0...v2.4.0
[v2.3.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.2.0...v2.3.0
[v2.2.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.1.0...v2.2.0
[v2.1.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v2.0.0...v2.1.0
[v2.0.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.66.0...v2.0.0
[v1.66.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.65.0...v1.66.0
[v1.65.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.64.0...v1.65.0
[v1.64.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.63.0...v1.64.0
[v1.63.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.62.0...v1.63.0
[v1.62.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.61.0...v1.62.0
[v1.61.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.60.0...v1.61.0
[v1.60.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.59.0...v1.60.0
[v1.59.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.58.0...v1.59.0
[v1.58.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.57.0...v1.58.0
[v1.57.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.56.0...v1.57.0
[v1.56.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.55.0...v1.56.0
[v1.55.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.54.0...v1.55.0
[v1.54.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.53.0...v1.54.0
[v1.53.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.52.0...v1.53.0
[v1.52.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.51.0...v1.52.0
[v1.51.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.50.0...v1.51.0
[v1.50.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.49.0...v1.50.0
[v1.49.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.48.0...v1.49.0
[v1.48.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.47.0...v1.48.0
[v1.47.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.46.0...v1.47.0
[v1.46.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.45.0...v1.46.0
[v1.45.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.44.0...v1.45.0
[v1.44.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.43.2...v1.44.0
[v1.43.2]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.43.1...v1.43.2
[v1.43.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.43.0...v1.43.1
[v1.43.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.42.0...v1.43.0
[v1.42.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.41.0...v1.42.0
[v1.41.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.40.0...v1.41.0
[v1.40.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.39.0...v1.40.0
[v1.39.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.38.0...v1.39.0
[v1.38.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.37.0...v1.38.0
[v1.37.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.36.0...v1.37.0
[v1.36.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.35.0...v1.36.0
[v1.35.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.34.0...v1.35.0
[v1.34.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.33.0...v1.34.0
[v1.33.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.32.0...v1.33.0
[v1.32.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.31.0...v1.32.0
[v1.31.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.30.0...v1.31.0
[v1.30.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.29.0...v1.30.0
[v1.29.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.28.0...v1.29.0
[v1.28.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.27.0...v1.28.0
[v1.27.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.26.0...v1.27.0
[v1.26.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.25.0...v1.26.0
[v1.25.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.24.0-pre...v1.25.0
[v1.24.0-pre]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.23.0...v1.24.0-pre
[v1.23.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.22.1...v1.23.0
[v1.22.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.22.0...v1.22.1
[v1.22.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.21.0...v1.22.0
[v1.21.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.20.0...v1.21.0
[v1.20.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.19.0...v1.20.0
[v1.19.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.18.0...v1.19.0
[v1.18.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.17.0...v1.18.0
[v1.17.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.16.0...v1.17.0
[v1.16.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.15.0...v1.16.0
[v1.15.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.14.0...v1.15.0
[v1.14.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.13.0...v1.14.0
[v1.13.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.12.0...v1.13.0
[v1.12.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.11.0...v1.12.0
[v1.11.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.10.0...v1.11.0
[v1.10.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.9.1...v1.10.0
[v1.9.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.9.0...v1.9.1
[v1.9.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.8.0...v1.9.0
[v1.8.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.7.0...v1.8.0
[v1.7.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.6.0...v1.7.0
[v1.6.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.4.1...v1.6.0
[v1.4.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.5.1...v1.4.1
[v1.5.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.5.0...v1.5.1
[v1.5.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.4.0...v1.5.0
[v1.4.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.0.4...v1.1.0
[v1.0.4]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.0.3...v1.0.4
[v1.0.3]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.0.2...v1.0.3
[v1.0.2]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.0.1...v1.0.2
[v1.0.1]: https://github.com/terraform-aws-modules/terraform-aws-vpc/compare/v1.0.0...v1.0.1
