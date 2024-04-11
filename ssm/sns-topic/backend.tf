terraform {
  backend "s3" {
    bucket         = "cit-poc-992382462775-tfstate"
    key            = "IaC-POC/infrastructure/aws/ssm/sns-topic/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}