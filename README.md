# eq-ex-demo
First problem statement solution


This is a Terraform Infrastructure as a code sample to:
    1. Create a VPC with all components
    2. Launch a instance in public subnet with Jenkins and ansible installed in it.
    3. Launch a instance with private subnet working as a client.

Prerequisites: 
    1. AWS account.
    2. IAM user with access and secret key with required permissions
    3. Terraform installed.

Steps to launch infrastructure:
    1. cd vpc/ and replace the desired values in main.tf
    2. Once VPC is launched, cd instances/ and replace the desired changes in main.tf file.

