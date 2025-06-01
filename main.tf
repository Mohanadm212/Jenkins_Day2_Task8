provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-0a461599880b5bb71"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  key_name                    = "lab1-kp"
  subnet_id                   = "subnet-0e9d4b4ebbf99df83"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Task8-instance"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[web]" > /var/jenkins_home/workspace/Day2-Task8/ansible/inventory.ini
      echo "${aws_instance.web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/jenkins_home/lab1-kp.pem" >> /var/jenkins_home/workspace/Day2-Task8/ansible/inventory.ini
      export ANSIBLE_HOST_KEY_CHECKING=False
EOT
  }
}
