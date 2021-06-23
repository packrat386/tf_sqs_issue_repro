terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.25"
    }
  }
}

locals {
  message_group_id = null
}

terraform {
  backend "local" {}
}

provider "aws" {
  alias  = "va"
  region = "us-east-1"
}

resource "aws_sqs_queue" "test_queue" {
  provider = aws.va
  name     = "terraform_test_queue"
}

resource "aws_cloudwatch_event_rule" "test_rule" {
  provider            = aws.va
  name                = "test_rule"
  description         = "Send a message at a set interval to kick off a job."
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "test_rule_target" {
  provider = aws.va
  rule     = aws_cloudwatch_event_rule.test_rule.name
  arn      = aws_sqs_queue.test_queue.arn

  input = jsonencode({
    foo = "bar"
  })

  sqs_target {
    message_group_id = local.message_group_id
  }
}

