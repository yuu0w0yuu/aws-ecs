resource "aws_lb" "ecs_lb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = module.vpc.public_subnets
}

################################
## Service Traffic
################################

resource "aws_lb_target_group" "ecs_alb_tg_service" {
  name        = "ecs-alb-tg-service"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "ecs_alb_listener_service" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg_service.arn
  }

#CodeDeployによるBlueGreenDeploymen実行時にリスナーとターゲットグループの紐づけが変わるため、ターゲットグループはignore_changesする
  lifecycle {
    ignore_changes = [default_action["target_group_arn"]]
  }
}

################################
## Test Traffic
################################

resource "aws_lb_target_group" "ecs_alb_tg_test" {
  name        = "ecs-alb-tg-test"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "ecs_alb_listener_test" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg_test.arn
  }
  
#CodeDeployによるBlueGreenDeploymen実行時にリスナーとターゲットグループの紐づけが変わるため、ターゲットグループはignore_changesする
  lifecycle {
    ignore_changes = [default_action["target_group_arn"]]
  }
}