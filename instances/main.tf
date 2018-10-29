provider "aws" {
  region     = "ap-southeast-1"
}


module "ec2" {
  source = "../modules/ec2"
  name = "demo"
  instance_type = "t2.micro"
  # ami = ""
  key_name = "eq-ex-ec2"
}