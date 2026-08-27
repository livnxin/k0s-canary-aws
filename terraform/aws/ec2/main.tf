resource "aws_instance" "controlplane" {
  ami                    = var.talos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.control_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.talos_control_nodes.id]
  user_data              = var.controlplane_ignition

  # user_data_replace_on_change ensures a Butane/Ignition edit actually
  # re-provisions the node instead of silently no-op'ing, since Ignition
  # only runs once at first boot.
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20 # well within the 30GB free-tier EBS allowance
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

  ami                    = var.talos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.worker_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k0s_nodes.id]
  user_data              = var.worker_ignition

  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-worker-${count.index}"
    Role = "worker"
  }
}
