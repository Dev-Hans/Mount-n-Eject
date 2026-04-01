# Configure the AWS provider to use the specified region.
provider "aws" {
  region = var.aws_region
}

# Find the latest free-tier eligible Ubuntu 20.04 AMI in the specified region.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate a temporary RSA key for provisioning the EC2 instance.
# This key is used only for the setup and is destroyed afterward.
resource "tls_private_key" "builder_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS to create a key pair.
resource "aws_key_pair" "builder_key" {
  key_name   = "ctf-challenge-builder-key"
  public_key = tls_private_key.builder_pk.public_key_openssh
}

# Create a security group to allow SSH access for the provisioner.
# This allows Terraform to connect to the instance and write the flag.
resource "aws_security_group" "allow_ssh" {
  name        = "ctf-challenge-allow-ssh"
  description = "Allow SSH inbound traffic for CTF builder"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name = "CTF-Challenge-SG"
  }
}

# Launch the EC2 instance that will be used to create the snapshot.
resource "aws_instance" "mount_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro" 
  key_name               = aws_key_pair.builder_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "mount-ec2"
  }

  # Provisioner to connect via SSH and write the flag to the specified file.
  provisioner "remote-exec" {
    inline = [
      "echo '${var.flag_content}' | sudo tee /var/log/flag.txt",
      "sudo chmod 644 /var/log/flag.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.builder_pk.private_key_pem
      host        = self.public_ip
    }
  }

  # Provisioner to stop the instance after the flag is written.
  # This ensures a clean, consistent state for the snapshot.
  # It waits for the instance to be fully running before stopping it.
  provisioner "local-exec" {
    when    = create
    command = "aws ec2 wait instance-running --instance-ids ${self.id} --region ${var.aws_region} && aws ec2 stop-instances --instance-ids ${self.id} --region ${var.aws_region} && aws ec2 wait instance-stopped --instance-ids ${self.id} --region ${var.aws_region}"
  }
}

# Create a snapshot of the root volume from the stopped instance.
# A dependency is set to ensure the instance provisioning and stopping are complete.
resource "aws_ebs_snapshot" "challenge_snapshot" {
  volume_id = aws_instance.mount_ec2.root_block_device[0].volume_id

  tags = {
    Name = "mount-snapshot"
  }

  depends_on = [
    aws_instance.mount_ec2
  ]
}

# Use a null_resource with a local-exec provisioner to make the snapshot public.
# This is the modern replacement for the deprecated "group = 'all'" functionality.
resource "null_resource" "make_snapshot_public" {
  # This resource will be created after the EBS snapshot is available.
  depends_on = [
    aws_ebs_snapshot.challenge_snapshot
  ]

  provisioner "local-exec" {
    # This command uses the AWS CLI to modify the snapshot's permissions.
    command = "aws ec2 modify-snapshot-attribute --snapshot-id ${aws_ebs_snapshot.challenge_snapshot.id} --attribute createVolumePermission --operation-type add --group-names all --region ${var.aws_region}"
  }
}

