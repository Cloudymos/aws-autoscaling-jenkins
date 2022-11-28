resource "aws_lb" "poc_lb" {
  name               = "poc-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.poc_sg_lb.id]
  subnets            = toset(aws_subnet.public[*].id)
  enable_cross_zone_load_balancing = true

  depends_on = [
    aws_internet_gateway.internet_gateway
  ]
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }
}

resource "aws_lb_listener" "poc_listener" {
  load_balancer_arn = aws_lb.poc_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}