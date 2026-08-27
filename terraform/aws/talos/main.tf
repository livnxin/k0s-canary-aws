terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
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
}



ephemeral "talos_client_configuration" "this" {
  cluster_name    = "example-cluster"
  machine_secrets = talos_machine_secrets.aws_machine_secret.machine_secrets
  nodes           = ["var.controlplane_ip"]
}

ephemeral "talos_machine_configuration" "this" {
  cluster_name     = "example-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://cluster.local:6443"
  machine_secrets  = talos_machine_secrets.aws_machine_secret.machine_secrets
}

data "talos_machine_configuration" "controller" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.aws_machine_secret.machine_secrets
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
  machine_type     = "worker"
  examples         = false
  docs             = false
  config_patches   = [for c in local.common_machine_configs : yamlencode(c)]
}