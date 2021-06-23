tf_sqs_issue_repro
------------------

This repo reproduces an issue with the hashicorp AWS provider. It doesn't like an explicit null for the `sqs_target` block in an `aws_cloudwatch_event_target`

like so:
```
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

```

full code in main.tf

## Reproducing

init:
```
 [fg-386] repro > AWS_PROFIE=sandbox terraform init

Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 3.25.0"...
- Installing hashicorp/aws v3.46.0...
- Installed hashicorp/aws v3.46.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

plan:
```
 [fg-386] repro > AWS_PROFIE=sandbox terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_event_rule.test_rule will be created
  + resource "aws_cloudwatch_event_rule" "test_rule" {
      + arn                 = (known after apply)
      + description         = "Send a message at a set interval to kick off a job."
      + event_bus_name      = "default"
      + id                  = (known after apply)
      + is_enabled          = true
      + name                = "test_rule"
      + name_prefix         = (known after apply)
      + schedule_expression = "cron(0 12 * * ? *)"
      + tags_all            = (known after apply)
    }

  # aws_cloudwatch_event_target.test_rule_target will be created
  + resource "aws_cloudwatch_event_target" "test_rule_target" {
      + arn            = (known after apply)
      + event_bus_name = "default"
      + id             = (known after apply)
      + input          = jsonencode(
            {
              + foo = "bar"
            }
        )
      + rule           = "test_rule"
      + target_id      = (known after apply)

      + sqs_target {}
    }

  # aws_sqs_queue.test_queue will be created
  + resource "aws_sqs_queue" "test_queue" {
      + arn                               = (known after apply)
      + content_based_deduplication       = false
      + deduplication_scope               = (known after apply)
      + delay_seconds                     = 0
      + fifo_queue                        = false
      + fifo_throughput_limit             = (known after apply)
      + id                                = (known after apply)
      + kms_data_key_reuse_period_seconds = (known after apply)
      + max_message_size                  = 262144
      + message_retention_seconds         = 345600
      + name                              = "terraform_test_queue"
      + name_prefix                       = (known after apply)
      + policy                            = (known after apply)
      + receive_wait_time_seconds         = 0
      + tags_all                          = (known after apply)
      + url                               = (known after apply)
      + visibility_timeout_seconds        = 30
    }

Plan: 3 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

