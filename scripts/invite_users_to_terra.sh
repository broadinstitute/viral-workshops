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

# invite and add to group
for usernum in $(seq -f %0${USERNUM_LENGTH_WITH_LEADING_ZERO_PADDING}g -w $STARTING_USER_NUM 1 $(($STARTING_USER_NUM + $NUM_USERS - 1))); do
#for usernum in $(seq -f %0${USERNUM_LENGTH_WITH_LEADING_ZERO_PADDING}g -w 31 1 $NUM_USERS); do
    #usernum=$(printf "%02d" ${usernum})
    echo "user num: $usernum"
    echo ""
    #continue

    # invite (not yet created) user to Terra
    echo "Inviting to Terra: ${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN}"
    curl "https://sam.dsde-prod.broadinstitute.org/api/users/v1/invite/${USERNAME_PREFIX}${usernum}%40${USER_EMAIL_DOMAIN}" \
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
      #continue

      echo ""
      echo "Adding ${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN} to group ${USER_GROUP_NAME}"
      # add said user to group
      curl "https://sam.dsde-prod.broadinstitute.org/api/groups/v1/${USER_GROUP_NAME}/member/${USERNAME_PREFIX}${usernum}%40${USER_EMAIL_DOMAIN}" \
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

#exit 0

# add to billing group
for usernum in $(seq -f %0${USERNUM_LENGTH_WITH_LEADING_ZERO_PADDING}g -w $STARTING_USER_NUM 1 $(($STARTING_USER_NUM + $NUM_USERS - 1))); do
    echo $usernum
    echo ""
    echo "Adding ${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN} to billing group ${BILLING_GROUP_NAME}"

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
      --data-raw '{"membersToAdd":[{"email":"'${USERNAME_PREFIX}${usernum}@${USER_EMAIL_DOMAIN}'","role":"User"}],"membersToRemove":[]}' \
      --verbose \
      --compressed
done