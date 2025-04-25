#!/bin/bash
set -eo pipefail

if [[ -z ${OS_PROJECT_NAME} ]]; then
    echo "invalid OS_PROJECT_NAME set. Please execute \". ./credentials.sh\""
    exit 1
fi


tmpdir=$(mktemp -d)

# deletes the temp directory
function cleanup {
  rm -rf "$tmpdir"
  echo "Deleted temp working directory $WORK_DIR"
}

trap cleanup EXIT

function run {
    plan="$tmpdir/terraform.out"
    result="$tmpdir/terraform.result"

    cd terraform

    terraform init

    terraform plan --out "$plan" | tee "$result"

    if grep "Infrastructure is up-to-date" "$result" > /dev/null; then
      exit 0;
    fi

    echo -n "Do you want to apply the changes? (N/y): "
    read confirm

    if [[ "$confirm" == "Y" ]] || [[ "$confirm" == "y" ]] ; then
      terraform apply "$plan"
    fi
}

( run )
