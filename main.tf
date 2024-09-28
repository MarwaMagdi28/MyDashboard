provider "aws" {
  region     = "us-west-1"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-047d7c33f6e7b4bc4"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
}
