provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-cluster"
}

resource "aws_ecs_task_definition" "jenkins_task" {
  family                   = "jenkins-task"
  network_mode             = "awsvpc"
  container_definitions    = jsonencode([
    {
      name                    = "jenkins-container"
      image                   = var.jenkins_docker_image
      cpu                     = 256
      memory                  = 512
      essential               = true
      portMappings = [
        {
          containerPort       = 8080
          hostPort            = 8080
        },
        {
          containerPort       = 50000
          hostPort            = 50000
        }
      ]
      environment = [
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = var.aws_access_key_id
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = var.aws_secret_access_key
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "jenkins_service" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }
}

resource "aws_codebuild_project" "jenkins_build" {
  name          = "jenkins-build"
  description   = "CodeBuild project for building Jenkins Docker image"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/DavidNasirov/JavaDummy"
    buildspec       = "buildspec.yml"
  }

  artifacts {
    type            = "NO_ARTIFACTS"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_integration_policy" {
  name        = "ecs_integration_policy"
  description = "Policy for ECS integration with CodeBuild"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_integration_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.ecs_integration_policy.arn
}
