terraform {
  backend "s3" {
    bucket         = "cit-poc-992382462775-tfstate"
    key            = "infrastructure/aws/ssm/patchbaseline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}