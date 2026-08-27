terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0-alpha.3"
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

resource "talos_machine_secrets" "aws_machine_secret" {
  talos_version = "v1.13.7"
}



data "talos_client_configuration" "this" {
  cluster_name    = var.cluster_name
  nodes           = [var.controlplane_ip]
  endpoints = [var.controlplane_ip]
  client_configuration = talos_machine_secrets.aws_machine_secret.client_configuration
}

data "talos_machine_configuration" "control" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.aws_machine_secret.machine_secrets

  talos_version = "v1.13.7"
  machine_type     = "controlplane"
  examples         = false
  docs             = false
  config_patches = concat(
    [for c in local.common_machine_configs : yamlencode(c)],
    [
      // see https://docs.siderolabs.com/talos/v1.13/networking/advanced/vip
      // see https://docs.siderolabs.com/talos/v1.13/reference/configuration/network/layer2vipconfig
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "Layer2VIPConfig"
        link       = "eth0"
        name       = var.controlplane_ip
      }),
      yamlencode({
        cluster = {
          inlineManifests = [
            {
              name = "cilium"
              contents = join("---\n", [
                data.helm_template.cilium.manifest
              ])
            }
          ],
        },
    })],
  )
}

// see https://registry.terraform.io/providers/siderolabs/talos/0.11.0/docs/data-sources/machine_configuration
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.aws_machine_secret.machine_secrets
  talos_version = "v1.13.7"
  machine_type     = "worker"
  examples         = false
  docs             = false
  config_patches   = [for c in local.common_machine_configs : yamlencode(c)]
}



resource "talos_machine_configuration_apply" "control" {
  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control.machine_configuration
  node                        = var.controlplane_ip

  endpoint = var.controlplane_ip
}



resource "talos_machine_bootstrap" "control" {
  depends_on = [
    talos_machine_configuration_apply.control
  ]
  endpoint = var.controlplane_ip
  node                 = var.controlplane_ip
  client_configuration = data.talos_client_configuration.this.client_configuration
}