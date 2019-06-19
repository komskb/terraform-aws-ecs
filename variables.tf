variable "project" {
  description = "Project name to use on all resources created (VPC, ALB, etc)"
  type        = string
}

variable "environment" {
  description = "Deploy environment"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "A list of IDs of existing private subnets inside the VPC"
  type        = list(string)
  default     = []
}

# Cloudwatch
variable "cloudwatch_log_retention_in_days" {
  description = "Retention period of service CloudWatch logs"
  default     = 7
}

# ECS Service / Task
variable "security_groups" {
  description = "ALB target group arns"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group arn"
  type        = string
}

variable "ecs_service_assign_public_ip" {
  description = "Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)"
  default     = false
}

variable "policies_arn" {
  description = "A list of the ARN of the policies you want to apply"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "ecs_service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
}

variable "ecs_service_deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  default     = 200
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = 50
}

variable "ecs_task_cpu" {
  description = "The number of cpu units used by the task"
  default     = 256
}

variable "ecs_task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 512
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container"
  default     = 128
}

variable "custom_container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document. By default, the standard container definition is used."
  default     = ""
}

# Docker Image
variable "api_port" {
  description = "Local port service should be running on. Default value is most likely fine."
  default     = 5000
}

variable "env_jwt_secret_key" {
  description = "JWT Token secret key"
  type        = string
  default     = ""
}

variable "env_flask_env" {
  description = "Flask env"
  type        = string
  default     = "prodction"
}

variable "evn_database_uri" {
  description = "Database uri (ex: mysql://)"
  type        = string
  default     = ""
}

variable "custom_environment_variables" {
  description = "List of additional environment variables the container will use (list should contain maps with `name` and `value`)"
  type        = list(any)
  default     = []
}

