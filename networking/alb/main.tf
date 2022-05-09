# updated ALB default response
resource "aws_security_group" "terraform-alb-sg" {
  name        = var.alb_sg_name
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.ndo_vpc_id

  tags = {
    Name = var.alb_sg_name
  }
}

resource "aws_security_group_rule" "alb-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform-alb-sg.id
}

resource "aws_security_group_rule" "alb-http-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform-alb-sg.id
}

resource "aws_lb" "terraformALB" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform-alb-sg.id]
  subnets            = [data.terraform_remote_state.network.outputs.ndo_subnet_b, data.terraform_remote_state.network.outputs.ndo_subnet_c]
}

resource "aws_lb_target_group" "terraformTG" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.ndo_vpc_id
}

resource "aws_alb_listener" "terraformALBListener" {
  load_balancer_arn = aws_lb.terraformALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraformTG.arn
  }
}