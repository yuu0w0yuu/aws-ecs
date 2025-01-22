provider "aws" {
  region  = "ap-northeast-1"

  default_tags { #デフォルトタグ付与（ojt識別子・Terraform識別子）
    tags = {
      creator   = "yutaro.shirayama"
      terraform = "true"
    }

  }
}