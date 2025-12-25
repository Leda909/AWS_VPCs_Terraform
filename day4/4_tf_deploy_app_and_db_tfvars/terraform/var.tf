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

variable "app_sg_id" {
  type        = string
  description = "Security Group ID for App instance"
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

variable "mongodb_sg_id" {
  type        = string
  description = "Security Group ID for Mongo DB instance"
}