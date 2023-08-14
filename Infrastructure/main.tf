module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "my-test-vpc"
  cidr = "192.168.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["192.168.10.0/24", "192.168.20.0/24"]
  public_subnets  = ["192.168.30.0/24", "192.168.40.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false
  tags = {
    Terraform = "true"
    Environment = "test"
  }
  map_public_ip_on_launch = true
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/ecs/rn"
  retention_in_days = 14

  tags = {
    Environment = "sandbox"
    Application = "my-app"
  }
}

resource "aws_lb" "test_app" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_app_lb.id]
  subnets            = toset(module.vpc.public_subnets)
  enable_deletion_protection = false
  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.test_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_security_group" "test_app_lb" {
  name        = "test-app-sg-lb"
  description = "Allow 80 port inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_http_lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_lb.id
}

resource "aws_security_group_rule" "allow_http_outbound_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_lb.id
}

resource "aws_ecr_repository" "my_repo" {
  name                 = "my-ecr-01"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my_cluster_name"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_ecr_policy" {
  name        = "ecs-ecr-policy"
  description = "IAM policy for ECS to interact with ECR"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "${aws_ecr_repository.my_repo.arn}"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_policy_attach01" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_full_access.arn
}

data "aws_iam_policy" "cloudwatch_full_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

output "public_subnets" {
  value = toset(module.vpc.public_subnets)
}

output "alb_dns_name" {
  value = aws_lb.test_app.dns_name
}
