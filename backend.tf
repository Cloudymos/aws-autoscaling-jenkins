terraform {
  backend "s3" {
    bucket         = "poc-projects-terraform-statefile"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
  }
}