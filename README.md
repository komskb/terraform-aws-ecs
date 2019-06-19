# KOMSKB Framework Terraform AWS-ECS module 

AWS ECS를 생성하는 Terraform 모듈 입니다.

내부적으로 사용하는 리소스 및 모듈:

* [ECR](https://www.terraform.io/docs/providers/aws/r/ecr_repository.html)
* [ECS](https://github.com/terraform-aws-modules/terraform-aws-ecs)
* [Container Definition](https://github.com/cloudposse/terraform-aws-ecs-container-definition)
* [Cloudwatch Log Group](https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html)

## Usage

```hcl
module "ecs" {
  source = "komskb/ecs/aws"

  project = var.project
  environment = var.environment
  subnet_ids = [module.vpc.private_subnets]
  security_groups = [module.alb.security_group_id]
  target_group_arn = element(module.alb.target_group_arns, 0)
  env_jwt_secret_key = var.jwt_secret_key
  evn_database_uri = format("mysql+pymysql://%s:%s@%s:%s/%s?charset=utf8", module.rds.this_rds_cluster_master_username, module.rds.this_rds_cluster_master_password, module.rds.this_rds_cluster_endpoint, module.rds.this_rds_cluster_port, module.rds.this_rds_cluster_database_name)
  custom_environment_variables = [
    {
      name = "PROJECT"
      value = var.project
    },
    {
      name = "AWS_DEFAULT_REGION"
      value = var.region
    },
    {
      name = "AWS_ACCESS_KEY_ID"
      value = var.access_key
    },
    {
      name = "AWS_SECRET_ACCESS_KEY"
      value = var.secret_key
    }
  ]
  tags = {
    Terraform = var.terraform_repo
    Environment = var.environment
  }
}
```

## Terraform version

Terraform version 0.12.0 or newer is required for this module to work.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| api\_port | Local port service should be running on. Default value is most likely fine. | string | `"5000"` | no |
| cloudwatch\_log\_retention\_in\_days | Retention period of service CloudWatch logs | string | `"7"` | no |
| container\_memory\_reservation | The amount of memory (in MiB) to reserve for the container | string | `"128"` | no |
| custom\_container\_definitions | A list of valid container definitions provided as a single valid JSON document. By default, the standard container definition is used. | string | `""` | no |
| custom\_environment\_variables | List of additional environment variables the container will use (list should contain maps with `name` and `value`) | map(any) | `{}` | no |
| ecs\_service\_assign\_public\_ip | Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html) | string | `"false"` | no |
| ecs\_service\_deployment\_maximum\_percent | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment | string | `"200"` | no |
| ecs\_service\_deployment\_minimum\_healthy\_percent | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment | string | `"50"` | no |
| ecs\_service\_desired\_count | The number of instances of the task definition to place and keep running | string | `"1"` | no |
| ecs\_task\_cpu | The number of cpu units used by the task | string | `"256"` | no |
| ecs\_task\_memory | The amount (in MiB) of memory used by the task | string | `"512"` | no |
| env\_flask\_env | Flask env | string | `"prodction"` | no |
| env\_jwt\_secret\_key | JWT Token secret key | string | `""` | no |
| environment | Deploy environment | string | `"production"` | no |
| evn\_database\_uri | Database uri (ex: mysql://) | string | `""` | no |
| policies\_arn | A list of the ARN of the policies you want to apply | list(string) | `[ "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" ]` | no |
| project | Project name to use on all resources created (VPC, ALB, etc) | string | n/a | yes |
| security\_groups | ALB target group arns | list(string) | n/a | yes |
| subnet\_ids | A list of IDs of existing private subnets inside the VPC | list(string) | `[]` | no |
| tags | A map of tags to use on all resources | map(string) | `{}` | no |
| target\_group\_arn | ALB target group arn | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_name | cloudwatch log name |
| jwt\_secret\_key |  |
| this\_ecr\_uri |  |
| this\_ecs\_cluster\_arn |  |
| this\_ecs\_cluster\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained by [komskb](https://github.com/komskb).

## License

MIT licensed. See LICENSE for full details.
