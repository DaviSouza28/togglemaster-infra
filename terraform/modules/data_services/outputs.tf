output "auth_db_endpoint" {
  description = "Endpoint do banco Auth"
  value       = aws_db_instance.auth.address
}

output "auth_db_port" {
  description = "Porta do banco Auth"
  value       = aws_db_instance.auth.port
}

output "flag_db_endpoint" {
  description = "Endpoint do banco Flag"
  value       = aws_db_instance.flag.address
}

output "flag_db_port" {
  description = "Porta do banco Flag"
  value       = aws_db_instance.flag.port
}

output "targeting_db_endpoint" {
  description = "Endpoint do banco Targeting"
  value       = aws_db_instance.targeting.address
}

output "targeting_db_port" {
  description = "Porta do banco Targeting"
  value       = aws_db_instance.targeting.port
}

output "redis_endpoint" {
  description = "Endpoint do Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Porta do Redis"
  value       = aws_elasticache_replication_group.redis.port
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.analytics.name
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.analytics.url
}

output "ecr_repository_urls" {
  description = "URLs dos repositorios ECR"
  value = {
    for name, repository in aws_ecr_repository.services :
    name => repository.repository_url
  }
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS"
  value       = aws_sqs_queue.analytics.arn
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.analytics.arn
}

output "auth_db_secret_arn" {
  description = "ARN do Secret Manager do Auth DB"
  value       = aws_secretsmanager_secret.auth_db.arn
}

output "flag_db_secret_arn" {
  description = "ARN do Secret Manager do Flag DB"
  value       = aws_secretsmanager_secret.flag_db.arn
}

output "targeting_db_secret_arn" {
  description = "ARN do Secret Manager do Targeting DB"
  value       = aws_secretsmanager_secret.targeting_db.arn
}
