terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-099113461797-ap-northeast-2-an"
    key    = "EKS/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
