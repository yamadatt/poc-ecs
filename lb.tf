resource "aws_lb" "main" {
  name               = "yamada-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  # access_logs {
  #   bucket = "${aws_s3_bucket.alb_log.bucket}"
  # }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_listener_rule" "test" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 10   # 本番ルール(20)より先に評価されるよう小さい数

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  condition {
    path_pattern {
      values = ["/test", "/test/*"]
    }
  }
}
resource "aws_lb_listener_rule" "production" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      # exact match なら "/" のみ、その他すべては default_action で処理
      values = ["/"]
    }
  }
}


resource "aws_lb_target_group" "blue" {
  name        = "yamada-ecs-targetgroup-blue"
  port        = 8091
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "green" {
  name        = "yamada-ecs-targetgroup-green"
  port        = 8091
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

output "ALB_DNS_NAME" {
  value = aws_lb.main.dns_name
}
