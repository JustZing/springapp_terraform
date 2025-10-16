terraform {
  backend "s3" {
    bucket  = "github-terraform-bucketz"
    key     = "infra.tfstate"
    region  = "ap-south-1"
    profile = "default"
    dynamodb_table = "vegeta-terraform-remote-state-table"
  }
}
