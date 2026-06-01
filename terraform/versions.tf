terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend lives in the DR region (Singapore). If the primary region
  # (Bangkok) is the incident, we still need a working state store to run
  # `terraform apply` against the DR resources. The state bucket also has
  # CRR to a third region, configured at account bootstrap.
  backend "s3" {
    bucket         = "redemption-tfstate"
    key            = "redemption/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "redemption-tflock"
    encrypt        = true
  }
}
