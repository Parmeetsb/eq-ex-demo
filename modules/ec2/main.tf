
data "aws_vpc" "vpc" {
  tags {
      Name = "${var.name}"
  }
}

data "aws_subnet" "private" {
  tags {
    Name = "${var.name}-private-001"
  }
}

data "aws_subnet" "public" {
  tags {
    Name = "${var.name}-public-001"
  }
}


data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    
}

resource "aws_security_group" "public-instance" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

    egress {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }

  vpc_id="${data.aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-public-sg"
  }
}

resource "aws_security_group" "private-instance" {
  name = "vpc_test_db"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

    egress {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }

  vpc_id="${data.aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-private-sg"
  }
}


data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"
  vars {
    name = "${var.name}"
  }
}


resource "aws_instance" "public" {
  #  name = "${var.name}"
   ami  = "${data.aws_ami.ubuntu.id}"
   instance_type = "${var.instance_type}"
   key_name = "${var.key_name}"
   subnet_id = "${data.aws_subnet.public.id}"
   vpc_security_group_ids = ["${aws_security_group.public-instance.id}"]
   associate_public_ip_address = true
  #  user_data = "${data.template_file.user_data.rendered}"
   user_data = <<-EOF
                  #!/bin/bash
                  wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
                  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
                  sudo apt-get update -y
                  sudo apt-get install default-jdk jenkins  -y
                  sudo service jenkins restart

                  set +x
                  echo '**********************************************************'
                  echo '** Initial administration password to enter into browser:'
                  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
                  EOF

  tags {
    Name = "${var.name}-public-instance"
  }
}


resource "aws_instance" "private" {
  #  name = "${var.name}"
   ami  = "${data.aws_ami.ubuntu.id}"
   instance_type = "${var.instance_type}"
   key_name = "${var.key_name}"
   subnet_id = "${data.aws_subnet.private.id}"
   vpc_security_group_ids = ["${aws_security_group.private-instance.id}"]

  tags {
    Name = "${var.name}-private-instance"
  }
}