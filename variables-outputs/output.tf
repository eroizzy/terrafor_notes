output "instance_1_ip_addr" {
  value = aws_instance.instance_1.private_ip
}
output "instance_2_ip_addr" {
  value = aws_instance.instance_2.private_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}