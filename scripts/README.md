# Account provisioning automation

## Install dependencies

Install dependencies into an isolated conda environment and activate the environment:
```
conda env create -f selenium_env.yml
conda activate selenium_env
```

## Invite users to Terra and add to group and billing group

Modify `invite_users_to_terra.sh` and set the following values as appropriate:

```
NUM_USERS=20

USERNAME_PREFIX="user" #prefix to which a sequential number is appended, up to $NUM_USERS
USER_EMAIL_DOMAIN="example.com"
USER_GROUP_NAME="training-2024"

BILLING_GROUP_NAME="my-training"
```

Then run the script:

```
./invite_users_to_terra.sh
```

## Initial login to Google accounts with password change

```
./login_and_change_password.py ./training_accounts_2024.tsv --change_password
```