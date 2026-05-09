provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "devops-tfstate-jaffarmuhammad1234567"
}

resource "aws_dynamodb_table" "lock" {
  name         = "devops-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
