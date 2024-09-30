provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-005fc0f236362e99f" # Ubuntu 18.04 AMI
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus
            sudo docker run -d --name grafana -p 3000:3000 grafana/grafana
            EOF
}

output "instance_ip" {
  value = aws_instance.ubuntu.public_ip
}
