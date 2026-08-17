terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after bootstrapping the state backend module once
  # (chicken-and-egg problem: the backend itself can't use remote state).
  # backend "s3" {
  #   bucket         = ""
  #   key            = "k0s-canary/terraform.tfstate"
  #   region         = ""
  #   dynamodb_table = ""
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  ssh_ingress_cidr = var.ssh_ingress_cidr

  instance_type = var.instance_type
  fcos_ami_id   = var.fcos_ami_id
  ssh_key_name  = var.ssh_key_name
  worker_count  = var.worker_count

  controlplane_ignition = data.local_file.controlplane_ignition.content
  worker_ignition       = data.local_file.worker_ignition.content
}

# Ignition JSON is generated from Butane YAML via a local-exec step
# (see butane/README.md). We just read the compiled output here.
data "local_file" "controlplane_ignition" {
  filename = "${path.module}/../butane/controlplane.ign"
}

data "local_file" "worker_ignition" {
  filename = "${path.module}/../butane/worker.ign"
}
