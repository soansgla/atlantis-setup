# AWS ECS Task Execution Role
output "aws_iam_role_ecs_task_execution_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.ecs_task_execution_role.arn
}
output "aws_iam_role_ecs_task_execution_role_create_date" {
  description = "The creation date of the IAM role."
  value       = aws_iam_role.ecs_task_execution_role.create_date
}
output "aws_iam_role_ecs_task_execution_role_description" {
  description = "The description of the role."
  value       = aws_iam_role.ecs_task_execution_role.description
}
output "aws_iam_role_ecs_task_execution_role_id" {
  description = "The ID of the role."
  value       = aws_iam_role.ecs_task_execution_role.id
}
output "aws_iam_role_ecs_task_execution_role_name" {
  description = "The name of the role."
  value       = aws_iam_role.ecs_task_execution_role.name
}
output "aws_iam_role_ecs_task_execution_role_unique_id" {
  description = "The stable and unique string identifying the role."
  value       = aws_iam_role.ecs_task_execution_role.unique_id
}

# ECS Task Definition
output "aws_ecs_task_definition_td_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = data.aws_ecs_task_definition.default.id
}
output "aws_ecs_task_definition_td_family" {
  description = "The family of the Task Definition."
  value       = aws_ecs_task_definition.default.family
}
output "aws_ecs_task_definition_td_revision" {
  description = "The revision of the task in a particular family."
  value       = data.aws_ecs_task_definition.default.revision
}
output "container_name" {
  description = "Name of the container"
  value       = var.container_name
}
output "log_configuration_awslogs_group" {
  description = "Name of the AWS logs group in the log configuration if specified"
  value       = one(aws_cloudwatch_log_group.this.*.name)
}
