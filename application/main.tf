data "aws_caller_identity" "current" {}

locals {
  my_aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_lb_target_group" "test" {
  name = "my-tg"
}

data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = "my_cluster_name"
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
}

data "aws_vpc" "myvpc" {
  filter {
    name = "tag:Name"
    values = ["my-test-vpc"]
  }
}

data "aws_subnet" "publicsubnet01" {
  filter {
    name   = "tag:Name"
    values = ["my-test-vpc-public-us-east-1a"]
  }

}

data "aws_subnet" "publicsubnet02" {
  filter {
    name   = "tag:Name"
    values = ["my-test-vpc-public-us-east-1b"]
  }

}

resource "aws_security_group" "test_ecs_service" {
  name        = "test-app-sg-ecs-service"
  description = "Allow  inbound traffic"
  vpc_id      = data.aws_vpc.myvpc.id
}

resource "aws_security_group_rule" "allow_http_lb" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_ecs_service.id
}

resource "aws_security_group_rule" "allow_http_outbound_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_ecs_service.id
}

resource "aws_ecs_task_definition" "ecs_task_defintion_rn" {
  family                   = "rn-tesk-defintion"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "rn_test"
    image = "${local.my_aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/my-ecr-01:latest"
    portMappings = [{
      containerPort = 5000,
      hostPort      = 5000
    }],
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "/aws/ecs/rn",
        "awslogs-region" : "us-east-1",
        "awslogs-stream-prefix" : "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "ecs_service_rn" {
  name            = "ecs_service_rn"
  cluster         = data.aws_ecs_cluster.ecs-cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_defintion_rn.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.publicsubnet01.id, data.aws_subnet.publicsubnet02.id]
    security_groups  = [aws_security_group.test_ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.test.arn
    container_name   = "rn_test"
    container_port   = 5000
  }

  desired_count = 1
}
