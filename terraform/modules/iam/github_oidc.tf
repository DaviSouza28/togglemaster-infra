resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name    = "github-actions-oidc"
    Projeto = "MBA DevOps"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:DaviSouza28@59304635/togglemaster-auth@1357325627:ref:refs/heads/main",
        "repo:DaviSouza28@59304635/togglemaster-flag@1357325692:ref:refs/heads/main",
        "repo:DaviSouza28@59304635/togglemaster-targeting@1357325736:ref:refs/heads/main",
        "repo:DaviSouza28@59304635/togglemaster-evaluation@1357325790:ref:refs/heads/main",
        "repo:DaviSouza28@59304635/togglemaster-analytics@1357326030:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "togglemaster-github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name    = "togglemaster-github-actions-role"
    Projeto = "MBA DevOps"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "togglemaster-github-actions-ecr-policy"
  description = "Permite que GitHub Actions publique imagens nos repositorios ECR do ToggleMaster"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = [
          "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/togglemaster-auth",
          "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/togglemaster-flag",
          "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/togglemaster-targeting",
          "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/togglemaster-evaluation",
          "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/togglemaster-analytics"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
