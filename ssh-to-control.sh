#!/bin/bash -
set -o nounset                                  # Treat unset variables as an error
CONTROL_IP=$(cd terraform; terraform output control-ip | tr -d '"')
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  rocky@$CONTROL_IP

