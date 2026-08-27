output "controlplane_public_ip" {
  value = aws_instance.controlplane.public_ip
}

output "worker_public_ips" {
  value = aws_instance.worker[*].private_ip
}
