provider "aws" {
  region = "us-east-1"
}

variable "env" {
  default = "dev"
}

variable "prod_owner" {
  default = "Vitalii Nik"
}

variable "noprod_owner" {
  default = "Prost Drug"
}

variable "ec2_size" {
  default = {
    "prod"    = "t3.medium"
    "dev"     = "t3.micro"
    "staging" = "t3.small"
  }
}

variable "allow_port_list" {
  default = {
    "prod" = ["80", "443"]
    "dev"  = ["80", "443", "22", "8080"]
  }
}

resource "aws_instance" "my_webserver1" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"]

  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }
}

resource "aws_instance" "my_webserver2" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = lookup(var.ec2_size, var.env)

  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }

}
