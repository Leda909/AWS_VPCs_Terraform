variable "app_id" {
  type        = string
  description = "AMI ID for App instance"
  default     = "ami-0acd59b88fb09fe21"
}

variable "app_instance_type" {
  type        = string
  description = "EC2 instance type for node20 app deployment"
  default     = "t3.micro"
}

variable "app_key_pair" {
  type        = string
  description = "SSH Key Pair for App instance"
  default     = "se-adel-basic-key-pair"
}

variable "app_sg_id" {
  type        = string
  description = "Security Group ID for App instance"
  default     = "sg-067189220c8b55f45"
}


