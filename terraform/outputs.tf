output "vpc_id" {
  description = "ID da VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.networking.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "auth_db_endpoint" {
  description = "Endpoint do PostgreSQL Auth"
  value       = module.data_services.auth_db_endpoint
}

output "flag_db_endpoint" {
  description = "Endpoint do PostgreSQL Flag"
  value       = module.data_services.flag_db_endpoint
}

output "targeting_db_endpoint" {
  description = "Endpoint do PostgreSQL Targeting"
  value       = module.data_services.targeting_db_endpoint
}

output "redis_endpoint" {
  description = "Endpoint do Redis"
  value       = module.data_services.redis_endpoint
}

output "analytics_queue_url" {
  description = "URL da fila SQS de Analytics"
  value       = module.data_services.sqs_queue_url
}

output "analytics_table_name" {
  description = "Nome da tabela DynamoDB de Analytics"
  value       = module.data_services.dynamodb_table_name
}

output "github_actions_role_arn" {
  description = "ARN da IAM Role usada pelos pipelines do GitHub Actions"
  value       = module.iam.github_actions_role_arn
}