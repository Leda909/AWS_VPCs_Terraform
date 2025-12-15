provider "aws" {
  region = "eu-west-1"
}

# --- 1. Networking Infrastructure (across multiple availibility zones for high availability) ---

# Virtual private cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidrs

  tags = {
    Name = "se-adel-terraform-2tier-vpc"
  }
}

# Public Subnets (multiple availibility zones)
resource "aws_subnet" "vpc_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = var.avz_public[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true         # instances launched here will get a public IP

  tags = {
    Name = "se-adel-terraform-2tier-public-subnet-${count.index + 1}"
  }
}

# Private Subnets (multiple availibility zones)
resource "aws_subnet" "vpc_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.avz_private[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "se-adel-terraform-2tier-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "se-adel-terraform-vpc-internet-gateway"
  }
}

# Public Route Table (Routes internet traffic via IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.rt_cidrs
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "se-adel-terraform-public-route-table"
  }
}

# Private Route Table (Routes internet traffic via NAT Instance)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  
  # The 'route' block is defined externally using aws_route.private_nat_route
  
  tags = {
    Name = "se-adel-terraform-private-route-table"
  }
}

# Data source to fetch the primary network interface ID of the NAT Instance
# This is the modern and correct way to reference an EC2 instance as a route target.
data "aws_network_interface" "nat_eni" {
  # This filter ensures we get the primary ENI attached to our NAT instance
  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.nat_instance.id]
  }
  depends_on = [aws_instance.nat_instance]
}

# FIX: Explicit route for Private Subnets (0.0.0.0/0 traffic to NAT Instance)
# Target is now set to 'network_interface_id' to resolve validation errors.
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = var.rt_cidrs
  network_interface_id   = data.aws_network_interface.nat_eni.id
  depends_on             = [aws_instance.nat_instance, data.aws_network_interface.nat_eni]
}


# Route Table Association: Public Subnets to Public Route Table
resource "aws_route_table_association" "public_subnet_asso_rt" {
  count          = length(aws_subnet.vpc_public_subnet)
  subnet_id      = aws_subnet.vpc_public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Route Table Association: Private Subnets to Private Route Table
resource "aws_route_table_association" "private_subnet_asso_rt" {
  count          = length(aws_subnet.vpc_private_subnet)
  subnet_id      = aws_subnet.vpc_private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# --- 2. Security Groups ---

# Security Group for the NAT Instance
resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-security-group"
  description = "Allows traffic to and from the NAT Instance"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: Allow SSH from defined CIDR block
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Ingress: Allow traffic from ALL PRIVATE subnets for outbound internet access
  ingress {
    description = "From Private Subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Egress: Allow all outbound traffic to the Internet Gateway
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "se-adel-terraform-nat-instance-sg"
  }
}

# Security Group for the Node App (ALB and EC2 instances in Public Tier)
resource "aws_security_group" "public_app_sg" {
  name        = "pubic-app-security-group"
  description = "Allow SSH and HTTP access from the internet and ALB"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: Allow SSH (Port 22) from defined CIDR block (0.0.0.0/0 as requested)
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Ingress: Allow HTTP (Port 80) from the ALB (Health Check and Traffic)
  ingress {
    description     = "HTTP Access from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Egress: Allow all outbound traffic (for MongoDB and internet access via NAT Instance)
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

# Security Group for ALB (Allows internet traffic to port 80)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allows inbound HTTP access to the Application Load Balancer"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "se-adel-terraform-alb-sg"
  }
}


# Security Group for MongoDB (Private Tier)
resource "aws_security_group" "private_mongo_sg" {
  name        = "se_adel_privet_subnet_mongodb_security_group"
  description = "Allow SSH and MongoDB connection via App SG"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: Allow SSH (Port 22) from defined CIDR block (0.0.0.0/0 as requested)
  ingress {
    description = "SSH access for MongoDB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Ingress: Allow MongoDB (27017) ONLY from the App's Security Group ID (SECURE LINK)
  ingress {
    description     = "MongoDB connection from App SG"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.public_app_sg.id]
  }

  # Egress: Allow all outbound traffic (traffic routed via NAT Instance)
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

# --- 3. Public Tier (ALB + ASG) ---

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "se-adel-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.vpc_public_subnet.*.id # Use all public subnets

  enable_deletion_protection = false

  tags = {
    Name = "se-adel-app-alb"
  }
}

# Target Group (used by the ALB to route requests and perform health checks)
resource "aws_lb_target_group" "app_tg" {
  name     = "se-adel-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "se-adel-app-tg"
  }
}

