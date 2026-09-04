terraform {
  backend "s3" {
    bucket  = "davi-laboratorio-terraform-2026"
    key     = "fase-3/terraform.tfstate"
    region  = "us-east-1"
    profile = "terraform"
  }
}