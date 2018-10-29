# eq-ex -demo
First problem statement solution


This is a Terraform Infrastructure as a code sample to:
 - Create a VPC with all components
 - Launch a instance in public subnet with Jenkins and ansible installed in it.
 - Launch a instance with private subnet working as a client.

**Prerequisites**: 
 - AWS account.
 - IAM user with access and secret key with required permissions
 - Terraform installed.

**Steps to launch infrastructure**:
 - cd vpc/ and replace the desired values in main.tf
 - Once VPC is launched, cd instances/ and replace the desired changes in main.tf file.
