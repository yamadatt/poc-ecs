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
      mountPoints = [
        {
          containerPath = "/mnt/efs"
          sourceVolume  = "fargate-efs"
        },
                {
          containerPath = "/mnt/efs2"
          sourceVolume  = "fargate-efs"
        }
      ]
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
  volume {
    name = "fargate-efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }

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

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = local.container_name
    container_port   = 8091
  }
}
