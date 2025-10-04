/**
 * Backend Configuration
 * 
 * Initialize with environment-specific config:
 * terraform init -backend-config=environments/dev/backend.conf
 * terraform init -backend-config=environments/qa/backend.conf
 * terraform init -backend-config=environments/uat/backend.conf
 * terraform init -backend-config=environments/prod/backend.conf
 */

terraform {
  backend "s3" {
    # Configuration loaded from environments/{env}/backend.conf
  }
}
