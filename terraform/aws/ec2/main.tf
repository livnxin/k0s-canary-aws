# --- Security group -------------------------------------------------------
# One shared SG for all k0s nodes. Rules are intentionally scoped tight:
# SSH only from your IP, k0s API (9443) and kubelet (10250) only between
# nodes in this SG, everything else outbound-only.

resource "aws_security_group" "k0s_nodes" {
  name_prefix = "${var.environment}-k0s-"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH - emergency access only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  ingress {
    description = "k0s / Kubernetes API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # Node-to-node traffic (kubelet, etcd if multi-controlplane later,
  # pod networking). Scoped to itself via self=true, not 0.0.0.0/0.
  ingress {
    description = "Inter-node cluster traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Inter-node UDP (VXLAN/wireguard overlay, depending on CNI)"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  # Demo app HTTP access so you can actually see the canary in a browser
  ingress {
    description = "Demo app HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-k0s-sg"
  }
}

# --- Control-plane node (always on) ----------------------------------------
# Runs k0s in single-node mode (controller+worker combined) by default,
# via k0sctl/systemd unit baked into the FCOS Ignition config.
# This alone can run the whole demo - workers below are optional extras.

resource "aws_instance" "controlplane" {
  ami                    = var.fcos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k0s_nodes.id]
  user_data              = var.controlplane_ignition

  # user_data_replace_on_change ensures a Butane/Ignition edit actually
  # re-provisions the node instead of silently no-op'ing, since Ignition
  # only runs once at first boot.
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 15 # well within the 30GB free-tier EBS allowance
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-controlplane"
    Role = "controlplane"
  }
}

# --- Optional worker nodes ---------------------------------------------
# count = 0 by default (see root variables.tf). Scale up temporarily
# only while actively demoing, then back to 0.

resource "aws_instance" "worker" {
  count = var.worker_count

  ami                    = var.fcos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k0s_nodes.id]
  user_data              = var.worker_ignition

  user_data_replace_on_change = true

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-worker-${count.index}"
    Role = "worker"
  }
}
