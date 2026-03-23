module "my_github_oidc" {
  source      = "./modules/github-oidc"
  
  github_repo = "AdhamAyad/k8s-dr-ansible"
  role_name   = "github-actions-k8s-dr-role"
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1", 
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]
}

