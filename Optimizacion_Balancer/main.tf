provider "aws" {
  region = var.aws_region
}

locals {
  instance_type   = "t1.micro"
  server_port     = 8080
  public_port     = 80
  server_protocol = "TCP"
  tg_protocol     = "HTTP"
  cidr_public     = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "subnets" {
  count             = var.amount_subnets
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available)]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }

}

resource "aws_security_group" "sg_server_public" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    cidr_blocks = local.cidr_public
    from_port   = local.server_port
    to_port     = local.server_port
    protocol    = local.server_protocol
  }
}

resource "aws_instance" "servers" {
  count                  = var.number_servers
  ami                    = coalesce(var.user_specified_ami, data.aws_ami.ubuntu.id)
  instance_type          = coalesce(var.user_specified_ami, local.instance_type)
  subnet_id              = data.aws_subnet.subnets[count.index % length(data.aws_subnet.subnets)].id
  vpc_security_group_ids = [aws_security_group.sg_server_public.id]

  tags = {
    Name = "Servidor-${count.index}"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Hola Mundo Soy El Server ${count.index + 1}" > index.html
    nohup busybox httpd -f -p 8080&
    EOF

}

resource "aws_security_group" "alb_security_group" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    cidr_blocks = local.cidr_public
    from_port   = local.public_port
    to_port     = local.public_port
    protocol    = local.server_protocol
  }

  egress {
    cidr_blocks = local.cidr_public
    from_port   = local.server_port
    to_port     = local.server_port
    protocol    = local.server_protocol
  }
}

resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "alb"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for subnet in data.aws_subnet.subnets : "${subnet.id}"]
}

resource "aws_lb_target_group" "tg" {
  name     = "tg"
  port     = local.public_port
  vpc_id   = data.aws_vpc.default.id
  protocol = local.tg_protocol

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = local.server_port
    protocol = local.tg_protocol
  }
}
resource "aws_lb_target_group_attachment" "http" {
  count            = length(aws_instance.servers)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.servers[count.index].id
  port             = local.server_port
}

resource "aws_lb_listener" "lb_lis_feog" {
  load_balancer_arn = aws_lb.alb.arn
  port              = local.public_port
  protocol          = local.tg_protocol
  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }

}
