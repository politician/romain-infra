# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  aws_account_name   = replace(title(replace(local.project_name, "-", " ")), " ", "")
  aws_terraform_user = format("%s-terraform", local.project_name)
  aws_users          = setunion([local.aws_terraform_user], var.aws_admin_users)
}

# ---------------------------------------------------------------------------------------------------------------------
# Project (sub-account)
# ---------------------------------------------------------------------------------------------------------------------
// Create sub-account
resource "aws_organizations_account" "account" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  name              = var.project_title
  email             = var.aws_account_email
  role_name         = "OrganizationAccountAccessRole"
  close_on_deletion = true

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------------------------------------------------
// Create terraform user
resource "aws_iam_user" "terraform" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  name          = local.aws_terraform_user
  force_destroy = true
  tags          = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

// Create programmatic access for Terraform user
resource "aws_iam_access_key" "terraform" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  user = aws_iam_user.terraform["main"].name

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Permissions
# ---------------------------------------------------------------------------------------------------------------------
// Create policy to assume the sub-account admin role from a role in the parent organization
resource "aws_iam_policy" "account_policy" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  name   = "${local.aws_account_name}AccountPolicy"
  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Resource": [
            "arn:aws:iam::${aws_organizations_account.account["main"].id}:role/OrganizationAccountAccessRole"
          ]
        }
      ]
    }
    EOF
}

// Create account user group
resource "aws_iam_group" "group" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  name = local.aws_account_name
}

// Attach policy to user group
resource "aws_iam_group_policy_attachment" "account_group_policy" {
  for_each = toset(var.aws_enabled ? ["main"] : [])

  group      = aws_iam_group.group["main"].id
  policy_arn = aws_iam_policy.account_policy["main"].id
}

// Place Terraform and admin users in above user group so it inherits the above permissions
resource "aws_iam_user_group_membership" "users_groups" {
  for_each   = toset(var.aws_enabled ? local.aws_users : [])
  depends_on = [aws_iam_user.terraform]

  user   = each.key
  groups = [aws_iam_group.group["main"].name]
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "aws_terraform_user_arn" {
  description = "AWS Terraform user ARN."
  value       = var.aws_enabled ? aws_iam_user.terraform["main"].arn : null
}

output "aws_terraform_user_name" {
  description = "AWS Terraform user name."
  value       = var.aws_enabled ? aws_iam_user.terraform["main"].name : null
}

output "aws_terraform_user_access_key_id" {
  description = "AWS Terraform user access key ID."
  value       = var.aws_enabled ? aws_iam_access_key.terraform["main"].id : null
}

output "aws_terraform_user_access_key_secret" {
  description = "AWS Terraform user secret access key."
  value       = var.aws_enabled ? aws_iam_access_key.terraform["main"].secret : null
}
