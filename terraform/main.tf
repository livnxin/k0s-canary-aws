terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
  }


}

provider "aws" {
  region = var.aws_region
}

module "talos" {
  source = "./aws/talos"

}

module "vpc" {
  source = "./aws/vpc"

  aws_vpc_cidr = var.aws_vpc_cidr
  environment  = var.aws_environment
}

module "ec2" {
  source = "./aws/ec2"

  environment       = var.aws_environment
  vpc_id            = module.vpc.vpc_id
  control_subnet_id = module.vpc.control_subnet_id
  worker_subnet_id  = module.vpc.worker_subnet_id
  ssh_ingress_cidr  = var.ssh_ingress_cidr

  instance_type = var.aws_instance_type
  talos_ami_id  = var.talos_ami_id
  ssh_key_name  = var.ssh_key_name
  worker_count  = var.worker_count

  depends_on = [module.vpc]
}

# Ignition JSON is generated from Butane YAML via a local-exec step
# (see butane/README.md). We just read the compiled output here.
data "local_file" "controlplane_ignition" {
  filename = "${path.module}/../butane/controlplane.ign"
}

data "local_file" "worker_ignition" {
  filename = "${path.module}/../butane/worker.ign"
}
