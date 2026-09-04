# ============================================================
# IAM PARA WORKLOADS DO EKS
# ============================================================


# ============================================================
# POLICY - EVALUATION SERVICE / SQS
# ============================================================

resource "aws_iam_policy" "evaluation_sqs" {
  name        = "togglemaster-evaluation-sqs"
  description = "Permite ao evaluation-service publicar eventos na fila SQS"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      }
    ]
  })
}


# ============================================================
# POLICY - ANALYTICS SERVICE / SQS + DYNAMODB
# ============================================================

resource "aws_iam_policy" "analytics_sqs_dynamodb" {
  name        = "togglemaster-analytics-sqs-dynamodb"
  description = "Permite ao analytics-service consumir SQS e gravar no DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem"
        ]

        Resource = var.dynamodb_table_arn
      }
    ]
  })
}


# ============================================================
# ROLE - EVALUATION SERVICE
# ============================================================

resource "aws_iam_role" "evaluation_workload" {
  name = "togglemaster-evaluation-workload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name    = "togglemaster-evaluation-workload"
    Projeto = "MBA DevOps"
    Servico = "Evaluation"
  }
}


# ============================================================
# ROLE - ANALYTICS SERVICE
# ============================================================

resource "aws_iam_role" "analytics_workload" {
  name = "togglemaster-analytics-workload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name    = "togglemaster-analytics-workload"
    Projeto = "MBA DevOps"
    Servico = "Analytics"
  }
}


# ============================================================
# POLICY ATTACHMENT - EVALUATION / SQS
# ============================================================

resource "aws_iam_role_policy_attachment" "evaluation_sqs" {
  role       = aws_iam_role.evaluation_workload.name
  policy_arn = aws_iam_policy.evaluation_sqs.arn
}


# ============================================================
# POLICY ATTACHMENT - ANALYTICS / SQS + DYNAMODB
# ============================================================

resource "aws_iam_role_policy_attachment" "analytics_sqs_dynamodb" {
  role       = aws_iam_role.analytics_workload.name
  policy_arn = aws_iam_policy.analytics_sqs_dynamodb.arn
}


# ============================================================
# POLICY - SECRETS MANAGER / DATABASE CREDENTIALS
# ============================================================

resource "aws_iam_policy" "database_secrets" {
  name        = "togglemaster-database-secrets"
  description = "Permite aos workloads do ToggleMaster ler as credenciais dos bancos"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          var.auth_db_secret_arn,
          var.flag_db_secret_arn,
          var.targeting_db_secret_arn
        ]
      }
    ]
  })
}


# ============================================================
# POLICY ATTACHMENT - EVALUATION / DATABASE SECRETS
# ============================================================

resource "aws_iam_role_policy_attachment" "evaluation_database_secrets" {
  role       = aws_iam_role.evaluation_workload.name
  policy_arn = aws_iam_policy.database_secrets.arn
}


# ============================================================
# POLICY ATTACHMENT - ANALYTICS / DATABASE SECRETS
# ============================================================

resource "aws_iam_role_policy_attachment" "analytics_database_secrets" {
  role       = aws_iam_role.analytics_workload.name
  policy_arn = aws_iam_policy.database_secrets.arn
}


# ============================================================
# ROLE - DATABASE INITIALIZATION JOB
# ============================================================

resource "aws_iam_role" "db_init_workload" {
  name = "togglemaster-db-init-workload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name    = "togglemaster-db-init-workload"
    Projeto = "MBA DevOps"
    Servico = "Database Initialization"
  }
}


# ============================================================
# POLICY - DATABASE INITIALIZATION / SECRETS MANAGER
# ============================================================

resource "aws_iam_policy" "db_init_secrets" {
  name        = "togglemaster-db-init-secrets"
  description = "Permite ao Job de inicializacao ler as credenciais dos bancos"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          var.auth_db_secret_arn,
          var.flag_db_secret_arn,
          var.targeting_db_secret_arn
        ]
      }
    ]
  })
}


# ============================================================
# POLICY ATTACHMENT - DATABASE INITIALIZATION
# ============================================================

resource "aws_iam_role_policy_attachment" "db_init_secrets" {
  role       = aws_iam_role.db_init_workload.name
  policy_arn = aws_iam_policy.db_init_secrets.arn
}