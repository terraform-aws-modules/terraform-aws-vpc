#!/usr/bin/env bash

cd /src

set -o errexit
set -o pipefail

echo "Unit tests for terraform files, runs for each dir containing .tf files"

echo $(find . -name "*.tf" -not -path "*/.terraform" | xargs -n1 dirname | LC_ALL=C sort | uniq)

for d in $(find . -name "*.tf" -not -path "*/.terraform" -not -path "*/examples/*" | xargs -n1 dirname | LC_ALL=C sort | uniq); do
  cd "${d}"
  python tests/tests.py
  echo -en "terraform unit tests for module \"$(basename ${d})\" "
  echo "✓"
  cd -
done