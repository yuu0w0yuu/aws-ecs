module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  # OR条件でECSのイベントは"default"バスに通知されるため、busを作成しない（defaultを利用する）設定とする
  create_bus          = false
  append_rule_postfix = false

  ### ルール定義
  rules = {
    # コンテナインスタンス状態変更イベントのルール
    "${module.ecs.cluster_name}-InstanceStateChangeEvents" = {
      event_pattern = jsonencode({
        "source" : ["aws.ecs"],
        "detail-type" : ["ECS Container Instance State Change"],
        "detail" : { "clusterArn" : [module.ecs.cluster_arn] }
      })
      enabled = true
    },
    # タスク状態変更イベントのルール
    "${module.ecs.cluster_name}-TaskStateChangeEvents" = {
      event_pattern = jsonencode({
        "source" : ["aws.ecs"],
        "detail-type" : ["ECS Task State Change"],
        "detail" : { "clusterArn" : [module.ecs.cluster_arn] }
      })
      enabled = true
    },
    # サービスアクションイベントのルール
    "${module.ecs.cluster_name}-ServiceActionEvents" = {
      event_pattern = jsonencode({
        "source" : ["aws.ecs"],
        "detail-type" : ["ECS Service Action"],
        "detail" : {
          "clusterArn" : [module.ecs.cluster_arn],
          "eventType" : ["INFO", "WARN", "ERROR"]
        }
      })
      enabled = true
    },
    # サービスデプロイ状態変更イベントのルール
    "${module.ecs.cluster_name}-DeplomentStateChangeEvent" = {
      event_pattern = jsonencode({
        "source" : ["aws.ecs"],
        "detail-type" : ["ECS Deployment State Change"],
        "resources" : [{
          "prefix" : replace(module.ecs.cluster_arn, ":cluster/", ":service/")
        }],
        "detail" : {
          "eventType" : ["INFO", "WARN", "ERROR"]
        }
      })
      enabled = true
    }
  }

  ### ターゲット定義
  targets = {
    "${module.ecs.cluster_name}-InstanceStateChangeEvents" = [
      {
        name = "LogGroup_InstanceStateChangeEvents"
        arn  = aws_cloudwatch_log_group.containerinsights_event.arn
      }
    ],
    "${module.ecs.cluster_name}-TaskStateChangeEvents" = [
      {
        name = "LogGroup_TaskStateChangeEvents"
        arn  = aws_cloudwatch_log_group.containerinsights_event.arn
      }
    ],
    "${module.ecs.cluster_name}-ServiceActionEvents" = [
      {
        name = "LogGroup_ServiceActionEvents"
        arn  = aws_cloudwatch_log_group.containerinsights_event.arn
      }
    ],
    "${module.ecs.cluster_name}-DeplomentStateChangeEvent" = [
      {
        name = "LogGroup_DeplomentStateChangeEvent"
        arn  = aws_cloudwatch_log_group.containerinsights_event.arn
      }
    ]
  }
}