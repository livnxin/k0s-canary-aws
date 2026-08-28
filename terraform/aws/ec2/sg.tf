
locals {
  control_group_id = aws_security_group.talos_control_nodes.id
  worker_group_id  = aws_security_group.talos_worker_nodes.id
  cillium_group_id = aws_security_group.cillium_nodes.id
}

resource "aws_security_group" "talos_control_nodes" {
  name_prefix = "${var.environment}-talos-control"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-control-talos-sg"
  }
}

resource "aws_security_group" "talos_worker_nodes" {
  name_prefix = "${var.environment}-talos-worker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-worker-talos-sg"
  }
}

resource "aws_security_group" "cillium_nodes" {
  name_prefix = "${var.environment}-cillium"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-cillium-sg"
  }
}

## Control Plane Security Group ##

resource "aws_vpc_security_group_egress_rule" "egress_all" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}



resource "aws_vpc_security_group_ingress_rule" "kubelet" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 10250
  ip_protocol                  = "tcp"
  to_port                      = 10250
}

resource "aws_vpc_security_group_ingress_rule" "controller_manager" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 10257
  ip_protocol                  = "tcp"
  to_port                      = 10257
}

resource "aws_vpc_security_group_ingress_rule" "shceduler" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 10259
  ip_protocol                  = "tcp"
  to_port                      = 10259
}

resource "aws_vpc_security_group_ingress_rule" "apiserver-etcd" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 2379
  ip_protocol                  = "tcp"
  to_port                      = 2380
}

resource "aws_vpc_security_group_ingress_rule" "kubeprism" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 7445
  ip_protocol                  = "tcp"
  to_port                      = 7445
}

resource "aws_vpc_security_group_ingress_rule" "kube-apiserver_self" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 6443
  ip_protocol                  = "tcp"
  to_port                      = 6443
}

resource "aws_vpc_security_group_ingress_rule" "kube-apiserver" {
  security_group_id = local.control_group_id

  cidr_ipv4   = var.ssh_ingress_cidr
  from_port   = 6443
  ip_protocol = "tcp"
  to_port     = 6443
}

resource "aws_vpc_security_group_ingress_rule" "kube-apiserver6" {
  security_group_id = local.control_group_id

  cidr_ipv6   = var.ssh_ingress_cidr6
  from_port   = 6443
  ip_protocol = "tcp"
  to_port     = 6443
}

resource "aws_vpc_security_group_ingress_rule" "trustd" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = 50001
  ip_protocol                  = "tcp"
  to_port                      = 50001

  description = "Talos trustd service. SHould be open on control plane from workers. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

resource "aws_vpc_security_group_ingress_rule" "apid_self" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = 50000
  ip_protocol                  = "tcp"
  to_port                      = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

resource "aws_vpc_security_group_ingress_rule" "apid_master" {
  security_group_id = local.control_group_id

  cidr_ipv4   = var.ssh_ingress_cidr
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

resource "aws_vpc_security_group_ingress_rule" "apid_internal" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}



resource "aws_vpc_security_group_ingress_rule" "apid_auto" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "${aws_instance.controlplane.public_ip}/32"
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

resource "aws_vpc_security_group_ingress_rule" "apid_master6" {
  security_group_id = local.control_group_id

  cidr_ipv6   = var.ssh_ingress_cidr6
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}
## Worker Plane Security Group ##

## Cillium Security Group ##

resource "aws_vpc_security_group_ingress_rule" "cillium_healthcheck" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port   = 4240
  ip_protocol = "tcp"
  to_port     = 4240

  description = "Cillium Health Check. An alternative to ICMP 8/0"
}

resource "aws_vpc_security_group_ingress_rule" "cillium_vxlan" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port   = 8472
  ip_protocol = "udp"
  to_port     = 8472

  description = "Cillium VXLAN"
}

resource "aws_vpc_security_group_egress_rule" "cillium_healthcheck" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port   = 4240
  ip_protocol = "tcp"
  to_port     = 4240

  description = "Cillium Health Check. An alternative to ICMP 8/0"
}

resource "aws_vpc_security_group_egress_rule" "cillium_vxlan" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port   = 8472
  ip_protocol = "udp"
  to_port     = 8472

  description = "Cillium VXLAN"
}