# ALB Listener (Listens on port 80 and forwards traffic to the Target Group)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Launch Template (Defines configuration for instances managed by ASG)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = var.app_id
  instance_type = var.app_instance_type
  key_name      = var.app_key_pair
  vpc_security_group_ids = [aws_security_group.public_app_sg.id]

  # User data to inject the database IP
  user_data = base64encode(templatefile("./app-deploy.sh.tpl", {
    db_host = aws_instance.mongodb_instance.private_ip
  }))

  # Ensure the MongoDB instance is created before the App instances start
  depends_on = [aws_instance.mongodb_instance]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "se-adel-asg-app-instance"
    }
  }
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  name                      = "se-adel-app-asg"
  vpc_zone_identifier       = aws_subnet.vpc_public_subnet.*.id # Deploy across all public subnets
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Health Check and Scaling Requirements
  min_size                  = 2
  desired_capacity          = 3
  max_size                  = 4
  health_check_type         = "ELB"
  health_check_grace_period = 300 # Wait 5 minutes before checking health after launch

  target_group_arns         = [aws_lb_target_group.app_tg.arn]

  # ASG Tag Syntax
  tag {
    key                 = "Name"
    value               = "se-adel-asg-managed-app"
    propagate_at_launch = true
  }
}

# --- 4. Private Tier (Single MongoDB Instance) ---

# MongoDB EC2 Instance (Private Subnet)
resource "aws_instance" "mongodb_instance" {
  ami                         = var.mongodb_id
  instance_type               = var.mongodb_instance_type
  key_name                    = var.mongodb_key_pair
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private_mongo_sg.id]
  # Place in the first private subnet for simplicity (no need for ASG here)
  subnet_id                   = aws_subnet.vpc_private_subnet[0].id

  tags = {
    Name = "se-adel-terraform-private-subnet-mongodb"
  }
}

# --- 5. NAT Instance (Workaround for EIP Limit) ---

# NAT Instance to handle outbound traffic from Private Subnets
# NOTE: Uses a dynamic public IP since EIP allocation is restricted.
resource "aws_instance" "nat_instance" {
  ami                         = var.app_id # Use a standard Amazon Linux AMI
  instance_type               = "t3.micro"
  key_name                    = var.app_key_pair
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  # Must be placed in a Public Subnet
  subnet_id                   = aws_subnet.vpc_public_subnet[0].id

  # CRITICAL: This disables the Source/Destination check required for a NAT instance
  source_dest_check = false 

  # User data to enable IP forwarding on the NAT Instance
  user_data = <<-EOF
              #!/bin/bash
              echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
              sysctl -p
              EOF

  tags = {
    Name = "se-adel-terraform-nat-instance"
  }
}


# --- 6. Outputs ---

# Data source to find all running EC2 instances managed by the ASG
# It uses the tag applied via the Launch Template: 'se-adel-asg-app-instance'
data "aws_instances" "app_public_ips_data" {
  filter {
    name   = "tag:Name"
    values = ["se-adel-asg-app-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.app_asg]
}

# Output ALB DNS Name (The recommended access point)
output "app_url" {
  description = "The URL for the highly available Node.js application (use this for traffic)"
  value       = aws_lb.app_alb.dns_name
}

# Output Public IPs of ASG instances (for debugging/SSH)
output "app_public_ips_for_ssh" {
  description = "Public IPs of instances managed by the ASG (these IPs are dynamic)"
  value       = data.aws_instances.app_public_ips_data.public_ips
}

# Output MongoDB IP
output "mongodb_private_ip" {
  description = "Private IP address of MongoDB instance (in subnet 1)"
  value       = aws_instance.mongodb_instance.private_ip
}