#!/usr/bin/env bash

cd src

set -o errexit
set -o pipefail
set -u # exit on unbound vars

if [ -z $CI_COMMIT_ID ] || [ -z $CI_BUILD_ID ] || [ -z $CI_BRANCH ] ; then
  echo "Either of env variables not configured: CI_COMMIT_ID, CI_BRANCH, CI_BUILD_ID\n"
  echo -ne "When developing locally, run jet cli as following:
jet steps -e CI_COMMIT_ID=\$(git rev-parse  HEAD) \
-e CI_BUILD_ID=local-build \
-e CI_BRANCH=\$(git rev-parse --abbrev-ref HEAD)"
exit 1
fi

export ENV=$(cat /artifacts/packer-vars.txt)

if [ "$ENV" == "master" ]; then 
  export ARTIFACTS_BUCKET="s3://907136348507-firebricks/terraform-modules/providers/aws-master/"
else 
  export ARTIFACTS_BUCKET="s3://907136348507-firebricks/terraform-modules/providers/aws-dev-$ENV/"
fi

TFDIRS=$(find . ! -path "*/examples/*" -name "*.tf" | xargs -n1 dirname | LC_ALL=C sort | uniq)

echo -e "\n\e[93mUploading modules to S3, packaged as zip"
echo -e "\e[92m$TFDIRS"

for d in $TFDIRS; do
  cd "${d}"
  /usr/bin/zip --exclude=.terraform --exclude=tests/ "$(basename ${PWD}).zip" ./*
  /usr/bin/aws s3 cp "$(basename ${PWD}).zip" "$ARTIFACTS_BUCKET"
  echo -en "\e[92mModule \"$(basename ${PWD})\" uploaded to $ARTIFACTS_BUCKET$(basename ${PWD}).zip "
  echo -e "\e[92m✓"
  cd -
done
