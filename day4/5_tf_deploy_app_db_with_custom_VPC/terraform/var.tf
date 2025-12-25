# use this file to define the variables only its names and types

variable "vpc_cidrs" {
 type        = string
 description = "VPC CIDR value"
}

variable "public_subnet_cidrs" {
 type        = string
 description = "VPC Public Subnet CIDR value"
}
 
variable "private_subnet_cidrs" {
 type        = string
 description = "VPC Private Subnet CIDR value"
}

variable "rt_cidrs" {
 type        = string
 description = "Route Table local CIDR value"
}

variable "ssh_cidr_block" {
  type        = string
  description = "SSH CIDR value"
}

variable "mongodb_cidr_blocks" {
  type        = string
  description = "MongoDB allowed CIDR blocks"
}

variable "avz_public" {
  type        = string
  description = "Availability Zone for Public Subnet"
}

variable "avz_private" {
  type        = string
  description = "Availability Zone for Private Subnet"
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