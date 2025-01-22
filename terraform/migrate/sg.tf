####################################
## ECSタスク用セキュリティグループ
####################################
resource "aws_security_group" "sg-ecs-task" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.prefix}-container-sg-test"
}

resource "aws_security_group_rule" "sg_ecs_task_allow_ingress_http" {
  security_group_id        = aws_security_group.sg-ecs-task.id
  type                     = "ingress"
  protocol                 = "all"
  from_port                = "-1"
  to_port                  = "-1"
  description              = "Allow all traffic from ALB."
  source_security_group_id = aws_security_group.sg_alb.id
}

resource "aws_security_group_rule" "sg_ecs_tasl_allow_egress_all" {
  security_group_id = aws_security_group.sg-ecs-task.id
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
}

####################################
## ECSコンテナインスタンス用セキュリティグループ
####################################
resource "aws_security_group" "sg-ecs-instance" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.prefix}-ecs-instance-sg-test"
}

resource "aws_security_group_rule" "sg_ecs_instance_allow_egress_all" {
  security_group_id = aws_security_group.sg-ecs-instance.id
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
}


####################################
## ALB用セキュリティグループ
####################################
resource "aws_security_group" "sg_alb" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.prefix}-alb-sg-test"
}

resource "aws_security_group_rule" "alb_allow_ingress_http" {
  security_group_id = aws_security_group.sg_alb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow http traffic"
}

resource "aws_security_group_rule" "alb_allow_ingress_http_alt" {
  security_group_id = aws_security_group.sg_alb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "8080"
  to_port           = "8080"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow traffic for blue/green test"
}

resource "aws_security_group_rule" "alb_allow_egress_all" {
  security_group_id = aws_security_group.sg_alb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
}