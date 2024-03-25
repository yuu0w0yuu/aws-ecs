terraform {
  backend "s3" {
    bucket  = "shirayama-test-terraform-tfstate"
    key     = "aws-ecs/terraform.tfstate"
    encrypt = true
    region  = "ap-northeast-1"
  }
}