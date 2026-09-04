# ============================================================
# RANDOM PASSWORDS
# ============================================================

resource "random_password" "auth_db" {
  length           = 24
  special          = true
  override_special = "!#$%&*+-=?@_"
}

resource "random_password" "flag_db" {
  length           = 24
  special          = true
  override_special = "!#$%&*+-=?@_"
}

resource "random_password" "targeting_db" {
  length           = 24
  special          = true
  override_special = "!#$%&*+-=?_"
}

# ============================================================
# SECURITY GROUP - DATA SERVICES
# ============================================================

resource "aws_security_group" "data_services" {
  name        = "togglemaster-data-services-sg"
  description = "Acesso aos servicos de dados do ToggleMaster"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL dentro da VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Redis dentro da VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Saida para a VPC/Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "togglemaster-data-services-sg"
    Projeto = "MBA DevOps"
  }
}

# ============================================================
# RDS SUBNET GROUP
# ============================================================

resource "aws_db_subnet_group" "main" {
  name       = "togglemaster-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "togglemaster-rds-subnet-group"
    Projeto = "MBA DevOps"
  }
}

# ============================================================
# RDS - AUTH
# ============================================================

resource "aws_db_instance" "auth" {
  identifier = "togglemaster-auth-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "authdb"
  username = "postgres"
  password = var.auth_db_password

  port = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.data_services.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name    = "togglemaster-auth-db"
    Projeto = "MBA DevOps"
    Servico = "Auth"
  }
}

# ============================================================
# RDS - FLAG
# ============================================================

resource "aws_db_instance" "flag" {
  identifier = "togglemaster-flag-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "flagdb"
  username = "postgres"
  password = var.flag_db_password

  port = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.data_services.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name    = "togglemaster-flag-db"
    Projeto = "MBA DevOps"
    Servico = "Flag"
  }
}

# ============================================================
# RDS - TARGETING
# ============================================================

resource "aws_db_instance" "targeting" {
  identifier = "togglemaster-targeting-db"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "targetingdb"
  username = "postgres"
  password = var.targeting_db_password

  port = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.data_services.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name    = "togglemaster-targeting-db"
    Projeto = "MBA DevOps"
    Servico = "Targeting"
  }
}

# ============================================================
# ELASTICACHE SUBNET GROUP
# ============================================================

resource "aws_elasticache_subnet_group" "main" {
  name       = "togglemaster-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "togglemaster-redis-subnet-group"
    Projeto = "MBA DevOps"
  }
}

# ============================================================
# ELASTICACHE REDIS
# ============================================================

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "togglemaster-redis"
  description          = "Redis do projeto ToggleMaster"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.t3.micro"

  num_cache_clusters = 1
  port               = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.data_services.id]

  automatic_failover_enabled = false
  multi_az_enabled           = false

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  tags = {
    Name    = "togglemaster-redis"
    Projeto = "MBA DevOps"
  }
}

# ============================================================
# DYNAMODB
# ============================================================

resource "aws_dynamodb_table" "analytics" {
  name         = "ToggleMasterAnalytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  tags = {
    Name    = "ToggleMasterAnalytics"
    Projeto = "MBA DevOps"
    Servico = "Analytics"
  }
}

# ============================================================
# SQS
# ============================================================

resource "aws_sqs_queue" "analytics" {
  name = "togglemaster-analytics"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  sqs_managed_sse_enabled = true

  tags = {
    Name    = "togglemaster-analytics"
    Projeto = "MBA DevOps"
    Servico = "Analytics"
  }
}

# ============================================================
# ECR
# ============================================================

locals {
  ecr_repositories = toset([
    "togglemaster-auth",
    "togglemaster-flag",
    "togglemaster-targeting",
    "togglemaster-evaluation",
    "togglemaster-analytics",
    "togglemaster-db-init"
  ])
}

resource "aws_ecr_repository" "services" {
  for_each = local.ecr_repositories

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = each.value
    Projeto = "MBA DevOps"
  }
}

# ============================================================
# ECR LIFECYCLE POLICY
# Mantem apenas as imagens mais recentes para reduzir custos.
# ============================================================

resource "aws_ecr_lifecycle_policy" "services" {
  for_each = aws_ecr_repository.services

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter somente as 10 imagens mais recentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================================
# SECRETS MANAGER - AUTH DATABASE
# ============================================================

resource "aws_secretsmanager_secret" "auth_db" {
  name                    = "togglemaster/auth-db"
  recovery_window_in_days = 0

  tags = {
    Name    = "togglemaster-auth-db-secret"
    Projeto = "MBA DevOps"
    Servico = "Auth"
  }
}

resource "aws_secretsmanager_secret_version" "auth_db" {
  secret_id = aws_secretsmanager_secret.auth_db.id

  secret_string = jsonencode({
    username = "postgres"
    password = var.auth_db_password
    database = "authdb"
    host     = aws_db_instance.auth.address
    port     = 5432
  })
}

# ============================================================
# SECRETS MANAGER - FLAG DATABASE
# ============================================================

resource "aws_secretsmanager_secret" "flag_db" {
  name                    = "togglemaster/flag-db"
  recovery_window_in_days = 0

  tags = {
    Name    = "togglemaster-flag-db-secret"
    Projeto = "MBA DevOps"
    Servico = "Flag"
  }
}

resource "aws_secretsmanager_secret_version" "flag_db" {
  secret_id = aws_secretsmanager_secret.flag_db.id

  secret_string = jsonencode({
    username = "postgres"
    password = var.flag_db_password
    database = "flagdb"
    host     = aws_db_instance.flag.address
    port     = 5432
  })
}

# ============================================================
# SECRETS MANAGER - TARGETING DATABASE
# ============================================================

resource "aws_secretsmanager_secret" "targeting_db" {
  name                    = "togglemaster/targeting-db"
  recovery_window_in_days = 0

  tags = {
    Name    = "togglemaster-targeting-db-secret"
    Projeto = "MBA DevOps"
    Servico = "Targeting"
  }
}

resource "aws_secretsmanager_secret_version" "targeting_db" {
  secret_id = aws_secretsmanager_secret.targeting_db.id

  secret_string = jsonencode({
    username = "postgres"
    password = var.targeting_db_password
    database = "targetingdb"
    host     = aws_db_instance.targeting.address
    port     = 5432
  })
}