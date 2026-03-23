output "backup_bucket_name" {
  value       = aws_s3_bucket.k8s_backup_bucket.id
}

output "role_arn" {
  value = module.my_github_oidc.github_actions_role_arn
}
