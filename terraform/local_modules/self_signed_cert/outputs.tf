output "iam_self_signed_iam" {
  description = "ARN for the Self-Signed certificate on IAM"
  value       = aws_iam_server_certificate.cert.arn
}
