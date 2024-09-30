provider "aws" {
  region = "us-west-1"
}

variable "aws_public_key_name" {
  default = "prometheus_aws_rsa"
}

resource "tls_private_key" "sskeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "prometheus_key_pair" {
  depends_on = [tls_private_key.sskeygen_execution]
  key_name   = "${var.aws_public_key_name}"
  public_key = "${tls_private_key.sskeygen_execution.public_key_openssh}"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-047d7c33f6e7b4bc4" # Ubuntu 18.04 AMI
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.prometheus_key_pair.id}"
  associate_public_ip_address = true

  tags = {
    Name = "ec2_instance"
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

    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u ec2-user -i '${self.public_ip}' --private-key ${aws_key_pair.prometheus_key_pair.id}.pem ./playbook.yml"
  }
}

output "instance_ip" {
  value = aws_instance.ec2_instance.public_ip
}
