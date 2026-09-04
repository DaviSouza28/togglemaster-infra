variable "cluster_role_arn" {
  description = "ARN da IAM Role do EKS Cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN da IAM Role dos EKS Node Groups"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets privadas utilizadas pelo EKS"
  type        = list(string)
}

variable "evaluation_workload_role_arn" {
  description = "ARN da IAM Role do evaluation-service"
  type        = string
}

variable "analytics_workload_role_arn" {
  description = "ARN da IAM Role do analytics-service"
  type        = string
}

variable "db_init_workload_role_arn" {
  description = "ARN da IAM Role do Job de inicializacao dos bancos"
  type        = string
}

variable "admin_principal_arn" {
  description = "ARN do principal IAM com acesso administrativo ao cluster EKS"
  type        = string
}