locals {
  destination_bucket_name = jsonencode(distinct([
    for k, v in var.replication_rules : format("arn:aws:s3:::%s/*", v.destination_bucket_name)
  ]))
}

data "aws_iam_policy_document" "s3_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

module "s3_roles" {
  source = "../iam_roles"
  count  = length(var.replication_rules) > 0 ? 1 : 0

  name_prefix = format("%s-bucket", var.bucket)
  iam_roles = {
    replication-role = {
      instance_profile   = false
      assume_role_policy = data.aws_iam_policy_document.s3_assume_role.json
      policies = {
        replication-policy = <<EOF
          {
            "Version" : "2012-10-17",
            "Statement" : [
              {
                "Effect" : "Allow",
                "Action" : [
                  "s3:ListBucket",
                  "s3:GetReplicationConfiguration"
                ],
                "Resource" : ["arn:aws:s3:::${var.bucket}"]
              },
              {
                "Effect" : "Allow",
                "Action" : [
                  "s3:GetObjectVersionForReplication",
                  "s3:GetObjectVersionAcl",
                  "s3:GetObjectVersionTagging",
                  "s3:GetObjectRetention",
                  "s3:GetObjectLegalHold"
                ],
                "Resource" : ["arn:aws:s3:::${var.bucket}/*"]
              },
              {
                "Effect" : "Allow",
                "Action" : [
                  "s3:ReplicateObject",
                  "s3:ReplicateDelete",
                  "s3:ReplicateTags",
                  "s3:ObjectOwnerOverrideToBucketOwner"
                ],
                "Resource" : ${local.destination_bucket_name}
              }
            ]
          }
          EOF
      }
    }
  }
}
