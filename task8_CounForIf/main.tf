provider "aws" {
  region = "us-east-1"
}

variable "aws_users" {
  description = "List of IAM Users to create"
  default     = ["vasya", "petya", "kolya", "lena", "masha", "misha", "vova", "donald"]
}

resource "aws_iam_user" "user1" {
  name = "pushkin"
}

resource "aws_iam_user" "name" {
  count = length(var.aws_users)
  name  = element(var.aws_users, count.index)
}

output "create_iam_uaers_all" {
  value = aws_iam_user.users
}

output "create_iam_users_ids" {
  value = aws_iam_user.users[*].id
}

output "create_iam_users_custom" {
  value = [
    for user in aws_iam_user.users :
    "Username: ${user.name} has ARN: ${user.arn}"
  ]
}

output "create_iam_users_mao" {
  value = {
    for user in aws_iam_user.users :
    user.unique_id => user.id //"SGGGWW4646465SSFSFSDGG" : "vasya"
  }
}


// Print List of users with name 4 characters long
output "custom_if_leght" {
  value = [
    for x in aws_iam_user.users :
    x.name
    if length(x.name) == 4
  ]
}



#----------------------------------------------------

resource "aws_instance" "servers" {
  count         = 3
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t3.micro"
  tags = {
    Name = "Server Number ${count.index + 1}"
  }
}


// Print nice MAP  of InstanceID:  PublicIP
output "server_all" {
  value = {
    for server in aws_instance.servers :
    server.id => server.public_ip
  }
}
