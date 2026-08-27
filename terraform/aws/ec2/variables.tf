variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "control_subnet_id" {
  type = string
}

variable "worker_subnet_id" {
  type = string
}

variable "ssh_ingress_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "talos_ami_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "worker_count" {
  type    = number
  default = 0
}