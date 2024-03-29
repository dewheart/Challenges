terraform {
  backend "s3" {
    bucket = "cit-poc-063997147317-tfstate"
    key    = "CITPOCWEBSRV1/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}