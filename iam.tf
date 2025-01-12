# タスク起動用IAMロールの定義
resource "aws_iam_role" "ecs_execution" {
  name = "ecsTasExecRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecsTaskExecRole"
  }
}

# タスク起動＋CloudwatchLogsのポリシーの作成
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ecs_task_execution_policy"
  description = "Policy for ECS Task Execution Role to use CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:log-group:/ecs/*",
          "arn:aws:logs:*:*:log-group:/ecs/*:log-stream:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}


# タスク起動用IAMロールへのポリシー割り当て
#resource "aws_iam_role_policy_attachment" "ecs_execution" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#  role       = aws_iam_role.ecs_execution.name
#}

# タスク起動用IAMロールへのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}









# コンテナ用IAMロールの定義
resource "aws_iam_role" "ecs_task" {
  name = "yamada_ecs_task_role_name"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecs_task_role"
  }
}


# コンテナ用IAMポリシーの定義
resource "aws_iam_policy" "ecs_task" {
  name = "yamada-task-role"
  path = "/service-role/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ]
  })

  tags = {
    Name = "yamada-task-role-tag"
  }
}

# コンテナ用IAMロールへのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_task" {
  policy_arn = aws_iam_policy.ecs_task.arn
  role       = aws_iam_role.ecs_task.name
}





