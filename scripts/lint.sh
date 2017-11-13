#!/usr/bin/env bash

cd /src

set -o errexit
set -o pipefail


TFDIRS=$(find . ! -path "*/examples/*" -name "*.tf" | xargs -n1 dirname | LC_ALL=C sort | uniq)
echo -e "\n\e[93mValidating terraform files syntax, runs for each dir containing .tf files:"
echo -e "\e[92m$TFDIRS"

for d in $TFDIRS; do
  cd "${d}"
  terraform init
  terraform validate -var-file=tests/terraform.tfvars
  echo -en "\e[92mTerraform configs successfully validated for module $(basename ${d}) "
  echo -e "\e[92m✓"
  cd -
done