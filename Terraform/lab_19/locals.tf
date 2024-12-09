# locals.tf
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}
