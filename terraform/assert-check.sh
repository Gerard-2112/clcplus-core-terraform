#!/bin/bash

CHKVAL="$1"

if [ "$CHKVAL" != "$OS_PROJECT_ID" ] ; then
    echo "ERROR: provided Openstack Domain ID \"$OS_PROJECT_ID\" is not the same as expected value of \"$CHKVAL\"" > /dev/stderr
    exit 1
else
    echo -n '{"status":"ok"}'
fi
