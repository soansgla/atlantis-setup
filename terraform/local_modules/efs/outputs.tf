output "efs_id" {
  description = "Id of the EFS file system."
  value       = aws_efs_file_system.this.id
}

output "efs_arn" {
  description = "ARN of the EFS file system."
  value       = aws_efs_file_system.this.arn
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system."
  value       = aws_efs_file_system.this.dns_name
}

output "efs_access_points" {
  description = "Map of the EFS access points."
  value = {
    for key, value in aws_efs_access_point.this :
    key => {
      arn = value.arn
      id  = value.id
    }
  }
}

output "efs_mount_target" {
  description = "Map of the EFS mount target."
  value = {
    for key, value in aws_efs_mount_target.this :
    value.availability_zone_name => {
      id                    = value.id
      dns_name              = value.dns_name
      mount_target_dns_name = value.mount_target_dns_name
      subnet_id             = key
      network_interface_id  = value.network_interface_id
      owner_id              = value.owner_id
    }
  }
}

# EFS Replica Outputs

output "efs_replica_id" {
  description = "Id of the EFS replica file system."
  value       = one(data.aws_efs_file_system.replica[*].file_system_id)
}

output "efs_replica_arn" {
  description = "ARN of the EFS replica file system."
  value       = one(data.aws_efs_file_system.replica[*].arn)
}

output "efs_replica_dns_name" {
  description = "DNS name of the EFS replica file system."
  value       = one(data.aws_efs_file_system.replica[*].dns_name)
}

output "efs_replica_access_points" {
  description = "Map of the EFS replica file system access points."
  value = {
    for key, value in aws_efs_access_point.replica :
    key => {
      arn = value.arn
      id  = value.id
    }
  }
}

output "efs_replica_mount_target" {
  description = "Map of the EFS replica file system mount target."
  value = {
    for key, value in aws_efs_mount_target.replica :
    value.availability_zone_name => {
      id                    = value.id
      dns_name              = value.dns_name
      mount_target_dns_name = value.mount_target_dns_name
      network_interface_id  = value.network_interface_id
      owner_id              = value.owner_id
      subnet_id             = key
    }
  }
}
