######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  tags         = local.vpce_tags
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.intra.*.id, 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

############################
# VPC Endpoint for DynamoDB
############################
data "aws_vpc_endpoint_service" "dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.dynamodb[0].service_name
  tags         = local.vpce_tags
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.intra.*.id, 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.public[0].id
}


#############################
# VPC Endpoint for Codebuild
#############################
data "aws_vpc_endpoint_service" "codebuild" {
  count = var.create_vpc && var.enable_codebuild_endpoint ? 1 : 0

  service = "codebuild"
}

resource "aws_vpc_endpoint" "codebuild" {
  count = var.create_vpc && var.enable_codebuild_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.codebuild[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.codebuild_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.codebuild_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.codebuild_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###############################
# VPC Endpoint for Code Commit
###############################
data "aws_vpc_endpoint_service" "codecommit" {
  count = var.create_vpc && var.enable_codecommit_endpoint ? 1 : 0

  service = "codecommit"
}

resource "aws_vpc_endpoint" "codecommit" {
  count = var.create_vpc && var.enable_codecommit_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.codecommit[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.codecommit_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.codecommit_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.codecommit_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###################################
# VPC Endpoint for Git Code Commit
###################################
data "aws_vpc_endpoint_service" "git_codecommit" {
  count = var.create_vpc && var.enable_git_codecommit_endpoint ? 1 : 0

  service = "git-codecommit"
}

resource "aws_vpc_endpoint" "git_codecommit" {
  count = var.create_vpc && var.enable_git_codecommit_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.git_codecommit[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.git_codecommit_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.git_codecommit_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.git_codecommit_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

##########################
# VPC Endpoint for Config
##########################
data "aws_vpc_endpoint_service" "config" {
  count = var.create_vpc && var.enable_config_endpoint ? 1 : 0

  service = "config"
}

resource "aws_vpc_endpoint" "config" {
  count = var.create_vpc && var.enable_config_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.config[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.config_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.config_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.config_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for SQS
#######################
data "aws_vpc_endpoint_service" "sqs" {
  count = var.create_vpc && var.enable_sqs_endpoint ? 1 : 0

  service = "sqs"
}

resource "aws_vpc_endpoint" "sqs" {
  count = var.create_vpc && var.enable_sqs_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sqs[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sqs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sqs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sqs_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###################################
# VPC Endpoint for Secrets Manager
###################################
data "aws_vpc_endpoint_service" "secretsmanager" {
  count = var.create_vpc && var.enable_secretsmanager_endpoint ? 1 : 0

  service = "secretsmanager"
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.create_vpc && var.enable_secretsmanager_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.secretsmanager[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.secretsmanager_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.secretsmanager_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.secretsmanager_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for SSM
#######################
data "aws_vpc_endpoint_service" "ssm" {
  count = var.create_vpc && var.enable_ssm_endpoint ? 1 : 0

  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  count = var.create_vpc && var.enable_ssm_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssm[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ssm_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ssm_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ssm_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###############################
# VPC Endpoint for SSMMESSAGES
###############################
data "aws_vpc_endpoint_service" "ssmmessages" {
  count = var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0

  service = "ssmmessages"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssmmessages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ssmmessages_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ssmmessages_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ssmmessages_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for EC2
#######################
data "aws_vpc_endpoint_service" "ec2" {
  count = var.create_vpc && var.enable_ec2_endpoint ? 1 : 0

  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.create_vpc && var.enable_ec2_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ec2_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ec2_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ec2_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###############################
# VPC Endpoint for EC2MESSAGES
###############################
data "aws_vpc_endpoint_service" "ec2messages" {
  count = var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0

  service = "ec2messages"
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2messages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ec2messages_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ec2messages_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ec2messages_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###############################
# VPC Endpoint for EC2 Autoscaling
###############################
data "aws_vpc_endpoint_service" "ec2_autoscaling" {
  count = var.create_vpc && var.enable_ec2_autoscaling_endpoint ? 1 : 0

  service = "autoscaling"
}

resource "aws_vpc_endpoint" "ec2_autoscaling" {
  count = var.create_vpc && var.enable_ec2_autoscaling_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2_autoscaling[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ec2_autoscaling_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ec2_autoscaling_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ec2_autoscaling_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


###################################
# VPC Endpoint for Transfer Server
###################################
data "aws_vpc_endpoint_service" "transferserver" {
  count = var.create_vpc && var.enable_transferserver_endpoint ? 1 : 0

  service = "transfer.server"
}

resource "aws_vpc_endpoint" "transferserver" {
  count = var.create_vpc && var.enable_transferserver_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.transferserver[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.transferserver_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.transferserver_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.transferserver_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###########################
# VPC Endpoint for ECR API
###########################
data "aws_vpc_endpoint_service" "ecr_api" {
  count = var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0

  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {
  count = var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_api[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecr_api_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ecr_api_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ecr_api_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

###########################
# VPC Endpoint for ECR DKR
###########################
data "aws_vpc_endpoint_service" "ecr_dkr" {
  count = var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0

  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_dkr[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecr_dkr_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ecr_dkr_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ecr_dkr_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for API Gateway
#######################
data "aws_vpc_endpoint_service" "apigw" {
  count = var.create_vpc && var.enable_apigw_endpoint ? 1 : 0

  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  count = var.create_vpc && var.enable_apigw_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.apigw[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.apigw_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.apigw_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.apigw_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for KMS
#######################
data "aws_vpc_endpoint_service" "kms" {
  count = var.create_vpc && var.enable_kms_endpoint ? 1 : 0

  service = "kms"
}

resource "aws_vpc_endpoint" "kms" {
  count = var.create_vpc && var.enable_kms_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.kms[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.kms_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.kms_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.kms_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for ECS
#######################
data "aws_vpc_endpoint_service" "ecs" {
  count = var.create_vpc && var.enable_ecs_endpoint ? 1 : 0

  service = "ecs"
}

resource "aws_vpc_endpoint" "ecs" {
  count = var.create_vpc && var.enable_ecs_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecs[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ecs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ecs_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for ECS Agent
#######################
data "aws_vpc_endpoint_service" "ecs_agent" {
  count = var.create_vpc && var.enable_ecs_agent_endpoint ? 1 : 0

  service = "ecs-agent"
}

resource "aws_vpc_endpoint" "ecs_agent" {
  count = var.create_vpc && var.enable_ecs_agent_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecs_agent[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecs_agent_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ecs_agent_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ecs_agent_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for ECS Telemetry
#######################
data "aws_vpc_endpoint_service" "ecs_telemetry" {
  count = var.create_vpc && var.enable_ecs_telemetry_endpoint ? 1 : 0

  service = "ecs-telemetry"
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  count = var.create_vpc && var.enable_ecs_telemetry_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecs_telemetry[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.ecs_telemetry_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ecs_telemetry_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ecs_telemetry_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for SNS
#######################
data "aws_vpc_endpoint_service" "sns" {
  count = var.create_vpc && var.enable_sns_endpoint ? 1 : 0

  service = "sns"
}

resource "aws_vpc_endpoint" "sns" {
  count = var.create_vpc && var.enable_sns_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sns[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sns_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sns_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sns_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudWatch Monitoring
#######################
data "aws_vpc_endpoint_service" "monitoring" {
  count = var.create_vpc && var.enable_monitoring_endpoint ? 1 : 0

  service = "monitoring"
}

resource "aws_vpc_endpoint" "monitoring" {
  count = var.create_vpc && var.enable_monitoring_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.monitoring[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.monitoring_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.monitoring_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.monitoring_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudWatch Logs
#######################
data "aws_vpc_endpoint_service" "logs" {
  count = var.create_vpc && var.enable_logs_endpoint ? 1 : 0

  service = "logs"
}

resource "aws_vpc_endpoint" "logs" {
  count = var.create_vpc && var.enable_logs_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.logs[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.logs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.logs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.logs_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudWatch Events
#######################
data "aws_vpc_endpoint_service" "events" {
  count = var.create_vpc && var.enable_events_endpoint ? 1 : 0

  service = "events"
}

resource "aws_vpc_endpoint" "events" {
  count = var.create_vpc && var.enable_events_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.events[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.events_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.events_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.events_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for Elastic Load Balancing
#######################
data "aws_vpc_endpoint_service" "elasticloadbalancing" {
  count = var.create_vpc && var.enable_elasticloadbalancing_endpoint ? 1 : 0

  service = "elasticloadbalancing"
}

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  count = var.create_vpc && var.enable_elasticloadbalancing_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.elasticloadbalancing[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.elasticloadbalancing_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.elasticloadbalancing_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.elasticloadbalancing_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for CloudTrail
#######################
data "aws_vpc_endpoint_service" "cloudtrail" {
  count = var.create_vpc && var.enable_cloudtrail_endpoint ? 1 : 0

  service = "cloudtrail"
}

resource "aws_vpc_endpoint" "cloudtrail" {
  count = var.create_vpc && var.enable_cloudtrail_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.cloudtrail[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.cloudtrail_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.cloudtrail_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.cloudtrail_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for Kinesis Streams
#######################
data "aws_vpc_endpoint_service" "kinesis_streams" {
  count = var.create_vpc && var.enable_kinesis_streams_endpoint ? 1 : 0

  service = "kinesis-streams"
}

resource "aws_vpc_endpoint" "kinesis_streams" {
  count = var.create_vpc && var.enable_kinesis_streams_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.kinesis_streams[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.kinesis_streams_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.kinesis_streams_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.kinesis_streams_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}


#######################
# VPC Endpoint for Kinesis Firehose
#######################
data "aws_vpc_endpoint_service" "kinesis_firehose" {
  count = var.create_vpc && var.enable_kinesis_firehose_endpoint ? 1 : 0

  service = "kinesis-firehose"
}

resource "aws_vpc_endpoint" "kinesis_firehose" {
  count = var.create_vpc && var.enable_kinesis_firehose_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.kinesis_firehose[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.kinesis_firehose_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.kinesis_firehose_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.kinesis_firehose_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for Glue
#######################
data "aws_vpc_endpoint_service" "glue" {
  count = var.create_vpc && var.enable_glue_endpoint ? 1 : 0

  service = "glue"
}

resource "aws_vpc_endpoint" "glue" {
  count = var.create_vpc && var.enable_glue_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.glue[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.glue_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.glue_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.glue_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

######################################
# VPC Endpoint for Sagemaker Notebooks
######################################
data "aws_vpc_endpoint_service" "sagemaker_notebook" {
  count = var.create_vpc && var.enable_sagemaker_notebook_endpoint ? 1 : 0

  service_name = "aws.sagemaker.${var.sagemaker_notebook_endpoint_region}.notebook"
}

resource "aws_vpc_endpoint" "sagemaker_notebook" {
  count = var.create_vpc && var.enable_sagemaker_notebook_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sagemaker_notebook[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sagemaker_notebook_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sagemaker_notebook_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sagemaker_notebook_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for STS
#######################
data "aws_vpc_endpoint_service" "sts" {
  count = var.create_vpc && var.enable_sts_endpoint ? 1 : 0

  service = "sts"
}

resource "aws_vpc_endpoint" "sts" {
  count = var.create_vpc && var.enable_sts_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sts[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sts_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sts_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sts_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#############################
# VPC Endpoint for Cloudformation
#############################
data "aws_vpc_endpoint_service" "cloudformation" {
  count = var.create_vpc && var.enable_cloudformation_endpoint ? 1 : 0

  service = "cloudformation"
}

resource "aws_vpc_endpoint" "cloudformation" {
  count = var.create_vpc && var.enable_cloudformation_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.cloudformation[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.cloudformation_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.cloudformation_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.cloudformation_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for CodePipeline
#############################
data "aws_vpc_endpoint_service" "codepipeline" {
  count = var.create_vpc && var.enable_codepipeline_endpoint ? 1 : 0

  service = "codepipeline"
}

resource "aws_vpc_endpoint" "codepipeline" {
  count = var.create_vpc && var.enable_codepipeline_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.codepipeline[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.codepipeline_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.codepipeline_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.codepipeline_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for AppMesh
#############################
data "aws_vpc_endpoint_service" "appmesh_envoy_management" {
  count = var.create_vpc && var.enable_appmesh_envoy_management_endpoint ? 1 : 0

  service = "appmesh-envoy-management"
}

resource "aws_vpc_endpoint" "appmesh_envoy_management" {
  count = var.create_vpc && var.enable_appmesh_envoy_management_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.appmesh_envoy_management[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.appmesh_envoy_management_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.appmesh_envoy_management_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.appmesh_envoy_management_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for Service Catalog
#############################
data "aws_vpc_endpoint_service" "servicecatalog" {
  count = var.create_vpc && var.enable_servicecatalog_endpoint ? 1 : 0

  service = "servicecatalog"
}

resource "aws_vpc_endpoint" "servicecatalog" {
  count = var.create_vpc && var.enable_servicecatalog_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.servicecatalog[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.servicecatalog_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.servicecatalog_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.servicecatalog_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for Storage Gateway
#############################
data "aws_vpc_endpoint_service" "storagegateway" {
  count = var.create_vpc && var.enable_storagegateway_endpoint ? 1 : 0

  service = "storagegateway"
}

resource "aws_vpc_endpoint" "storagegateway" {
  count = var.create_vpc && var.enable_storagegateway_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.storagegateway[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.storagegateway_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.storagegateway_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.storagegateway_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for Transfer
#############################
data "aws_vpc_endpoint_service" "transfer" {
  count = var.create_vpc && var.enable_transfer_endpoint ? 1 : 0

  service = "transfer"
}

resource "aws_vpc_endpoint" "transfer" {
  count = var.create_vpc && var.enable_transfer_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.transfer[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.transfer_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.transfer_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.transfer_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for SageMaker API
#############################
data "aws_vpc_endpoint_service" "sagemaker_api" {
  count = var.create_vpc && var.enable_sagemaker_api_endpoint ? 1 : 0

  service = "sagemaker.api"
}

resource "aws_vpc_endpoint" "sagemaker_api" {
  count = var.create_vpc && var.enable_sagemaker_api_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sagemaker_api[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sagemaker_api_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sagemaker_api_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sagemaker_api_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
#############################
# VPC Endpoint for SageMaker Runtime
#############################
data "aws_vpc_endpoint_service" "sagemaker_runtime" {
  count = var.create_vpc && var.enable_sagemaker_runtime_endpoint ? 1 : 0

  service = "sagemaker.runtime"
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  count = var.create_vpc && var.enable_sagemaker_runtime_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sagemaker_runtime[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.sagemaker_runtime_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sagemaker_runtime_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sagemaker_runtime_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#############################
# VPC Endpoint for AppStream
#############################
data "aws_vpc_endpoint_service" "appstream" {
  count = var.create_vpc && var.enable_appstream_endpoint ? 1 : 0

  service = "appstream"
}

resource "aws_vpc_endpoint" "appstream" {
  count = var.create_vpc && var.enable_appstream_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.appstream[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.appstream_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.appstream_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.appstream_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#############################
# VPC Endpoint for Athena
#############################
data "aws_vpc_endpoint_service" "athena" {
  count = var.create_vpc && var.enable_athena_endpoint ? 1 : 0

  service = "athena"
}

resource "aws_vpc_endpoint" "athena" {
  count = var.create_vpc && var.enable_athena_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.athena[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.athena_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.athena_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.athena_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#############################
# VPC Endpoint for Rekognition
#############################
data "aws_vpc_endpoint_service" "rekognition" {
  count = var.create_vpc && var.enable_rekognition_endpoint ? 1 : 0

  service = "rekognition"
}

resource "aws_vpc_endpoint" "rekognition" {
  count = var.create_vpc && var.enable_rekognition_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.rekognition[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.rekognition_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.rekognition_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.rekognition_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}

#######################
# VPC Endpoint for EFS
#######################
data "aws_vpc_endpoint_service" "efs" {
  count = var.create_vpc && var.enable_efs_endpoint ? 1 : 0

  service = "elasticfilesystem"
}

resource "aws_vpc_endpoint" "efs" {
  count = var.create_vpc && var.enable_efs_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.efs[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.efs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.efs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.efs_endpoint_private_dns_enabled

  tags = local.vpce_tags
}

#######################
# VPC Endpoint for Cloud Directory
#######################
data "aws_vpc_endpoint_service" "cloud_directory" {
  count = var.create_vpc && var.enable_cloud_directory_endpoint ? 1 : 0

  service = "clouddirectory"
}

resource "aws_vpc_endpoint" "cloud_directory" {
  count = var.create_vpc && var.enable_cloud_directory_endpoint ? 1 : 0

  vpc_id            = local.vpc_id
  service_name      = data.aws_vpc_endpoint_service.cloud_directory[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.cloud_directory_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.cloud_directory_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.cloud_directory_endpoint_private_dns_enabled

  tags = local.vpce_tags
}
