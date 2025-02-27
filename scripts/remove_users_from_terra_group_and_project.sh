#!/bin/bash

NUM_USERS=75 # assumes users are sequentially numbered 01..N
STARTING_USER_NUM=1 # assumes users are sequentially numbered 01..N

USERNUM_LENGTH_WITH_LEADING_ZERO_PADDING=3 # =3 means user #1 is '001'

USERNAME_PREFIX="dsi-africa-"
USER_EMAIL_DOMAIN="theiagen.cloud"
USER_GROUP_NAME="DSI-Africa-Datathon-2024"

BILLING_GROUP_NAME="theiagen-uct-training"

# get OAuth bearer token via the gcloud API
# the user invoking gcloud MUST have permission 
# to use the Terra API
api_token=$(gcloud auth print-access-token)


for usernum in $(seq -f %0${USERNUM_LENGTH_WITH_LEADING_ZERO_PADDING}g -w $STARTING_USER_NUM 1 $(($STARTING_USER_NUM + $NUM_USERS - 1))); do

    echo "processing $usernum"
    #continue

    echo ""
    echo "Removing ${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN} from group ${USER_GROUP_NAME}"
    curl "https://sam.dsde-prod.broadinstitute.org/api/groups/v1/${USER_GROUP_NAME}/member/${USERNAME_PREFIX}${usernum}%40${USER_EMAIL_DOMAIN}" \
    -X 'DELETE' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${api_token}" \
    -H 'dnt: 1' \
    -H 'origin: https://app.terra.bio' \
    -H 'priority: u=1, i' \
    -H 'referer: https://app.terra.bio/' \
    -H 'sec-ch-ua: "Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "macOS"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: cross-site' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' \
    -H 'x-app-id: Saturn' \
    --verbose \
    --compressed

    echo ""
    echo "Removing ${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN} from billing group ${BILLING_GROUP_NAME}"
    curl "https://rawls.dsde-prod.broadinstitute.org/api/billing/v2/${BILLING_GROUP_NAME}/members/User/${USERNAME_PREFIX}${usernum}%40${USER_EMAIL_DOMAIN}" \
      -X 'DELETE' \
      -H 'accept: */*' \
      -H 'accept-language: en-US,en;q=0.9' \
      -H "authorization: Bearer ${api_token}" \
      -H 'dnt: 1' \
      -H 'origin: https://app.terra.bio' \
      -H 'priority: u=1, i' \
      -H 'referer: https://app.terra.bio/' \
      -H 'sec-ch-ua: "Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "macOS"' \
      -H 'sec-fetch-dest: empty' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-site: cross-site' \
      -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' \
      -H 'x-app-id: Saturn' \
      --verbose \
      --compressed

done