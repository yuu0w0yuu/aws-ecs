# ECSライフサイクルイベントをEventBridgeからログとして受信するためのロググループ設定
resource "aws_cloudwatch_log_group" "containerinsights_event" {
  name              = "/aws/events/ecs/containerinsights/${module.ecs.cluster_name}/performance"
  retention_in_days = 3

  # EventBridge Module側で"ECS_ContainerInsights"というインデックスが付与されたルールのルールARNを識別用にタグ付けする（動作には影響のないタグ）
  tags = {
    "ClusterName" = module.ecs.cluster_name
  }
}