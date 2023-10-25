#!/bin/bash

USERNAME_PREFIX="veme_user"
USER_EMAIL_DOMAIN="theiagen.cloud"
USER_GROUP_NAME="VEME-2023"

BILLING_GROUP_NAME="veme-training"

NUM_USERS=30 # assumes users are sequentially numbered 01..N

# get OAuth bearer token via the gcloud API
# the user invoking gcloud MUST have permission 
# to use the Terra API
api_token=$(gcloud auth print-access-token)

# invite and add to group
for usernum in $(seq -w 1 1 $NUM_USERS); do
    #usernum=$(printf "%02d" ${usernum})
    echo $usernum

    # invite (not yet created) user to Terra
    curl "https://sam.dsde-prod.broadinstitute.org/api/users/v1/invite/${USERNAME_PREFIX}_${usernum}%40${USER_EMAIL_DOMAIN}" \
      -X 'POST' \
      -H 'authority: sam.dsde-prod.broadinstitute.org' \
      -H 'accept: */*' \
      -H 'accept-language: en-US,en;q=0.9' \
      -H "authorization: Bearer ${api_token}" \
      -H 'content-length: 0' \
      -H 'dnt: 1' \
      -H 'origin: https://app.terra.bio' \
      -H 'referer: https://app.terra.bio/' \
      -H 'sec-ch-ua: "Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "macOS"' \
      -H 'sec-fetch-dest: empty' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-site: cross-site' \
      -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36' \
      -H 'x-app-id: Saturn' \
      --compressed

      # add said user to group
      curl "https://sam.dsde-prod.broadinstitute.org/api/groups/v1/${USER_GROUP_NAME}/member/${USERNAME_PREFIX}_${usernum}%40${USER_EMAIL_DOMAIN}" \
      -X 'PUT' \
      -H 'authority: sam.dsde-prod.broadinstitute.org' \
      -H 'accept: */*' \
      -H 'accept-language: en-US,en;q=0.9' \
      -H "authorization: Bearer ${api_token}" \
      -H 'content-length: 0' \
      -H 'dnt: 1' \
      -H 'origin: https://app.terra.bio' \
      -H 'referer: https://app.terra.bio/' \
      -H 'sec-ch-ua: "Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "macOS"' \
      -H 'sec-fetch-dest: empty' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-site: cross-site' \
      -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36' \
      -H 'x-app-id: Saturn' \
      --compressed
done

# add to billing group
for usernum in $(seq -w 1 1 $NUM_USERS); do
    echo $usernum
    echo ""

    curl "https://rawls.dsde-prod.broadinstitute.org/api/billing/v2/${BILLING_GROUP_NAME}/members?inviteUsersNotFound=true" \
      -X 'PATCH' \
      -H 'authority: rawls.dsde-prod.broadinstitute.org' \
      -H 'accept: */*' \
      -H 'accept-language: en-US,en;q=0.9' \
      -H "authorization: Bearer ${api_token}" \
      -H 'content-type: application/json' \
      -H 'dnt: 1' \
      -H 'origin: https://app.terra.bio' \
      -H 'referer: https://app.terra.bio/' \
      -H 'sec-ch-ua: "Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "macOS"' \
      -H 'sec-fetch-dest: empty' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-site: cross-site' \
      -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36' \
      -H 'x-app-id: Saturn' \
      --data-raw '{"membersToAdd":[{"email":"'${USERNAME_PREFIX}_${usernum}@${USER_EMAIL_DOMAIN}'","role":"User"}],"membersToRemove":[]}' \
      --verbose \
      --compressed
done