locals {
  common_tags = { Environment = var.environment; Project = var.project_name; ManagedBy = "Terraform"; Layer = "dns" }
}
