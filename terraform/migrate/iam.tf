##################################################
### ECSコンテナインスタンス用IAMロール・ポリシー
##################################################
# IAMロール
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.prefix}-ecs-instance-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
# ECSコンテナインスタンス用IAMポリシー
# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/instance_IAM_role.html
resource "aws_iam_policy_attachment" "ecs_instance_ec2_policy" {
  name       = "${var.prefix}-ecs-instance-policy"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
# SystemManagerセッションマネージャー利用用ポリシー
# https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/setup-instance-permissions.html
resource "aws_iam_policy_attachment" "ecs_instance_ssm_policy" {
  name       = "${var.prefix}-ecs-ssm-policy"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


##################################################
### ECS CodeDeploy BlurGreenデプロイ実行用ロール
##################################################
resource "aws_iam_role" "codedeploy_ecs_role" {
  name = "${var.prefix}-codedeploy-ecs-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codedeploy_ecs_policy" {
  name       = "${var.prefix}-codedeploy-ecs-policy"
  roles      = [aws_iam_role.codedeploy_ecs_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}