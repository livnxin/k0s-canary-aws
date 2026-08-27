variable "controlplane_ip" {
  type = string
}

variable "worker_ips" {
}

variable "cluster_name" {
  default = "aws-cluster"
}

output "talos_client" {
  value = data.talos_client_configuration.this.talos_config
}