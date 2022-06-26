data "aws_region" "current" {}
data "aws_default_tags" "current" {}
data "aws_efs_file_system" "replica" {
  # Must need "count" because of Error: The terraform-provider-aws_v3.75.1_x5 plugin crashed!
  count = var.replica_destination != null ? 1 : 0

  tags = {
    Name = "${var.name_prefix}-replica-efs"
  }

  depends_on = [
    null_resource.efs_replica
  ]
}

locals {
  replica_destination = var.replica_destination != null ? {
    for k, v in var.replica_destination : k => v
    if v != null
  } : null

  all_tags = merge(var.tags, data.aws_default_tags.current.tags, { "Name" : "${var.name_prefix}-replica-efs" })

  replica_tags = flatten([
    for k, v in local.all_tags : {
      Key   = k
      Value = v
    }
  ])
}

resource "aws_efs_file_system" "this" {
  #checkov:skip=CKV2_AWS_18: TODO: "Ensure that Elastic File System (Amazon EFS) file systems are added in the backup plans of AWS Backup"
  encrypted                       = true
  kms_key_id                      = var.kms_key_arn
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  creation_token                  = var.creation_token

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia != null ? toset([1]) : []

    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  tags = merge(var.tags, { "Name" = "${var.name_prefix}-efs" })
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_groups
}

resource "aws_efs_access_point" "this" {
  for_each = defaults(
    var.access_points,
    {
      "posix_user_gid" : 1000,
      "posix_user_uid" : 100,
      "owner_gid" : 1000,
      "owner_uid" : 100,
      "owner_permissions" : 0755,
    }
  )

  file_system_id = aws_efs_file_system.this.id
  posix_user {
    gid = each.value.posix_user_gid
    uid = each.value.posix_user_uid
  }

  root_directory {
    creation_info {
      owner_gid   = each.value.owner_gid
      owner_uid   = each.value.owner_uid
      permissions = each.value.owner_permissions
    }
    path = each.value.access_path
  }
  tags = merge(var.tags, { "Name" : "${var.name_prefix}-efs-${each.key}" })
}

resource "null_resource" "efs_replica" {
  count = var.replica_destination != null ? 1 : 0

  provisioner "local-exec" {
    command = "./scripts/efs_replica.sh create ${self.triggers.region} ${self.triggers.efs_id} '${self.triggers.destination}' '${self.triggers.replica_tags}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "./scripts/efs_replica.sh destroy ${self.triggers.region} ${self.triggers.efs_id} none none"
  }

  triggers = {
    region       = data.aws_region.current.name
    efs_id       = aws_efs_file_system.this.id
    destination  = jsonencode(local.replica_destination)
    replica_tags = jsonencode(local.replica_tags)
  }

  depends_on = [
    aws_efs_file_system.this
  ]
}

resource "aws_efs_mount_target" "replica" {
  for_each = toset(var.replica_subnet_ids)

  file_system_id  = data.aws_efs_file_system.replica[0].file_system_id
  subnet_id       = each.value
  security_groups = var.replica_security_groups

  depends_on = [
    data.aws_efs_file_system.replica
  ]
}

resource "aws_efs_access_point" "replica" {
  for_each = defaults(
    var.replica_access_points,
    {
      "posix_user_gid" : 1000,
      "posix_user_uid" : 100,
      "owner_gid" : 1000,
      "owner_uid" : 100,
      "owner_permissions" : 0755,
    }
  )

  file_system_id = data.aws_efs_file_system.replica[0].file_system_id
  posix_user {
    gid = each.value.posix_user_gid
    uid = each.value.posix_user_uid
  }

  root_directory {
    creation_info {
      owner_gid   = each.value.owner_gid
      owner_uid   = each.value.owner_uid
      permissions = each.value.owner_permissions
    }
    path = each.value.access_path
  }
  tags = merge(var.tags, { "Name" : "${var.name_prefix}-replica-efs-${each.key}" })

  depends_on = [
    data.aws_efs_file_system.replica
  ]
}
