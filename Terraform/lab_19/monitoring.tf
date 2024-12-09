# monitoring.tf
resource "aws_sns_topic" "security_group_changes" {
  name = "${local.name_prefix}-sg-changes"
  
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "security_group_notification" {
  topic_arn = aws_sns_topic.security_group_changes.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "security_group_changes" {
  name        = "${local.name_prefix}-sg-changes"
  description = "Capture all Security Group changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName   = [
        "AuthorizeSecurityGroupIngress",
        "RevokeSecurityGroupIngress",
        "AuthorizeSecurityGroupEgress",
        "RevokeSecurityGroupEgress"
      ]
      requestParameters = {
        groupId = [aws_security_group.example.id]
      }
    }
  })

  tags = local.common_tags
}
