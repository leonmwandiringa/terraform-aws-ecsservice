output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.default.name
}

output "service_arn" {
  description = "ECS Service ARN"
  value       = aws_ecs_service.default.id
}