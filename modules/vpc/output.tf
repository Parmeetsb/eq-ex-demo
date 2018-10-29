/**
 * Outputs
 */

// The VPC ID
output "default_vpc" {
  value = "${aws_vpc.main.id}"
}

// The VPC CIDR
output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

// A comma-separated list of subnet IDs.
output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

// A list of subnet IDs.
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

// The default VPC security group ID.
output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

// The list of availability zones of the VPC.
output "availability_zones" {
  value = ["${aws_subnet.public.*.availability_zone}"]
}

// The private route table ID.
output "private_rtb_id" {
  value = "${aws_route_table.private.*.id}"
}

// The public route table ID.
output "public_rtb_id" {
  value = "${aws_route_table.public.id}"
}

output "nat_instance_id"{
  value = ["${aws_instance.nat_instance.id}"]
}

