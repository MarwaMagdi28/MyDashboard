provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-047d7c33f6e7b4bc4" # Ubuntu 18.04 AMI
  instance_type = "t2.micro"
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
            sudo apt install 
            SSH_PUBLIC_KEY=$(curl -s https://api.github.com/repos/MarwaMagdi28/MYDASHBOARD/actions/secrets/SSH_PUBLIC_KEY | jq -r .key)
            echo "$SSH_PUBLIC_KEY" >> /home/ec2-user/.ssh/authorized_keys
            chmod 600 /home/ec2-user/.ssh/authorized_keys
            EOF

    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u ec2-user -h ${self.public_ip} --private-key $(curl -s https://api.github.com/repos/MarwaMagdi28/MYDASHBOARD/actions/secrets/ssh_private_key | jq -r .key)  ./playbook.yml"
  }
}

output "instance_ip" {
  value = aws_instance.ec2_instance.public_ip
}
