# create an ec2 instance
# where to create - provide cloud name
provider "aws" {
    # which region to use to create a resource/service
    region = "eu-west-1"
    # terraform will download all the required dependencies/plugins when you do
    # terraform init
}

# which service/resource
resource "aws_instance" "app_instance" {
    # which AMI ID 
    ami = var.app_id
    # what type of instance to launch
    instance_type = var.app_instance_type
    # key pair
    key_name = var.app_key_pair

    # please add a public ip to this instance
    associate_public_ip_address = true
    
    # add sg
    vpc_security_group_ids = [var.app_sg_id]
    # run user data script
    user_data = file("./app-deploy.sh")
    # name the service
    tags = {
        Name = "se-adel-terraform-app"
    }
}