
# ---------------------------------------------------------------------------------------------------------------------
# ALB TARGET GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "trgp" {
  name        = "${var.stack}-tgrp"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.cross_stack_ref.outputs.vpc_id
  target_type = "ip"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB LISTENER RULE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener_rule" "petclinic" {
  listener_arn = data.aws_alb_listener.selected80.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.trgp.arn
  }

  condition {
    path_pattern {
      values = ["/${var.api}*"]
    }
  }
}
