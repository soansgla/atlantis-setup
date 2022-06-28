# AWS ECS SERVICE

output "aws_ecs_service_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service."
  value       = aws_ecs_service.default.id
}

output "aws_ecs_service_service_name" {
  description = "The name of the service."
  value       = aws_ecs_service.default.name
}

output "aws_ecs_service_service_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_service.default.cluster
}

output "aws_ecs_service_service_desired_count" {
  description = "The number of instances of the task definition"
  value       = aws_ecs_service.default.desired_count
}

output "name_prefix" {
  description = "Name prefix for ECS service"
  value       = var.name_prefix
}

# AWS ECS TASK SECURITY GROUPS

output "ecs_tasks_sg_id" {
  description = "$${var.name_prefix} ECS Tasks Security Group - The ID of the security group"
  value       = aws_security_group.ecs_tasks_sg.id
}

output "ecs_tasks_sg_arn" {
  description = "$${var.name_prefix} ECS Tasks Security Group - The ARN of the security group"
  value       = aws_security_group.ecs_tasks_sg.arn
}

output "ecs_tasks_sg_name" {
  description = "$${var.name_prefix} ECS Tasks Security Group - The name of the security group"
  value       = aws_security_group.ecs_tasks_sg.name
}

output "ecs_tasks_sg_description" {
  description = "$${var.name_prefix} ECS Tasks Security Group - The description of the security group"
  value       = aws_security_group.ecs_tasks_sg.description
}

# AWS APPLICATION LOAD BALANCER

output "aws_lb_lb_id" {
  description = "The ARN of the load balancer (matches arn)."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_lb_lb_id : null
}

output "aws_lb_lb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_lb_lb_arn : null
}

output "aws_lb_lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_lb_lb_arn_suffix : null
}

output "aws_lb_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_lb_lb_dns_name : null
}

output "aws_lb_lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_lb_lb_zone_id : null
}


# ACCESS CONTROL TO APPLICATION LOAD BALANCER

output "aws_security_group_lb_access_sg_id" {
  description = "The ID of the security group for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_id : null
}

output "aws_security_group_lb_access_sg_arn" {
  description = "The ARN of the security group for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_arn : null
}

output "aws_security_group_lb_access_sg_vpc_id" {
  description = "The VPC ID."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_vpc_id : null
}

output "aws_security_group_lb_access_sg_owner_id" {
  description = "The owner ID."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_owner_id : null
}

output "aws_security_group_lb_access_sg_name" {
  description = "The name of the security group for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_name : null
}

output "aws_security_group_lb_access_sg_description" {
  description = "The description of the security group for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_description : null
}

output "aws_security_group_lb_access_sg_ingress" {
  description = "The ingress rules of the security group for ALB."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_ingress : null
}

output "aws_security_group_lb_access_sg_egress" {
  description = "The egress rules of the security group for ALB."
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.aws_security_group_lb_access_sg_egress : null
}

# AWS APPLICATION LOAD BALANCER - Target Groups

output "lb_https_tgs_ids" {
  description = "List of HTTPS Target Groups IDs for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.lb_https_tgs_ids : null
}

output "lb_https_tgs_arns" {
  description = "List of HTTPS Target Groups ARNs for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.lb_https_tgs_arns : null
}

output "lb_https_tgs_names" {
  description = "List of HTTPS Target Groups Names for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.lb_https_tgs_names : null
}



# AWS APPLICATION LOAD BALANCER - Listeners

output "lb_https_listeners_ids" {
  description = "List of HTTPS Listeners IDs for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.lb_https_listeners_ids : null
}

output "lb_https_listeners_arns" {
  description = "List of HTTPS Listeners ARNs for ALB"
  value       = length(module.ecs_alb) > 0 ? module.ecs_alb.lb_https_listeners_arns : null
}


