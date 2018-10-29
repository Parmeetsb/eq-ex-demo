provider "aws" {
  access_key = "AKIAIA2AFUXTAQJVCTYA"
  secret_key = "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"
  region     = "ap-southeast-1"
}


module "ec2" {
  source = "../modules/ec2"
  name = "demo"
  instance_type = "t2.micro"
  # ami = ""
  key_name = "eq-ex-ec2"
}