
# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP FOR ECS TASKS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "task-sg" {
  name        = "${var.stack}-task-sg"
  description = "Allow inbound access to ECS tasks from the ALB only"
  vpc_id      = data.terraform_remote_state.cross_stack_ref.outputs.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [data.terraform_remote_state.cross_stack_ref.outputs.alb_sg_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.stack}-task-sg"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD SECURITY GROUP INGRESS TO RDS SG FROM ECS TASK 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = data.terraform_remote_state.cross_stack_ref.outputs.rds_sg_id

  referenced_security_group_id   = aws_security_group.task-sg.id
  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}