apply:
```
 [fg-386] repro > AWS_PROFIE=sandbox terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_event_rule.test_rule will be created
  + resource "aws_cloudwatch_event_rule" "test_rule" {
      + arn                 = (known after apply)
      + description         = "Send a message at a set interval to kick off a job."
      + event_bus_name      = "default"
      + id                  = (known after apply)
      + is_enabled          = true
      + name                = "test_rule"
      + name_prefix         = (known after apply)
      + schedule_expression = "cron(0 12 * * ? *)"
      + tags_all            = (known after apply)
    }

  # aws_cloudwatch_event_target.test_rule_target will be created
  + resource "aws_cloudwatch_event_target" "test_rule_target" {
      + arn            = (known after apply)
      + event_bus_name = "default"
      + id             = (known after apply)
      + input          = jsonencode(
            {
              + foo = "bar"
            }
        )
      + rule           = "test_rule"
      + target_id      = (known after apply)

      + sqs_target {}
    }

  # aws_sqs_queue.test_queue will be created
  + resource "aws_sqs_queue" "test_queue" {
      + arn                               = (known after apply)
      + content_based_deduplication       = false
      + deduplication_scope               = (known after apply)
      + delay_seconds                     = 0
      + fifo_queue                        = false
      + fifo_throughput_limit             = (known after apply)
      + id                                = (known after apply)
      + kms_data_key_reuse_period_seconds = (known after apply)
      + max_message_size                  = 262144
      + message_retention_seconds         = 345600
      + name                              = "terraform_test_queue"
      + name_prefix                       = (known after apply)
      + policy                            = (known after apply)
      + receive_wait_time_seconds         = 0
      + tags_all                          = (known after apply)
      + url                               = (known after apply)
      + visibility_timeout_seconds        = 30
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_cloudwatch_event_rule.test_rule: Creating...
aws_sqs_queue.test_queue: Creating...
aws_sqs_queue.test_queue: Creation complete after 1s [id=https://sqs.us-east-1.amazonaws.com/643927032162/terraform_test_queue]
aws_cloudwatch_event_rule.test_rule: Creation complete after 1s [id=test_rule]
aws_cloudwatch_event_target.test_rule_target: Creating...
╷
│ Error: Plugin did not respond
│
│   with aws_cloudwatch_event_target.test_rule_target,
│   on main.tf line 36, in resource "aws_cloudwatch_event_target" "test_rule_target":
│   36: resource "aws_cloudwatch_event_target" "test_rule_target" {
│
│ The plugin encountered an error, and failed to respond to the plugin.(*GRPCProvider).ApplyResourceChange call. The plugin logs may contain more details.
╵

Stack trace from the terraform-provider-aws_v3.46.0_x5 plugin:

panic: interface conversion: interface {} is nil, not map[string]interface {}

goroutine 138 [running]:
github.com/terraform-providers/terraform-provider-aws/aws.expandAwsCloudWatchEventTargetSqsParameters(0xc001374eb0, 0x1, 0x1, 0x593e8c0)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/src/github.com/hashicorp/terraform-provider-aws/aws/resource_aws_cloudwatch_event_target.go:673 +0x18b
github.com/terraform-providers/terraform-provider-aws/aws.buildPutTargetInputStruct(0xc001424c00, 0x7128d4f)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/src/github.com/hashicorp/terraform-provider-aws/aws/resource_aws_cloudwatch_event_target.go:518 +0x507
github.com/terraform-providers/terraform-provider-aws/aws.resourceAwsCloudWatchEventTargetCreate(0xc001424c00, 0x632bc80, 0xc0012e4000, 0x0, 0xffffffffffffffff)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/src/github.com/hashicorp/terraform-provider-aws/aws/resource_aws_cloudwatch_event_target.go:334 +0x18f
github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema.(*Resource).create(0xc000839420, 0x7c74908, 0xc001423240, 0xc001424c00, 0x632bc80, 0xc0012e4000, 0x0, 0x0, 0x0)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/github.com/hashicorp/terraform-plugin-sdk/v2@v2.6.1/helper/schema/resource.go:318 +0x1ee
github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema.(*Resource).Apply(0xc000839420, 0x7c74908, 0xc001423240, 0xc0007edb90, 0xc00007f300, 0x632bc80, 0xc0012e4000, 0x0, 0x0, 0x0, ...)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/github.com/hashicorp/terraform-plugin-sdk/v2@v2.6.1/helper/schema/resource.go:456 +0x67b
github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema.(*GRPCProviderServer).ApplyResourceChange(0xc000120d98, 0x7c74908, 0xc001423240, 0xc001bb03c0, 0xc001423240, 0x6f07b20, 0xc001461f00)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/github.com/hashicorp/terraform-plugin-sdk/v2@v2.6.1/helper/schema/grpc_provider.go:955 +0x8ef
github.com/hashicorp/terraform-plugin-go/tfprotov5/server.(*server).ApplyResourceChange(0xc000dd0300, 0x7c749b0, 0xc001423240, 0xc0007eda40, 0xc000dd0300, 0xc001461f50, 0xc0002c2ba0)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/github.com/hashicorp/terraform-plugin-go@v0.3.0/tfprotov5/server/server.go:332 +0xb5
github.com/hashicorp/terraform-plugin-go/tfprotov5/internal/tfplugin5._Provider_ApplyResourceChange_Handler(0x6f07b20, 0xc000dd0300, 0x7c749b0, 0xc001461f50, 0xc001b11e00, 0x0, 0x7c749b0, 0xc001461f50, 0xc001d41500, 0x2c6)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/github.com/hashicorp/terraform-plugin-go@v0.3.0/tfprotov5/internal/tfplugin5/tfplugin5_grpc.pb.go:380 +0x214
google.golang.org/grpc.(*Server).processUnaryRPC(0xc0000c3500, 0x7c963b8, 0xc001b4a000, 0xc00136cb00, 0xc0012ce9c0, 0xb402a60, 0x0, 0x0, 0x0)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/google.golang.org/grpc@v1.32.0/server.go:1194 +0x52b
google.golang.org/grpc.(*Server).handleStream(0xc0000c3500, 0x7c963b8, 0xc001b4a000, 0xc00136cb00, 0x0)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/google.golang.org/grpc@v1.32.0/server.go:1517 +0xd0c
google.golang.org/grpc.(*Server).serveStreams.func1.2(0xc0010c8cd0, 0xc0000c3500, 0x7c963b8, 0xc001b4a000, 0xc00136cb00)
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/google.golang.org/grpc@v1.32.0/server.go:859 +0xab
created by google.golang.org/grpc.(*Server).serveStreams.func1
        /opt/teamcity-agent/work/5d79fe75d4460a2f/pkg/mod/google.golang.org/grpc@v1.32.0/server.go:857 +0x1fd

Error: The terraform-provider-aws_v3.46.0_x5 plugin crashed!

This is always indicative of a bug within the plugin. It would be immensely
helpful if you could report the crash with the plugin's maintainers so that it
can be fixed. The output above should help diagnose the issue.
```

version info:
```
 [fg-386] repro > terraform version
Terraform v0.15.5
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.46.0

Your version of Terraform is out of date! The latest version
is 1.0.0. You can update by downloading from https://www.terraform.io/downloads.html
```
