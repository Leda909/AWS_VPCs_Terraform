# create an ec2 instance
# where to create - provide cloud name
provider "aws" {
    # which region to use to create a resource/service
    region = "eu-west-1"
    # terraform will download all the required dependencies/plugins when you do "terraform init"
}

# MongoDB EC2 Instance
resource "aws_instance" "mongodb_instance" {
    # id of mongodb
    ami                         = var.mongodb_id
    # type of mongodb
    instance_type               = var.mongodb_instance_type
    # key pair for mongodb
    key_name                    = var.mongodb_key_pair
    # assign public ip for mongodb
    associate_public_ip_address = true
    # sg for mongodb
    vpc_security_group_ids      = [var.mongodb_sg_id]
    
    tags = {
        Name = "se-adel-terraform-mongodb"
    }
}

# Node App service/resource
resource "aws_instance" "app_instance" {
    # which AMI ID 
    ami = var.app_id
    # what type of instance to launch
    instance_type = var.app_instance_type
    # key pair
    key_name = var.app_key_pair

    # please add a public ip to this instance
    associate_public_ip_address = true
    
    # add security group
    vpc_security_group_ids = [var.app_sg_id]

    # use templatefile() to inject DB IP dynamically
    user_data = templatefile("./app-deploy.sh.tpl", {
        db_host = aws_instance.mongodb_instance.public_ip
    })
    
    # Ensure DB instance is created first
    depends_on = [aws_instance.mongodb_instance]
    
    tags = {
        Name = "se-adel-terraform-app"
    }
}

# Output MongoDB IP
output "mongodb_public_ip" {
    description = "Public IP address of MongoDB instance"
    value       = aws_instance.mongodb_instance.public_ip
}

output "mongodb_private_ip" {
    description = "Private IP address of MongoDB instance"
    value       = aws_instance.mongodb_instance.private_ip
}

# Output App IP
output "app_public_ip" {
    description = "Public IP address of the Node.js app instance"
    value       = aws_instance.app_instance.public_ip
}