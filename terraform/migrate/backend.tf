terraform {
  backend "s3" {
    profile        = "3-shake-sso"
    bucket         = "shirayama-test-terraform-tfstate"
    key            = "ecs/dev/terraform.tfstate"
    encrypt        = true
    region         = "ap-northeast-1"
    dynamodb_table = "shirayama-test-terraform-tfstatelock"
  }
}