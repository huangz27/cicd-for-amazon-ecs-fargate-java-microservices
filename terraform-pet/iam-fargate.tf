
# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "tasks-service-role" {
  name               = "${var.fargate-task-service-role}ECSTasksServiceRole" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tasks-service-assume-policy.json
}

data "aws_iam_policy_document" "tasks-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "tasks-service-role-attachment" {
  role       = aws_iam_role.tasks-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy" "secret_policy" {
  name = "get_secrets"
  role = aws_iam_role.tasks-service-role.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = data.aws_secretsmanager_secret.password.arn
      },
    ]
  })
}