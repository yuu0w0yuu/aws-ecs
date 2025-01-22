module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.prefix}_cluster"
  cluster_settings = {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider" {
  cluster_name = module.ecs.cluster_name

  capacity_providers = [aws_ecs_capacity_provider.cp_ec2_blue.name, aws_ecs_capacity_provider.cp_ec2_green.name]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 0
    capacity_provider = aws_ecs_capacity_provider.cp_ec2_blue.name
  }
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.cp_ec2_green.name
  }

  # FARGATE用設定
  # capacity_providers = [ "FARGATE","FARGATE_SPOT"]
  # default_capacity_provider_strategy {
  #     base = 1
  #     weight = 30
  #     capacity_provider = "FARGATE"
  # }
  # default_capacity_provider_strategy {
  #     weight = 70
  #     capacity_provider = "FARGATE_SPOT"
  # }

}

resource "aws_ecs_capacity_provider" "cp_ec2_blue" {
  name = "EC2_blue"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.asg_blue.autoscaling_group_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      target_capacity           = 70
    }
  }
}

resource "aws_ecs_capacity_provider" "cp_ec2_green" {
  name = "EC2_green"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.asg_green.autoscaling_group_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      target_capacity           = 70
    }
  }
}