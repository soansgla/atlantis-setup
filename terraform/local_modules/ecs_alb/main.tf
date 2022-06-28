data "aws_elb_service_account" "default" {}

# S3 Bucket
module "s3_bucket" {
  source = "../s3_bucket"

  bucket        = "${var.name_prefix}-lb-logs"
  acl           = "log-delivery-write"
  force_destroy = var.s3_force_destroy

  versioning = {
    enabled = false
  }

  attach_policy = true
  policy        = <<-POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid"    : "AWSLogDeliveryPutObject",
        "Action" : ["s3:PutObject"],
        "Resource" : ["arn:aws:s3:::${var.name_prefix}-lb-logs/*"],
        "Effect" : "Allow",
        "Principal" : { "AWS" : ["${data.aws_elb_service_account.default.arn}"] }
      },
      {
        "Sid"    : "AWSLogDeliveryWrite",
        "Action" : ["s3:PutObject"],
        "Resource" : ["arn:aws:s3:::${var.name_prefix}-lb-logs/*"],
        "Effect" : "Allow",
        "Principal" : { "Service" : ["delivery.logs.amazonaws.com"] },
        "Condition" : { "StringEquals" : { "s3:x-amz-acl" : "bucket-owner-full-control" } }
      },
      {
        "Sid"    : "AWSLogDeliveryAclCheck",
        "Action" : ["s3:GetBucketAcl"],
        "Resource" : ["arn:aws:s3:::${var.name_prefix}-lb-logs"],
        "Effect" : "Allow",
        "Principal" : { "Service" : ["delivery.logs.amazonaws.com"] }
      }
    ]
  }
  POLICY

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-lb-logs"
    }
  )
}

# Using moved to keep current S3 bucket object once is moved from resource to s3_bucket module
moved {
  from = aws_s3_bucket.logs
  to   = module.s3_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.logs
  to   = module.s3_bucket.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_policy.lb_logs_access_policy
  to   = module.s3_bucket.aws_s3_bucket_policy.this[0]
}

# APPLICATION LOAD BALANCER

resource "aws_lb" "lb" {
  #checkov:skip=CKV2_AWS_20:We don't want to always force HTTPS at this stage.
  #checkov:skip=CKV2_AWS_28:Ensure public facing ALB are protected by WAF. Disabled check
  name                             = "${var.name_prefix}-lb"
  internal                         = var.internal
  load_balancer_type               = "application"
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  subnets                          = var.internal == true ? var.private_subnets : var.public_subnets
  idle_timeout                     = var.idle_timeout
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type
  security_groups = compact(
    concat(var.security_groups, [
    aws_security_group.lb_access_sg.id]),
  )

  access_logs {
    bucket  = module.s3_bucket.s3_bucket_id
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-lb"
    }
  )
}

# ACCESS CONTROL TO APPLICATION LOAD BALANCER

resource "aws_security_group" "lb_access_sg" {
  name        = "${var.name_prefix}-lb-access-sg"
  description = "Controls access to the Load Balancer"
  vpc_id      = var.vpc_id
  egress {
    from_port   = var.lb_egress_from_port
    to_port     = var.lb_egress_to_port
    protocol    = var.lb_egress_protocol
    cidr_blocks = var.lb_egress_cidr
    description = "Allow all ALB to egress on defined ports/protocols."
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-lb-access-sg"
    }
  )
}

resource "aws_security_group_rule" "ingress_through_httpss" {
  for_each = var.https_ports

  security_group_id = aws_security_group.lb_access_sg.id
  type              = "ingress"
  from_port         = each.value.listener_port
  to_port           = each.value.listener_port
  protocol          = "tcp"
  cidr_blocks       = var.https_ingress_cidr_blocks
  prefix_list_ids   = var.https_ingress_prefix_list_ids
  description       = "Ingress through HTTPS for port ${each.value.listener_port}"
}

# AWS LOAD BALANCER - Target Groups

resource "aws_lb_target_group" "lb_https_tgs" {
  for_each = {
    for name, config in var.https_ports : name => config
    if lookup(config, "type", "") == "" || lookup(config, "type", "") == "forward"
  }

  name                          = "${var.name_prefix}-https-${each.value.target_group_port}"
  port                          = each.value.target_group_port
  protocol                      = "HTTPS"
  vpc_id                        = var.vpc_id
  deregistration_delay          = var.deregistration_delay
  slow_start                    = var.slow_start
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  dynamic "stickiness" {
    for_each = var.stickiness == null ? [] : [var.stickiness]
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }
  health_check {
    enabled             = var.target_group_health_check_enabled
    interval            = var.target_group_health_check_interval
    path                = var.target_group_health_check_path
    protocol            = "HTTPS"
    timeout             = var.target_group_health_check_timeout
    healthy_threshold   = var.target_group_health_check_healthy_threshold
    unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
    matcher             = var.target_group_health_check_matcher
  }
  target_type = "ip"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-https-${each.value.target_group_port}"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_lb.lb]
}


# AWS LOAD BALANCER - Listeners

resource "aws_lb_listener" "lb_https_listeners" {
  #checkov:skip=CKV_AWS_103:This is specifically a HTTPS listener.
  #checkov:skip=CKV_AWS_2:This is specifically a HTTPS listener.
  for_each = var.https_ports

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.listener_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.default_certificate_arn
  
  dynamic "default_action" {
    for_each = lookup(each.value, "type", "") == "redirect" ? [
    1] : []
    content {
      type = "redirect"

      redirect {
        host        = lookup(each.value, "host", "#{host}")
        path        = lookup(each.value, "path", "/#{path}")
        port        = lookup(each.value, "port", "#{port}")
        protocol    = lookup(each.value, "protocol", "#{protocol}")
        query       = lookup(each.value, "query", "#{query}")
        status_code = lookup(each.value, "status_code", "HTTPS_301")
      }
    }
  }

  dynamic "default_action" {
    for_each = lookup(each.value, "type", "") == "fixed-response" ? [
    1] : []
    content {
      type = "fixed-response"

      fixed_response {
        content_type = lookup(each.value, "content_type", "text/plain")
        message_body = lookup(each.value, "message_body", "Fixed response content")
        status_code  = lookup(each.value, "status_code", "200")
      }
    }
  }

  # We fallback to using forward type action if type is not defined
  dynamic "default_action" {
    for_each = (lookup(each.value, "type", "") == "" || lookup(each.value, "type", "") == "forward") ? [
    1] : []
    content {
      target_group_arn = aws_lb_target_group.lb_https_tgs[each.key].arn
      type             = "forward"
    }
  }
}

locals {
  list_maps_listener_certificate_arns = flatten([
    for cert_arn in var.additional_certificates_arn_for_https_listeners : [
      for listener in aws_lb_listener.lb_https_listeners : {
        name            = "${listener}-${cert_arn}"
        listener_arn    = listener.arn
        certificate_arn = cert_arn
      }
    ]
  ])

  map_listener_certificate_arns = {
    for obj in local.list_maps_listener_certificate_arns : obj.name => {
      listener_arn    = obj.listener_arn,
      certificate_arn = obj.certificate_arn
    }
  }
}

resource "aws_lb_listener_certificate" "additional_certificates_for_https_listeners" {
  for_each = local.map_listener_certificate_arns

  listener_arn    = each.value.listener_arn
  certificate_arn = each.value.certificate_arn
}



