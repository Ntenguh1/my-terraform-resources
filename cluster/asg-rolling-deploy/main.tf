resource "aws_launch_template" "terraformLT" {
  name                   = "${var.cluster_name}-launch-template"
  update_default_version = true
  description            = "Launch template used for provisioning with Terraform"
  image_id               = data.aws_ami.std_ami.id
  instance_type          = var.template_instance_type
  key_name               = var.key_pair
  user_data              = filebase64("${path.module}/httpd.sh")
  network_interfaces {
    subnet_id       = data.terraform_remote_state.network.outputs.ndo_subnet_b
    security_groups = [aws_security_group.terraformSG.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
    }
  }
}

resource "aws_autoscaling_group" "terraformASG" {
  name                = "${var.cluster_name}-asg"
  vpc_zone_identifier = [data.terraform_remote_state.network.outputs.ndo_subnet_b, data.terraform_remote_state.network.outputs.ndo_subnet_c]
  desired_capacity    = var.asg_desired
  max_size            = var.asg_max
  min_size            = var.asg_min

  launch_template {
    id      = aws_launch_template.terraformLT.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.terraformASG.id
  alb_target_group_arn   = data.terraform_remote_state.alb.outputs.tg_arn
  depends_on = [
    aws_autoscaling_group.terraformASG
  ]
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name  = "scale_out_during_business_hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.terraformASG.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name  = "scale_in_at_night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.terraformASG.name
}

resource "aws_security_group" "terraformSG" {
  name        = "${var.cluster_name}-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.ndo_vpc_id

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "ndo-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraformSG.id
}

resource "aws_security_group_rule" "ndo-http-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraformSG.id
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
    alarm_name = "${var.cluster_name}-high-cpu-utilization"
    namespace = "AWS/EC2"
    metric_name = "CPUUtilization"

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.terraformASG.name
    }

    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    period = 120
    statistic = "Average"
    threshold = 90
    unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
    alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
    namespace = "AWS/EC2"
    metric_name = "CPUCreditBalance"

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.terraformASG.name
    }

    comparison_operator = "LessThanThreshold"
    evaluation_periods = 1
    period = 300
    statistic = "Minimum"
    threshold = 10
    unit = "Count"
}