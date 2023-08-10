terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.regiao_aws
}

resource "aws_launch_template" "maquina" {
  image_id      = "ami-024e6efaf93d85776"
  instance_type = var.instancia
  key_name      = var.chave
  tags = {
    Name = "Terraform Ansible Python"
  }
  security_group_names = [var.sg_env]
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub") 
}

/* output "IP_publico" {
  value = aws_instance.app_server.public_ip
} */

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a"]
  name = var.nomeGrupo
  max_size = var.maximo
  min_size = var.minimo
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
}