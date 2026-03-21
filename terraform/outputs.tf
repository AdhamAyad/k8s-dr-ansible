output "backup_bucket_name" {
  value       = aws_s3_bucket.k8s_backup_bucket.id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
