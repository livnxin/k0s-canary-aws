variable "aws_region" {
  description = "AWS region to deploy into. Pick one close to you for lower latency."
  type        = string
  default     = "ap-southeast-1" # Singapore
}

variable "aws_environment" {
  description = "Short name used to tag/prefix all resources"
  type        = string
  default     = "aws-demo"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.27.0.0/16"
}

variable "aws_instance_type" {
  description = "EC2 instance type. MUST stay t2.micro or t3.micro to remain free-tier eligible."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Only t2.micro or t3.micro are free-tier eligible. Do not change this without checking your AWS Billing Free Tier usage page first."
  }
}

variable "talos_ami_id" {
  description = "Talos AMI ID for the region. Default is v.1.13.9 arm64 for Singapore Region"
  type        = string
  default     = "ami-0e652a0ca53b17bc6"
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair (for emergency console access; day-to-day management should go through the k0s/kubectl API, not SSH)"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach nodes on port 22. Set this to YOUR_IP/32, never 0.0.0.0/0."
  type        = string
}

variable "worker_count" {
  description = "Number of additional worker nodes beyond the single control-plane node. Keep at 0 unless actively demoing - each additional t3.micro running 24/7 eats into the shared 750 hrs/month free-tier pool."
  type        = number
  default     = 2

  # validation {
  #   condition     = var.worker_count <= 2
  #   error_message = "Keep worker_count at 2 or fewer to keep cost down"
  # }
}
