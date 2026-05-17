terraform {
  backend "s3" {
    bucket         = "devops-tfstate-jaffarmuhammad1234567"
    key            = "staging/devops.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "devops-locks"
    encrypt        = true
  }
}