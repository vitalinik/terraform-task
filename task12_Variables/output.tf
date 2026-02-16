output "webserver_instatnse_id" {
  value = aws_instance.my_webserver.id

}

output "webserver_public_ip_adress" {
  value = aws_eip.my_static_ip.public_ip
}

output "webserver_sg_id" {
  value = aws_security_group.my_webserver.id
}

output "webserver_sg_arn" {
  value       = aws_security_group.my_webserver.arn
  description = "This is security groupe ARN"
}
