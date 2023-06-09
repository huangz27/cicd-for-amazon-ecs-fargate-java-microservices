# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.stack}-Cluster"
}

output "ecs_cluster_name"{
  value = aws_ecs_cluster.ecs-cluster.name
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK DEFINITION USING FARGATE
# ---------------------------------------------------------------------------------------------------------------------

# resource "aws_ecs_task_definition" "petclinic_taskdef" {
#   family                = "petclinic"
#   container_definitions = "${data.template_file.petclinic-container.rendered}"

#   lifecycle {
#     create_before_destroy = true
#   }
# }


resource "aws_ecs_task_definition" "task-def" {
  family                   = var.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  //task_role_arn            = "${aws_iam_role.ecs-tasks-service-role.arn}"
  execution_role_arn       = aws_iam_role.tasks-service-role.arn
  # container_definitions = data.template_file.petclinic-container.rendered
  # container_definitions = file("petclinic.json")

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.image_repo.repository_url}",
    "memory": ${var.fargate_memory},
    "name": "${var.family}",
    "networkMode": "awsvpc",
    "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${var.cw_log_group}",
                "awslogs-region": "${var.aws_region}",
                "awslogs-stream-prefix": "${var.cw_log_stream}"
            }
        },
    "secrets": [{
      "name": "spring.datasource.password",
      "valueFrom": "${data.aws_secretsmanager_secret.password.arn}"
      }],
    "environment": [

            {
                "name": "spring.datasource.username",
                "value": "${var.db_user}"
            },
            {
                "name": "spring.datasource.initialize",
                "value": "${var.db_initialize}"
            },
            {
                "name": "spring.profiles.active",
                "value": "${var.db_profile}"
            },
            {
                "name": "spring.datasource.url",
                "value": "jdbc:mysql://${aws_db_instance.db.address}/${var.db_name}"
            }
        ],
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
DEFINITION
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name            = "${var.stack}-Service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = var.task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.task-sg.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.trgp.id
    container_name   = var.family
    container_port   = var.container_port
  }

  depends_on = [
    aws_alb_listener.alb-listener,
  ]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "target tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 70
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "petclinic-cw-lgrp" {
  name = var.cw_log_group
}

