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
  user_data            = filebase64("ansible.sh")
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave
  public_key = file("${var.chave}.pub")
}

/* output "IP_publico" {
  value = aws_instance.app_server.public_ip
} */

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"]
  name               = var.nomeGrupo
  max_size           = var.maximo
  min_size           = var.minimo
  launch_template {
    id      = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alvoLoadBalancer.arn]
}

resource "aws_default_subnet" "subnet-1" {
  availability_zone = "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet-2" {
  availability_zone = "${var.regiao_aws}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets  = [aws_default_subnet.subnet-1.id, aws_default_subnet.subnet-2.id ]
}

resource "aws_default_vpc" "default" {

}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name     = "maquinasAlvo"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer.arn
  }
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type = "TargetTrakingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAvarageCPUUtilization"
    }
    target_value = 50.0
  }
}