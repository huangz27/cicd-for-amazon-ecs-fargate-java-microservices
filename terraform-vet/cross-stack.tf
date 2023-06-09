data "terraform_remote_state" "cross_stack_ref" {
  backend = "local"
  config = {
    path = "../terraform/terraform.tfstate"
  }
}

#------- secrets manager ------------
data "aws_secretsmanager_secret" "password" {
  name = "mysql-rds-db-secret"
}

data "aws_secretsmanager_secret_version" "password" {
  secret_id = data.aws_secretsmanager_secret.password.arn
}

#------- get private subnet ids for fargate ------------
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.cross_stack_ref.outputs.vpc_id]
  }

  tags = {
    Type = "PrivateSubnet"
  }
}
#------- get ecs cluster arn ------------
data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = data.terraform_remote_state.cross_stack_ref.outputs.ecs_cluster_name
}

#------- get alb listener arn ------------
data "aws_alb_listener" "selected80" {
  load_balancer_arn = data.terraform_remote_state.cross_stack_ref.outputs.alb_arn
  port              = 80
}