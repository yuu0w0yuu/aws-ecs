resource "aws_iam_instance_profile" "this" {
  name = "${var.prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

########################
### BLUE
########################
module "asg_blue" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "${var.prefix}-asg_ecs_provider"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 0
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  protect_from_scale_in     = false

  create_launch_template  = false
  launch_template_id      = aws_launch_template.lt_blue.id
  launch_template_version = "$Latest"
}

resource "aws_launch_template" "lt_blue" {
  name = "${var.prefix}-ecs-instance-template"

  #al2023-ami-ecs-hvm-2023.0.20230406-kernel-6.1-x86_64
  image_id = "ami-07695fdb89e41b9f8"

  update_default_version = true
  instance_type          = "t3.xlarge"

  # ECSコンテナインスタンス用IAMロールプロファイル
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  # ECSコンテナインスタンス用のuserdata設定
  user_data = base64encode(templatefile("${path.module}/files/userdata.sh", {
    cluster_name = module.ecs.cluster_name
  }))

  # NIC設定
  network_interfaces {
    security_groups             = [aws_security_group.sg-ecs-instance.id]
    associate_public_ip_address = false
  }
}

#######################
## GREEN
#######################
module "asg_green" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "${var.prefix}-asg_ecs_provider"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 0
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  protect_from_scale_in     = false

  create_launch_template  = false
  launch_template_id      = aws_launch_template.lt_green.id
  launch_template_version = "$Latest"
}

resource "aws_launch_template" "lt_green" {
  name = "${var.prefix}-ecs-instance-template-green"

  #al2023-ami-ecs-hvm-2023.0.20231103-kernel-6.1-x86_64
  image_id = "ami-0ec3dcc987d10643f"

  update_default_version = true
  instance_type          = "t3.xlarge"

  # ECSコンテナインスタンス用IAMロールプロファイル
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  # ECSコンテナインスタンス用のuserdata設定
  user_data = base64encode(templatefile("${path.module}/files/userdata.sh", {
    cluster_name = module.ecs.cluster_name
  }))

  # NIC設定
  network_interfaces {
    security_groups             = [aws_security_group.sg-ecs-instance.id]
    associate_public_ip_address = false
  }
}


#自動停止設定
resource "aws_autoscaling_schedule" "stop_ecs_containerinstance" {
  scheduled_action_name  = "stop-${var.prefix}-ecs-containerinstance"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 23 * * MON-FRI"
  time_zone              = "Asia/Tokyo"
  autoscaling_group_name = module.asg_blue.autoscaling_group_name
}

resource "aws_autoscaling_schedule" "start_ecs_containerinstance" {
  scheduled_action_name  = "start-${var.prefix}-ecs-containerinstance"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 7 * * MON-FRI"
  time_zone              = "Asia/Tokyo"
  autoscaling_group_name = module.asg_blue.autoscaling_group_name
}