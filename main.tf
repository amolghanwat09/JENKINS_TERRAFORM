terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default VPC"
  }
}

data "aws_availability_zones" "available" {

}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet for us-west-1a"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow 8080 & 22 inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS http access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0430580de6244e02e" # us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name               = "my_key"

  tags = {
    "Name" = "jenkins_server"
  }

}

resource "null_resource" "install" {

  # SSH into ec2 instance

  connection {

    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/downloads/my_key.pem")
    host        = aws_instance.jenkins_server.public_ip
  }

  #copy the instal_jenkins.sh file from local to ec2 instance

  provisioner "file" {

    source      = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"

  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x /tmp/install_jenkins.sh",
      "sh /tmp/install_jenkins.sh"
    ]

  }

  depends_on = [

    aws_instance.jenkins_server
  ]
}