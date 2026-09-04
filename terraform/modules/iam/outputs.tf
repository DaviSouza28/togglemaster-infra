output "eks_cluster_role_arn" {
  description = "ARN da IAM Role do EKS Cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN da IAM Role dos EKS Node Groups"
  value       = aws_iam_role.eks_node.arn
}

output "evaluation_workload_role_arn" {
  description = "ARN da IAM Role do evaluation-service"
  value       = aws_iam_role.evaluation_workload.arn
}

output "analytics_workload_role_arn" {
  description = "ARN da IAM Role do analytics-service"
  value       = aws_iam_role.analytics_workload.arn
}

output "db_init_workload_role_arn" {
  description = "ARN da IAM Role do Job de inicializacao dos bancos"
  value       = aws_iam_role.db_init_workload.arn
}