resource "aws_s3_bucket" "k8s_backup_bucket" {
  bucket_prefix = "k8s-dr-backup-adham-"
  
  tags = {
    Name        = "Kubernetes DR Backups"
    Environment = "Lab"
  }
}
