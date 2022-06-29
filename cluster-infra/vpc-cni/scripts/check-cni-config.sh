#!/bin/bash

set -e

eval "$(jq -r '@sh "KS=\(.kubeserver) KT=\(.kubetoken) KCA=\(.kubeca)"')"

CUR_VALUE=$(kubectl describe ds aws-node \
  --server=$KS \
  --token=$KT \
  --certificate-authority=$KCA \
  -n kube-system |
  grep AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG)

if [[ $CUR_VALUE == *"false"* ]]; then
  CUSTOM_ON="off"
else
  CUSTOM_ON="on"
fi
jq -n --arg con "$CUSTOM_ON" '{"customnetwork":$con}'
