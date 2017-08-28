output "private_subnets" {
  desctiption = "List of IDs of private subnets"
  value       = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${aws_subnet.public.*.id}"]
}

output "database_subnets" {
  desctiption = "List of IDs of database subnets"
  value       = ["${aws_subnet.database.*.id}"]
}

output "database_subnet_group" {
  desctiption = "ID of database subnet group"
  value       = "${aws_db_subnet_group.database.id}"
}

output "elasticache_subnets" {
  desctiption = "List of IDs of elasticache subnets"

  value = ["${aws_subnet.elasticache.*.id}"]
}

output "elasticache_subnet_group" {
  desctiption = "ID of elasticache subnet group"

  value = "${aws_elasticache_subnet_group.elasticache.id}"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.mod.id}"
}

output "vpc_cidr_block" {
  desctiption = "The CIDR block of the VPC"

  value = "${aws_vpc.mod.cidr_block}"
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.public.*.id}"]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${aws_route_table.private.*.id}"]
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"

  value = "${aws_vpc.mod.default_security_group_id}"
}

output "nat_eips" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = ["${aws_eip.nateip.*.id}"]
}

output "nat_eips_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${aws_eip.nateip.*.public_ip}"]
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = ["${aws_nat_gateway.natgw.*.id}"]
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = "${aws_internet_gateway.mod.id}"
}
