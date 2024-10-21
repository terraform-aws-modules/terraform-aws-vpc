#!/bin/bash
#set -e
#set -x


GH_TOKEN=$(gh auth token)
REPO=$1
BRANCH=$2

gh repo edit $REPO --add-topic "terraform,terraform-module" \
--enable-rebase-merge --delete-branch-on-merge \
--enable-squash-merge=false --enable-merge-commit=false

curl \
-X PUT \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer ${GH_TOKEN}" \
"https://api.github.com/repos/$REPO/branches/$BRANCH/protection" \
--data-binary "@.github/scripts/branch_restrictions.json"