# ---------------------------------------------------------------------------------------------------------------------
# AWS
# ---------------------------------------------------------------------------------------------------------------------
// Make account an organization
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

// Create personal IAM user
resource "aws_iam_user" "global" {
  name = "romain"
}

// Create console access
resource "aws_iam_user_login_profile" "global" {
  user                    = aws_iam_user.global.name
  pgp_key                 = filebase64("${path.module}/keys/romain.gpg")
  password_reset_required = false
}

// Allow user to read all resources in the AWS account
resource "aws_iam_user_policy_attachment" "global_iam-admin" {
  user = aws_iam_user.global.name
  # policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ---------------------------------------------------------------------------------------------------------------------
# Google Cloud Platform
# ---------------------------------------------------------------------------------------------------------------------
// Create the global KMS keyring
resource "google_kms_key_ring" "global" {
  name     = "romain"
  location = "global"
  project  = module.romain-infra.gcp_project_id

  lifecycle {
    prevent_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "global_aws_signin_url" {
  description = "Global AWS IAM sign-in URL."
  value       = "https://${aws_organizations_organization.org.master_account_id}.signin.aws.amazon.com/console?region=us-east-1"
}

output "global_aws_user_name" {
  description = "Global AWS user name."
  value       = aws_iam_user.global.name
}

output "global_aws_user_password" {
  description = "Global AWS user password. View it with `terraform output --raw global_aws_user_password | base64 --decode | gpg --decrypt`"
  value       = aws_iam_user_login_profile.global.encrypted_password
}
