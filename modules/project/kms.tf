# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
// Generate unique ID for naming KMS key
resource "random_integer" "kms" {
  for_each = toset(var.kms_enabled ? ["main"] : [])

  min = 1000
  max = 9999
}

# ---------------------------------------------------------------------------------------------------------------------
# Encryption/Decryption key
# ---------------------------------------------------------------------------------------------------------------------
// Create key
// GCP does not allow renaming/deletion of keys, so we use a random integer as key name
// Destroying the resource will have the effect of disabling the key in GCP
resource "google_kms_crypto_key" "kms" {
  for_each = toset(var.kms_enabled ? ["main"] : [])

  name     = format("%s-%s", local.project_name, random_integer.kms["main"].id)
  key_ring = var.kms_keyring_id
  labels   = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------------------------------------------------
// Create user (if not already created in GCP)
resource "google_service_account" "kms" {
  for_each = toset(var.kms_enabled && !var.gcp_enabled ? ["main"] : [])

  account_id   = format("%s-automated", local.project_name)
  display_name = var.project_title
}

// Generate access key for user (if user not already created in GCP)
resource "google_service_account_key" "kms" {
  for_each = toset(var.kms_enabled && !var.gcp_enabled ? ["main"] : [])

  service_account_id = google_service_account.kms["main"].name
}

// User is allowed to encrypt and decrypt with the key
resource "google_kms_crypto_key_iam_member" "kms" {
  for_each = toset(var.kms_enabled ? ["main"] : [])

  crypto_key_id = google_kms_crypto_key.kms["main"].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${var.gcp_enabled ? google_service_account.terraform["main"].email : google_service_account.kms["main"].email}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "kms_user_email" {
  description = "KMS user email."
  value       = var.kms_enabled ? (var.gcp_enabled ? google_service_account.terraform["main"] : google_service_account.kms["main"]).email : null
}

output "kms_user_secret_key" {
  description = "KMS user secret key."
  value       = var.kms_enabled ? (var.gcp_enabled ? google_service_account_key.terraform["main"] : google_service_account_key.kms["main"]).private_key : null
  sensitive   = true
}

output "kms_key_id" {
  description = "Encryption/Decryption key ID."
  value       = var.kms_enabled ? google_kms_crypto_key.kms["main"].id : null
}
