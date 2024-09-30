provider "aws" {
  region = "us-west-1"
}

resource "aws_key_pair" "monitoring" {
  key_name   = "monitoring_server_keypair"
  public_key = file(var.instance_ssh_pub_key)
}

variable "instance_ssh_pub_key" {
  type = string
}

variable "instance_ssh_priv_key" {
  type = string
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-047d7c33f6e7b4bc4" # Ubuntu 18.04 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.monitoring.key_name
  associate_public_ip_address = true
  
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

    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ${var.instance_ssh_priv_key} ./playbook.yml"
  }
}

output "instance_ip" {
  value = aws_instance.ubuntu.public_ip
}
