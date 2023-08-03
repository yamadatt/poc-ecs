resource "aws_ecr_repository" "main" {
  name         = "yamada-ecs-helloworld"
  force_delete = true
}


resource "aws_ecr_lifecycle_policy" "main" {
  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Hold only 10 images, expire all others",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : 10,
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )

  repository = aws_ecr_repository.main.name
}

output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}