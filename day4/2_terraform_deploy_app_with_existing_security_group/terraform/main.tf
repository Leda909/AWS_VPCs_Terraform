provider "aws" {
  region = "eu-west-1"
}

# ---------------- To add existing security group with default VPC and ----------------

# data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# data source to get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# data source to reference the EXISTING node.js App security group
data "aws_security_group" "existing_nodejs_sg" {
  id = "sg-067189220c8b55f45"
}

# ---------------- Create EC2 for lanch App home page ----------------

# resource/service block to create an EC2 instance
resource "aws_instance" "basic_instance" {
  # AMI ID for Amazon Linux 2 in eu-west-1
  # Just copy from AWS Console from one of the existing EC2 instances
  ami           = "ami-0acd59b88fb09fe21"

  # instance type
  instance_type = "t3.micro"

  # use the first available subnet in default VPC
  subnet_id = data.aws_subnets.default.ids[0]

  # attach the EXISTING security group
  vpc_security_group_ids = [data.aws_security_group.existing_nodejs_sg.id]

  # auto-assingned public IP
  associate_public_ip_address = true

  # run user data script on instance launch
  user_data = file("./app_user_data.sh")

  # add a key pair for SSH access
  key_name = "se-adel-basic-key-pair"  # just replace with your existing one

  # Name instance on aws
  tags = {
    Name = "se-adel-test-tf-nodeApp-instance"
  }  
}

# ----------------- Some OUTPUT to confirm the deployment details -----------------

# output the public IP address
output "instance_public_ip" {
  description = "Public IP address of the Node.js app instance"
  value       = aws_instance.basic_instance.public_ip
}

# output the public DNS
output "instance_public_dns" {
  description = "Public DNS of the Node.js app instance"
  value       = aws_instance.basic_instance.public_dns
}

# Output the security group ID (to verify it's using the right one)
output "security_group_id" {
  description = "ID of the security group being used"
  value       = data.aws_security_group.existing_nodejs_sg.id
}

# Output security group name for verification
output "security_group_name" {
  description = "Name of the security group being used"
  value       = data.aws_security_group.existing_nodejs_sg.name
}