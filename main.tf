locals {
  # Container definitions
  container_definitions = var.custom_container_definitions == "" ? module.container_definition.json : var.custom_container_definitions
  jwt_secret_key        = var.env_jwt_secret_key == "" ? random_string.jwt.result : var.env_jwt_secret_key

  container_definition_environment = [
    {
      name  = "JWT_SECRET_KEY"
      value = local.jwt_secret_key
    },
    {
      name  = "FLASK_ENV"
      value = var.env_flask_env == "" ? "development" : var.env_flask_env
    },
    {
      name  = "FLASK_DEBUG"
      value = var.env_flask_env == "production" ? 0 : 1
    },
    {
      name  = "DATABASE_URI"
      value = var.evn_database_uri
    },
  ]

  tags = merge(
    var.tags,
    {
      Project = var.project
    },
  )
}

data "aws_region" "current" {
}

###################
# JWT TOKEN KEY
###################
resource "random_string" "jwt" {
  length = 32
}

###################
# ECR
###################
resource "aws_ecr_repository" "this" {
  name = format("%s-%s-ecr", var.project, var.environment)
  tags = merge(
    local.tags,
    {
      "Name" = format("%s-%s-ecr", var.project, var.environment)
    },
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

}

###################
# ECS
###################
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "~> v2.0"

  name = format("%s-%s-ecs", var.project, var.environment)
}

resource "aws_iam_role" "ecs_task_execution" {
  name = format("%s-%s-ecs_task_execution", var.project, var.environment)

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = length(var.policies_arn)

  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = element(var.policies_arn, count.index)
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.15.0"

  container_name  = var.project
  container_image = format("%s:latest", aws_ecr_repository.this.repository_url)

  container_cpu                = var.ecs_task_cpu
  container_memory             = var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation

  port_mappings = [
    {
      containerPort = var.api_port
      hostPort      = var.api_port
      protocol      = "tcp"
    },
  ]

  log_options = {
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-group"         = aws_cloudwatch_log_group.this.name
      "awslogs-stream-prefix" = "ecs"
  }

  environment = concat(local.container_definition_environment, var.custom_environment_variables, )
}

resource "aws_ecs_task_definition" "this" {
  family                   = format("%s-%s", var.project, var.environment)
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  container_definitions = local.container_definitions
}

data "aws_ecs_task_definition" "this" {
  task_definition = format("%s-%s", var.project, var.environment)
  depends_on      = [aws_ecs_task_definition.this]
}

resource "aws_ecs_service" "this" {
  name    = format("%s-%s-esc-service", var.project, var.environment)
  cluster = module.ecs.this_ecs_cluster_id
  
  task_definition = "${data.aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision, )}"

  desired_count                      = var.ecs_service_desired_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  load_balancer {
    container_name   = var.project
    container_port   = var.api_port
    target_group_arn = var.target_group_arn
  }
}

###################
# Cloudwatch logs
###################
resource "aws_cloudwatch_log_group" "this" {
  name              = format("%s/%s/logs/esc", var.project, var.environment)
  retention_in_days = var.cloudwatch_log_retention_in_days

  tags = merge(
    local.tags,
    {
      Name = format("%s-%s-logs", var.project, var.environment)
    },
  )
}
