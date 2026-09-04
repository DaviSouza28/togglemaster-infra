module "networking" {
  source = "./modules/networking"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "iam" {
  source = "./modules/iam"

  sqs_queue_arn      = module.data_services.sqs_queue_arn
  dynamodb_table_arn = module.data_services.dynamodb_table_arn

  auth_db_secret_arn      = module.data_services.auth_db_secret_arn
  flag_db_secret_arn      = module.data_services.flag_db_secret_arn
  targeting_db_secret_arn = module.data_services.targeting_db_secret_arn
}

module "eks" {
  source = "./modules/eks"

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
  subnet_ids       = module.networking.private_subnet_ids

  evaluation_workload_role_arn = module.iam.evaluation_workload_role_arn
  analytics_workload_role_arn  = module.iam.analytics_workload_role_arn
  db_init_workload_role_arn    = module.iam.db_init_workload_role_arn

  admin_principal_arn = var.eks_admin_principal_arn
}

module "data_services" {
  source = "./modules/data_services"

  vpc_id             = module.networking.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.networking.private_subnet_ids

  auth_db_password      = var.auth_db_password
  flag_db_password      = var.flag_db_password
  targeting_db_password = var.targeting_db_password
}