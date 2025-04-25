#!/usr/bin/env bash

if [ "$1" != "-f" ]; then
    echo "please provide -f parameter if you really want to reset this project" >&2
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

rm $DIR/terraform/terraform.tfstate*
rm $DIR/control/.ssh/*
