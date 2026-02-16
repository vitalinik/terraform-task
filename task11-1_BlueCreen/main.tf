#----------------------------------------------------------
#Create: 
#        - Security Group for Web Server 
#        - Launch Configuration with Auto AMI lookup
#        - Auto Scaling Group using 2 Availability Zones
#        - Classic Load Balancer in 2 Availability Zones
#----------------------------------------------------------

provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"] # ["137112412989"] #
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web" {
  name = "Dynamic Security Group"

  dynamic "ingress" {
    for_each = ["80", "443"]
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

  tags = {
    Name  = "Web Server SecurityGroupe"
    Owner = "Vitalii"
  }
}

resource "aws_launch_configuration" "web" {
  #name = "WebServer-Hightly-Available-LC"
  name_prefix     = "WebServer-Hightly-Available-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "web" {
  #name = "WebServer-Hightly-Available-ASG"
  name_prefix          = "WebServer-Hightly-Available-ASG-"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.id]

  dynamic "tag" {
    for_each = {
      "Name"   = "WebServer in ASG"
      "Owner"  = "Vitalii"
      "TAGKEY" = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name               = "WebServer-HAvailable-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name  = "WebServer-Highly-Available-ELB"
    Owner = "Vitalii"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

#----------------------------------------------------------
output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}
