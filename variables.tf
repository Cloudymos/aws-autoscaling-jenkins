variable "default_tags" {
  default     = {
 
     Environment = "Test"
     Owner       = "Bruno Olimpio"
     Project     = "POC_Terraform" 
}
  description = "Default Tags for Auto Scaling Group"
  type        = map(string)
}

variable "vpc_name" {
  default = "vpc"
}

variable "vpc_cidr" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = "10.0.0.0/16"
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default = ["10.0.10.0/24", "10.0.20.0/24","10.0.30.0/24"]
  type = list
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default = ["10.0.120.0/24", "10.0.150.0/24","10.0.180.0/24"]
  type = list
}

variable "nginx_ami" {
  description = "AMI pre configured with nginx"
  default = "ami-0be18df18ae5bb400"
}