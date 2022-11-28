resource "aws_launch_configuration" "poc_launch_config" {
  name_prefix     = "poc-terraform-aws-"
  image_id        = var.nginx_ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.poc_sg_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "poc_asg" {
  min_size             = 1
  max_size             = 6
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.poc_launch_config.name
  vpc_zone_identifier  = toset(aws_subnet.public[*].id)
  target_group_arns = [aws_lb_target_group.lb_tg.arn,]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  dynamic "tag" {
    for_each = var.default_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  tag {
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = false
  }
}

# resource "aws_autoscaling_attachment" "poc_asg_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.poc_asg.id
#   lb_target_group_arn   = aws_lb_target_group.lb_tg.arn
# }

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "poc_scale_out"
  autoscaling_group_name = aws_autoscaling_group.poc_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "monitor_asg_scale_out" {
  alarm_description   = "Monitors CPU utilization for POC ASG to scale down"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  alarm_name          = "poc_scale_out"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "20"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.poc_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "poc_scale_in"
  autoscaling_group_name = aws_autoscaling_group.poc_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "monitor_asg_scale_in" {
  alarm_description   = "Monitors CPU utilization for POC ASG to scale up"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  alarm_name          = "poc_scale_in"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.poc_asg.name
  }
}