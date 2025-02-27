#!/bin/bash

USERNAME_PREFIX="veme_user"

WORKSPACE_NAME_PREFIX="VEME%202023%20Pathogen%20Dashboards"

BILLING_GROUP_NAME="veme-training"

NUM_USERS=30 # assumes users are sequentially numbered 01..N

api_token=$(gcloud auth print-access-token)

for usernum in $(seq -w 1 1 $NUM_USERS); do
    bucket_prefix="gs://"$(curl --silent -X 'GET' \
      "https://api.firecloud.org/api/workspaces/${BILLING_GROUP_NAME}/$(echo "${WORKSPACE_NAME_PREFIX}" | sed 's/ /%20/g')%20copy_${USERNAME_PREFIX}_${usernum}?fields=workspace.bucketName" \
      -H 'accept: application/json' \
      -H "Authorization: Bearer ${api_token}" | jq -r '.workspace.bucketName')

    echo "${bucket_prefix}"
done