variable "vpc_cidrs" {
  type        = string
  description = "VPC CIDR value"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of VPC Public Subnet CIDR values (3 or more for multi-AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of VPC Private Subnet CIDR values (3 or more for multi-AZ)"
}

variable "rt_cidrs" {
  type        = string
  description = "Route Table local CIDR value, typically 0.0.0.0/0"
  default     = "0.0.0.0/0"
}

variable "ssh_cidr_block" {
  type        = string
  description = "CIDR block allowed for SSH access (e.g., your public IP or 0.0.0.0/0 for open access)"
}

variable "avz_public" {
  type        = list(string)
  description = "List of Availability Zones for Public Subnets"
}

variable "avz_private" {
  type        = list(string)
  description = "List of Availability Zones for Private Subnets"
}

variable "mongodb_id" {
  type        = string
  description = "AMI ID for MongoDB instance"
}

variable "mongodb_instance_type" {
  type        = string
  description = "EC2 instance type for Mongo DB deployment"
}

variable "mongodb_key_pair" {
  type        = string
  description = "SSH Key Pair for Mongo DB instance"
}

variable "app_id" {
  type        = string
  description = "AMI ID for App instance"
}

variable "app_instance_type" {
  type        = string
  description = "EC2 instance type for node20 app deployment"
}

variable "app_key_pair" {
  type        = string
  description = "SSH Key Pair for App instance"
}