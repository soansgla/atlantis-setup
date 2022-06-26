#!/bin/bash

set -euo pipefail

# Obtain arguments
action="${1}"
region="${2}"
efs_id="${3}"
destination="${4}"
replica_tags="${5}"

# Check current EFS destination Configuration
destination_filesystem_id=$(aws --region "${region}" efs describe-replication-configurations --file-system-id "${efs_id}" | jq -r '.Replications[].Destinations[].FileSystemId' || true)

if [ "${action}" == "create" ]; then
    time=5
    # Check if there is a value for AZSuffix key, if so change key for AvailabilityZoneName and the value is the full AZ Name
    azsuffix=$(echo "${destination}" | jq '.AZSuffix')
    if [ "${azsuffix}" != "" ]; then
        destination=$(echo "${destination}" | jq 'select(.AZSuffix != null) | .AvailabilityZoneName=("\(.Region)\(.AZSuffix)") | del(.AZSuffix)')
    fi
    if [ -z "${destination_filesystem_id}" ]; then
        echo "Create EFS Replica"
        destination_file="destination.json"
        echo "[${destination}]" | jq >${destination_file}
        aws --region "${region}" efs create-replication-configuration --source-file-system-id "${efs_id}" --destinations file://${destination_file}
        rm -f ${destination_file}
        status=""
        while [ "${status}" != "ENABLED" ]; do
            status=$(aws --region "${region}" efs describe-replication-configurations --file-system-id "${efs_id}" | jq -r '.Replications[].Destinations[].Status' || true)
            echo "EFS Replication Status = ${status}, checking again in ${time} seconds"
            sleep ${time}
        done
    fi
    # Update Destination EFS filesystem Id
    destination_filesystem_id=$(aws --region "${region}" efs describe-replication-configurations --file-system-id "${efs_id}" | jq -r '.Replications[].Destinations[].FileSystemId')
    if [ "${destination_filesystem_id}" != "" ]; then
        echo "Tagging EFS Destination = $destination_filesystem_id"
        replica_tags_file="replica_tags.json"
        echo "${replica_tags}" | jq >${replica_tags_file}
        aws --region "${region}" efs tag-resource --resource-id "$destination_filesystem_id" --tags file://${replica_tags_file}
        rm -f ${replica_tags_file}
    fi
elif [ "${action}" == "destroy" ]; then
    time=10
    if [ "${destination_filesystem_id}" != "" ] || [ -z "${destination_filesystem_id}" ]; then
        status=$(aws --region "${region}" efs describe-replication-configurations --file-system-id "${efs_id}" | jq -r '.Replications[].Destinations[].Status' || true)
        if [ "${status}" == "ENABLED" ]; then
            echo "Delete EFS Replication"
            aws --region "${region}" efs delete-replication-configuration --source-file-system-id "${efs_id}"
        fi
        while [ "${status}" == "DELETING" ] || [ -n "${status}" ]; do
            echo "EFS Replication Status = ${status}, checking again in ${time} seconds"
            sleep ${time}
            status=$(aws --region "${region}" efs describe-replication-configurations --file-system-id "${efs_id}" | jq -r '.Replications[].Destinations[].Status' || true)
        done
    fi
    if [ -n "${status}" ] || [ -n "$destination_filesystem_id" ]; then
        echo "Delete EFS ${destination_filesystem_id}"
        aws --region "${region}" efs delete-file-system --file-system-id "$destination_filesystem_id"
    fi
else
    echo "No action value found, exit with error"
    exit 1
fi
