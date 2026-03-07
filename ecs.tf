data "aws_caller_identity" "self" {}

locals {
  container_name = "golang-helloworld"
}

resource "aws_ecs_cluster" "main" {
  name = "yamada-ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "yamada-ecs-task-definition"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = "${local.container_name}"
      image     = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/yamatest"
      essential = true
      portMappings = [
        {
          name          = "${local.container_name}"
          containerPort = 8091
          hostPort      = 8091
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      # mountPoints = [
      #   {
      #     containerPath = "/mnt/efs"
      #     sourceVolume  = "fargate-efs"
      #   },
      #   {
      #     containerPath = "/mnt/efs2"
      #     sourceVolume  = "fargate-efs"
      #   }
      # ]
      essential = true
      logConfiguration = {
        logDriver : "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/yamada-ecs-task-definition"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  # volume {
  #   name = "fargate-efs"
  #   efs_volume_configuration {
  #     file_system_id = aws_efs_file_system.efs.id
  #     root_directory = "/efs1"
  #   }
  # }
  # {
  #   name = "fargate-efs2"
  #   efs_volume_configuration {
  #     file_system_id = aws_efs_file_system.efs.id
  #     root_directory = "/efs2"
  #   }
  # }



}

resource "aws_ecs_service" "main" {
  name                   = "yamada-ecs-service"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.main.arn
  launch_type            = "FARGATE"
  enable_execute_command = true #ECS EXECの有効

  desired_count = 1



  network_configuration {
    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]
    security_groups = [
      aws_security_group.contaner_sg.id
    ]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  deployment_configuration {
    strategy = "BLUE_GREEN" 
    bake_time_in_minutes = "1"

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = local.container_name
    container_port   = 8091
    advanced_configuration {
      alternate_target_group_arn = aws_lb_target_group.green.arn
      production_listener_rule = aws_lb_listener_rule.production.arn
      role_arn = aws_iam_role.ecs_infrastructure_role_for_load_balancers.arn
      test_listener_rule = aws_lb_listener_rule.test.arn
    }
  }
}

resource "aws_iam_role" "ecs_infrastructure_role_for_load_balancers" {
  name = "ecs-load-balancer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# ECS サービスがロードバランサーを管理するために必要なポリシー
resource "aws_iam_role_policy" "ecs_load_balancer_policy" {
  name = "ecs-load-balancer-policy"
  role = aws_iam_role.ecs_infrastructure_role_for_load_balancers.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECS Fargate では service-linked role が自動作成されるため、
# 従来の ECS サービスロールは不要
# resource "aws_iam_role" "ecs_service_role" は削除

#aws cloudwatch describe-alarms | jq -r '.MetricAlarms[] | [.AlarmName] | @csv'
#aws cloudwatch set-alarm-state --alarm-name "error-log-alarm" --state-value ALARM --state-reason "test"
#aws cloudwatch set-alarm-state --alarm-name "example-alarm" --state-value ALARM --state-reason "test"