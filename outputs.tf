output "cloudwatch_log_name" {
  description = "cloudwatch log name"
  value       = "${aws_cloudwatch_log_group.this.name}"
}

output "this_ecr_uri" {
  value = "${aws_ecr_repository.this.repository_url}"
}

output "this_ecs_cluster_id" {
  value = "${module.ecs.this_ecs_cluster_id}"
}

output "this_ecs_cluster_arn" {
  value = "${module.ecs.this_ecs_cluster_arn}"
}

output "jwt_secret_key" {
  value = "${local.jwt_secret_key}"
}
