terraform {
  required_providers {
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
}
