output "vpc_id" {
  value = aws_vpc.this.id
}

output "control_subnet_id" {
  value = aws_subnet.control.id
}

output "worker_subnet_id" {
  value = aws_subnet.worker.id
}