terraform {
  required_version = ">= 0.12.16"
  backend "s3" {
    bucket = "terra-test-methods"
    key    = "terraform-test/terraform.tfstate"
    region = "eu-west-1"
  }
}

