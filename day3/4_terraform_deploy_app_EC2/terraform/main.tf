# Create an EC2 instance

# Provider block - What providers do we need to interact with?

# Configure the AWS Provider
# We will use aws
provider "aws" {
  region = "eu-west-1"

  # Terraform will automatically use the AWS credentials and 
  # download att the required dependencies/plugins when you run "terraform init"
}

# Which Resource/Service block we want to create?
# Add "name" instance in script so it can be referenced later
resource "aws_instance" "basic_instance" {
  # AMI ID for Amazon Linux 2 in us-east-1, SSD Volume Type
  # Just copy from AWS Console from one of the existing EC2 instances
  ami           = "ami-0acd59b88fb09fe21"

  # What instance type do we want?
  instance_type = "t3.micro"

  # We want auto-assingned public IP
  associate_public_ip_address = true

  # Name instance on aws
  tags = {
    Name = "se-adel-test-tf-instance"
  } 
}