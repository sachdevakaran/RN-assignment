terraform {
  backend "s3" {
    bucket = "rn-test-bucket-karan-new-04"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
