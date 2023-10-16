#!/bin/bash

api_token=$(gcloud auth print-access-token)

# invite and add to group
for usernum in {01..30}; do
    usernum=$(printf "%02d" ${usernum})
    echo $usernum

    # invite (not yet created) user to Terra
    curl "https://sam.dsde-prod.broadinstitute.org/api/users/v1/invite/veme_user_${usernum}%40theiagen.cloud" \
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
      curl "https://sam.dsde-prod.broadinstitute.org/api/groups/v1/VEME-2023/member/veme_user_${usernum}%40theiagen.cloud" \
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
for usernum in {01..30}; do
    usernum=$(printf "%02d" ${usernum})
    echo $usernum
    echo ""

    curl 'https://rawls.dsde-prod.broadinstitute.org/api/billing/v2/veme-training/members?inviteUsersNotFound=true' \
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
      --data-raw '{"membersToAdd":[{"email":"'veme_user_${usernum}@theiagen.cloud'","role":"User"}],"membersToRemove":[]}' \
      --verbose \
      --compressed
done