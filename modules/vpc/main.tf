/**
 * VPC
 */
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.name}" 
  }
}

/**
 * Gateways
 */

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}" 
  }
}

/**
 * Creating NAT instance.
 */
#This data source returns the newest Amazon NAT instance AMI
data "aws_ami" "nat_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}

resource "aws_eip" "nat" {
  # Create these only if:
  # NAT instances are used and Elastic IPs are used with them,
  # or if the NAT gateway service is used (NAT instances are not used).
  count = "${signum((var.use_nat_instances * var.use_eip_with_nat_instances) + (var.use_nat_instances == 0 ? 1 : 0)) * length(var.private_subnets)}"

  vpc = true
}

resource "aws_security_group" "nat_instances" {
  #count       = "${var.use_nat_instances}"
  name        = "nat"
  description = "Allow traffic from clients into NAT instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_instance" "nat_instance" {
  # Create these only if using NAT instances, vs. the NAT gateway service.
  #count             = "${(0 + var.use_nat_instances) * length(var.private_subnets)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.name}-nat-instance"
  }

  volume_tags {
    Name        = "${var.name}-${format("private-NAT", count.index+1)}"
  }

  key_name          = "${var.nat_instance_ssh_key_name}"
  ami               = "${data.aws_ami.nat_ami.id}"
  instance_type     = "${var.nat_instance_type}"
  source_dest_check = false

  # associate_public_ip_address is not used,,
  # as public subnets have map_public_ip_on_launch set to true.
  # Also, using associate_public_ip_address causes issues with
  # stopped NAT instances which do not use an Elastic IP.
  # - For more details: https://github.com/terraform-providers/terraform-provider-aws/issues/343
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.nat_instances.id}"]

  lifecycle {
    # Ignore changes to the NAT AMI data source.
    ignore_changes = ["ami"]
  }
}

resource "aws_eip_association" "nat_instance_eip" {
  # Create these only if using NAT instances, vs. the NAT gateway service.
  count = "${(0 + (var.use_nat_instances)) * length(var.private_subnets)}"

  #instance_id   = "${element(aws_instance.nat_instance.*.id, count.index)}"
  instance_id   = "${aws_instance.nat_instance.id}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
}

/**
 * Subnets.
 */

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.public_subnets)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-${format("public-%03d", count.index+1)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.private_subnets)}"

  tags {
    Name        = "${var.name}-${format("private-%03d", count.index+1)}"
  }
}

/**
 * Route tables
 */

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-public-001"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat_instance.id}"
  }

  tags {
    Name        = "${var.name}-${format("private-%03d", count.index+1)}"
  }
}

resource "aws_route" "private" {
  # Create this only if using the NAT gateway service, vs. NAT instances.
  #count                  = "${(1 - var.use_nat_instances) * length(compact(var.private_subnets))}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  destination_cidr_block = "0.0.0.0/0"

  #instance_id         = "${element(aws_instance.nat_instance.*.id, count.index)}"
  instance_id = "${aws_instance.nat_instance.id}"

  depends_on = ["aws_instance.nat_instance", "aws_route_table.private"]
}

/**
 * Route associations
 */
#
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
