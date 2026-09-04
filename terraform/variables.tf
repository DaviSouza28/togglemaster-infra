variable "auth_db_password" {
  description = "Senha do banco Auth"
  type        = string
  sensitive   = true
}

variable "flag_db_password" {
  description = "Senha do banco Flag"
  type        = string
  sensitive   = true
}

variable "targeting_db_password" {
  description = "Senha do banco Targeting"
  type        = string
  sensitive   = true
}

variable "eks_admin_principal_arn" {
  description = "ARN do principal IAM administrador do cluster EKS"
  type        = string
}