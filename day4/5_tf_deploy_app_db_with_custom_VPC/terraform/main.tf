# configure the cloud provider
provider "aws" {
    region = "eu-west-1"
}

# ------------- 1. Networking --------------

# virtual private cloud (VPC)
resource "aws_vpc" "main_vpc" {
 cidr_block = var.vpc_cidrs
 
 tags = {
   Name = "se-adel-terraform-2tier-vpc"
 }
}

# public subnet
resource "aws_subnet" "vpc_public_subnets" {
 vpc_id     = aws_vpc.main_vpc.id
 availability_zone = var.avz_public
 cidr_block = var.public_subnet_cidrs
 
 tags = {
   Name = "se-adel-terraform-2tier-public-subnet"
 }
}

# private subnet 
resource "aws_subnet" "vpc_private_subnets" {
 vpc_id     = aws_vpc.main_vpc.id
 availability_zone = var.avz_private
 cidr_block = var.private_subnet_cidrs
 
 tags = {
   Name = "se-adel-terraform-2tier-private-subnet"
 }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main_vpc.id
 
 tags = {
   Name = "se-adel-terraform-vpc-internet-gateway"
 }
}

# Route Table
resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main_vpc.id
 
 # Route all internet traffic (0.0.0.0/0) to the Internet Gateway
 route {
   cidr_block = var.rt_cidrs
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "se-adel-terraform-route-table"
 }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_asso_rt" {
 subnet_id      = aws_subnet.vpc_public_subnets.id
 route_table_id = aws_route_table.route_table.id
}

# ------- 2. Security Groups -------

# create Security Group for the Node App (Public Tier)
resource "aws_security_group" "public_app_sg"{
  name        = "pubic-app-security-group"
  description = "Allow SSH and HTTP access from the internet"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: Allow SSH (Port 22) from defined CIDR block
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Ingress: Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP Access for App"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all outbound traffic (needed to connect to MongoDB and the internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "se-adel-terraform-public-subnet-app-sg"
  }
}

# create Security Group for MongoDB (Private Tier)
resource "aws_security_group" "private_mongo_sg"{
 name        = "se_adel_privet_subnet_mongodb_security_group"
 description = "Allow SHH and MongoDB connection via pivate ip"
 vpc_id      = aws_vpc.main_vpc.id

# Ingress: Allow SSH (Port 22) from defined CIDR block
 ingress {
   description = "SSH access for MongoDB"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = [var.ssh_cidr_block]
 }

 # Ingress: Allow MongoDB (27017) ONLY from the App's Security Group ID (Secure link)
 ingress {
   description = "MongoDB connection from App SG"
   from_port   = 27017
   to_port     = 27017
   protocol    = "tcp"
   cidr_blocks = [var.mongodb_cidr_blocks]

   security_groups = [aws_security_group.public_app_sg.id]
 }

  # Egress: Allow all outbound traffic (needed for updates and external connections)
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "se-adel-terraform-mongodb-private-subnet-sg"
  }
}

# ------------- 3. EC2 Instances -------------

# MongoDB EC2 Instance (Private Subnet)
resource "aws_instance" "mongodb_instance" {
    ami                         = var.mongodb_id
    instance_type               = var.mongodb_instance_type
    key_name                    = var.mongodb_key_pair
    # no public ip for mongodb
    associate_public_ip_address = false
    # use created security group
    vpc_security_group_ids      = [aws_security_group.private_mongo_sg.id]
    # place in private subnet
    subnet_id                   = aws_subnet.vpc_private_subnets.id

    tags = {
        Name = "se-adel-terraform-private-subnet-mongodb"
    }
}

# Node App service/resource EC2 (Public Subnet)
resource "aws_instance" "app_instance" {
    ami = var.app_id
    instance_type = var.app_instance_type
    key_name = var.app_key_pair

    # add a public ip to this instance
    associate_public_ip_address = true

    # use created security group
    vpc_security_group_ids = [aws_security_group.public_app_sg.id]

    # place in public subnet
    subnet_id = aws_subnet.vpc_public_subnets.id

    # use templatefile() to inject DB IP dynamically
    user_data = templatefile("./app-deploy.sh.tpl", {
        db_host = aws_instance.mongodb_instance.private_ip
    })
    
    # ensure DB instance is created first
    depends_on = [aws_instance.mongodb_instance]
    
    tags = {
        Name = "se-adel-terraform-public-subnet-app"
    }
}

# ---------- 4. Outputs ----------

# Output MongoDB IP
output "mongodb_private_ip" {
    description = "Private IP address of MongoDB instance"
    value       = aws_instance.mongodb_instance.private_ip
}

# Output App IP
output "app_public_ip" {
    description = "Public IP address of the Node.js app instance"
    value       = aws_instance.app_instance.public_ip
}