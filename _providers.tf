terraform {
  required_version = "~> 1.1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.19.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.25.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.22.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.31.0"
    }
  }
}

provider "google" {
  # project = var.gcp_iam_project_id
  region = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}