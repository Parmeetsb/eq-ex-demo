
provider "aws" {
  region     = "ap-southeast-1"
}


module "vpc" {
  source = "../modules/vpc"
  cidr = "10.0.0.0/16"
  name = "demo"
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  use_nat_instances="1"
  use_eip_with_nat_instances="1"
  nat_instance_ssh_key_name = "eq-ex-nat"
  nat_instance_type = "t2.micro"
}

output "vpc_id" {
  value = "${module.vpc.default_vpc}"
}







