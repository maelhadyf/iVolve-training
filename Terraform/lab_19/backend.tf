# backend.tf
terraform {
  backend "s3" {
    bucket         = "${var.project_name}-terraform-state-${var.environment}"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "memo-lab19-terraform-lock"
  }
}