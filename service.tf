resource "aws_ecs_service" "default" {
  name                               = var.service_name
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = length(var.ec2_capacity_provider) > 0 ? null : var.launch_type 
  platform_version                   = var.launch_type == "FARGATE" && length(var.ec2_capacity_provider) == 0 ? var.platform_version : null
  scheduling_strategy                = var.scheduling_strategy
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  iam_role                           = var.service_role_arn
  wait_for_steady_state              = var.wait_for_steady_state
  force_new_deployment               = var.force_new_deployment
  enable_execute_command             = var.exec_enabled

  dynamic "load_balancer" {
    for_each = var.ecs_load_balancers
    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = lookup(load_balancer.value, "elb_name", null)
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.ec2_capacity_provider
    content {
      capacity_provider = capacity_provider_strategy.value.name
      base              = capacity_provider_strategy.value.base
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_namespace != null ? [var.service_connect_namespace] : []
    content {
      enabled = true
      namespace = var.service_connect_namespace
    }
  }

  cluster        = var.ecs_cluster_arn
  propagate_tags = var.propagate_tags
  tags           = merge(
    var.tags,
    {
      Name = "${var.service_name}-service"
    }
  )

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? ["true"] : []
    content {
      security_groups  = var.security_group_ids
      subnets          = var.subnet_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_controller_type == "ECS" ? ["true"] : []
    content {
      enable   = var.circuit_breaker_deployment_enabled
      rollback = var.circuit_breaker_rollback_enabled
    }
  }
}
