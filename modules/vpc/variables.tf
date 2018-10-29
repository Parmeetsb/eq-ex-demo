variable "cidr" {
  description = "The CIDR block for the VPC."
  #default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = "list"

  #default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

# variable "ALB_subnets" {
#   description = "List of RDS subnets"
#   type        = "list"
# }

variable "private_subnets" {
  description = "List of private subnets"
  type        = "list"

  #default     = ["10.0.2.0/24", "10.0.3.0/24"]
}



variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
  # default     = ["ap-south-1a", "ap-south-1b"]
}

variable "name" {
  description = "Name tag, e.g stack"
  # default     = "stack"
}

variable "use_nat_instances" {
  description = "If true, use EC2 NAT instances instead of the AWS NAT gateway service. Select 1 for True else 0 for False"

  #default     = false
}

variable "nat_instance_type" {
  description = "Only if use_nat_instances is true, which EC2 instance type to use for the NAT instances."
  # default     = "t2.nano"
}

variable "nat_instance_ssh_key_name" {
  description = "Only if use_nat_instance is true, the optional SSH key-pair to assign to NAT instances."
 

}

variable "use_eip_with_nat_instances" {
  description = "Only if use_nat_instances is true, whether to assign Elastic IPs to the NAT instances. IF this is set to false, NAT instances use dynamically assigned IPs."

  #default     = false
}




