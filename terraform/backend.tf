terraform {
  backend "s3" {
    bucket         = "terraform-state-adham-dr-2026"
    key            = "k8s-dr/terraform.tfstate"     
    region         = "eu-central-1"                  
    encrypt        = true                            
  }
}
