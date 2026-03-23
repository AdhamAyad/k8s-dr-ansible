variable "github_repo" {
  description = "The GitHub repository in format 'username/repo'"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
}

variable "thumbprint_list" {
  description = "List of thumbprints for the OIDC provider"
  type        = list(string)
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
}
