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
  description = "EC2 instance type."
  type        = string
  default     = "c7i-flex.large"
}

variable "talos_ami_id" {
  description = "Talos AMI ID for the region. Default is v.1.13.7 amd64 for Singapore Region"
  type        = string
  default     = "ami-0993d3366ebd9fb78"
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair (for emergency console access; day-to-day management should go through the talosctl/kubectl API, not SSH)"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach nodes on port 22. Set this to YOUR_IP/32, never 0.0.0.0/0."
  type        = string
}

variable "ssh_ingress_cidr6" {
  description = "CIDR allowed to reach nodes on port 22. Set this to YOUR_IP/128, never 0.0.0.0/0."
  type        = string
}

variable "worker_count" {
  description = "Number of additional worker nodes beyond the single control-plane node. Keep at 0 unless actively demo due to budget cons"
  type        = number
  default     = 0

  # validation {
  #   condition     = var.worker_count <= 2
  #   error_message = "Keep worker_count at 2 or fewer to keep cost down"
  # }
}
