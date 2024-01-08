data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_lb" "sample" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

}

resource "aws_security_group" "alb" {
  name   = "${var.project}-${var.env}-alb-sg"
  vpc_id = aws_vpc.example.id
  ingress {
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
}

resource "aws_lb_listener" "sample" {
  load_balancer_arn = aws_lb.sample.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample.arn
  }

}

///リスナールールの定義

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.sample.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "sample" {
  name     = "${var.project}-${var.env}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id

  health_check {
    path = "/index.html"
  }
}

resource "aws_lb_target_group_attachment" "sample" {
  target_group_arn = aws_lb_target_group.sample.arn
  target_id        = aws_instance.sample.id
  port             = 80
}
