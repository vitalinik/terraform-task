provider "aws" {
  region = "ca-central-1"
}

terraform {
  backend "s3" {
    bucket = "vit-nikolaich-project-terraform-bucket"
    key    = "dev/servers/terraform.tfstate"
    region = "us-east-1"
  }
}

#============================================================

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "vit-nikolaich-project-terraform-bucket"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web_server" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.wedserver.id]
  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data       = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
ocho "<h2>Web Server with IP: $myip</h2><br>Build by Terraform with Remote State" > /var/www/html/index.html
EOF
  tags = {
    Name = "Web Server"
  }

}


#============================================================



resource "aws_security_group" "wedserver" {
  name   = "WedServer Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "web-server-sg"
    Onwer = "Vitalii"
  }
}

#output "network_details" {
#  value = data.terraform_remote_state.network
#}

output "webserver_sg_id" {
  value = aws_security_group.wedserver.id
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}
