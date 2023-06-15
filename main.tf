terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "tls_private_key" "terraform-ssh-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
}

resource "aws_security_group" "minecraft-auto-sg" {
  name = "minecraft-auto-sg"
  description = "Allow SSH and Minecraft traffic via Terraform"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = "ami-0e578290d2d5a1bfd"
  instance_type               = "t2.small"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.minecraft-auto-sg.id]

  tags = {
    Name = "minecraft-auto"
  }
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("tf-key-pair")}"
    host        = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "minecraft.service"
    destination = "/home/ubuntu/minecraft.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo snap install docker",
      "sudo docker pull itzg/minecraft-server",
      "sudo mv minecraft.service /etc/systemd/system/minecraft.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable minecraft",
      "sudo systemctl start minecraft"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > server_ip"
  }

  key_name= "tf-key-pair"

}

