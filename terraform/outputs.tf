output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "ssh_connection_command" {
  description = "SSH command template to connect to EC2"
  value       = "ssh -i /path/to/your-key.pem ec2-user@${aws_instance.app_server.public_ip}"
}

output "ansible_inventory_line" {
  description = "Inventory line you can copy into ansible/inventory.ini"
  value       = "app_server ansible_host=${aws_instance.app_server.public_ip} ansible_user=ec2-user"
}

output "app_url" {
  description = "HTTP URL for deployed app"
  value       = "http://${aws_instance.app_server.public_ip}"
}
