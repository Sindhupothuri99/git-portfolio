provider "aws" {
  
}


terraform {
  backend "s3" {
    bucket       = "portfolio-s64guu"
    key          = "portfolio/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}