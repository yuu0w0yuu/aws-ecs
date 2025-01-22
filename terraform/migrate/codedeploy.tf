resource "aws_codedeploy_app" "ecs_bluegreen_app" {
  compute_platform = "ECS"
  name             = "ecs_deploy_bluegreen"
}

resource "aws_codedeploy_deployment_group" "ecs_bluegreen_deplyment_group" {
  app_name               = aws_codedeploy_app.ecs_bluegreen_app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "ecs_bluegreen_deplyment_group"
  service_role_arn       = aws_iam_role.codedeploy_ecs_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = module.ecs.cluster_name
    service_name = "nginx-bluegreen"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.ecs_alb_listener_service.arn]
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.ecs_alb_listener_test.arn]
      }

      target_group {
        name = aws_lb_target_group.ecs_alb_tg_test.name
      }

      target_group {
        name = aws_lb_target_group.ecs_alb_tg_service.name
      }
    }
  }
}