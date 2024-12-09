# outputs.tf
output "instance_id" {
  value       = aws_instance.web.id
  description = "EC2 instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "EC2 instance public IP"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "security_group_id" {
  value       = aws_security_group.example.id
  description = "Security Group ID"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.security_group_changes.arn
  description = "SNS Topic ARN"
}
