locals {
  # 共通設定
  service = "shirayama"
  env     = "ecs"
  prefix  = "${local.service}-${local.env}"

  required_tags = {
    creator   = "yutaro.shirayama"
    terraform = "true"
  }

  # VPC設定
  vpc_cidr = "10.10.0.0/16"

  public_subnets = [
    { cidr = "10.10.1.0/24", az = "ap-northeast-1a" },
    { cidr = "10.10.2.0/24", az = "ap-northeast-1c" }
  ]

  private_subnets = [
    { cidr = "10.10.11.0/24", az = "ap-northeast-1a" },
    { cidr = "10.10.12.0/24", az = "ap-northeast-1c" }
  ]

}