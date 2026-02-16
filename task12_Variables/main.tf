provider "aws" {
  region = var.region
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_webserver.id
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Environment"]} Server IP"
  })

  /*
  tags = {
    Name  = "Web Server IP"
    Owner = "Vitalii"
  }
  */
}


resource "aws_instance" "my_webserver" {
  ami                    = "ami-03a71cec707bfc3d7"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  monitoring             = var.enable_detailed_monitoring # это стоит денег, так что по умолчанию отключено

  user_data = templatefile("user_data.sh.tpl", {
    f_name = "Denis",
    l_name = "Astahov",
    names  = ["Vasya", "Kolya", "Petya", "John", "Donald", "Masha"]
  })

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Environment"]} Web Server"
  })

  /*tags = {
    Name  = "Web Server"
    Owner = "Vitalii"
  }*/

  lifecycle {
    #prevent_destroy = true
    #ignore_changes = ["ami", "user_data"]
    create_before_destroy = true
  }
}

resource "aws_security_group" "my_webserver" {
  name = "Dynamic Security Group"

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Environment"]} Web Serve SecurityGrouper"
  })

  /*tags = {
    Name  = "Web Server SecurityGroupe"
    Owner = "Vitalii"
  }*/
}
