terraform {
  backend "s3" {
    bucket         = "cit-poc-992382462775-tfstate"
    key            = "CIT-POC/SSM-PATCH/NIHC-16/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}