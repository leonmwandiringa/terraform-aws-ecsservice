resource "aws_ecs_task_definition" "default" {
  family                   = "${var.service_name}-task"
  container_definitions    = var.container_definition_json
  requires_compatibilities = length(var.ec2_capacity_provider) > 0 ? ["EC2"] : [var.launch_type]
  network_mode             = var.network_mode
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_exec_role_arn
  task_role_arn            = var.task_role_arn

  dynamic "runtime_platform" {
    for_each = var.runtime_platform
    content {
      operating_system_family = lookup(runtime_platform.value, "operating_system_family", null)
      cpu_architecture        = lookup(runtime_platform.value, "cpu_architecture", null)
    }
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      host_path = lookup(volume.value, "host_path", null)
      name      = volume.value.name
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.service_name}-task"
    }
  )
}