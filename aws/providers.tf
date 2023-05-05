terraform {
  required_version = ">=0.13.1" # Versão do Terraform
  required_providers {
    aws   = ">=3.54.0" # Versão da AWS
    local = ">=2.1.0"  # Versão do Provider da HASHCORP
  }
}

provider "aws" {
  region = "us-east-1"
}
