#!/bin/bash

set -e

echo "Calling $KUBESERVER ..."
kubectl --server="$KUBESERVER" --token="$KUBETOKEN" --certificate-authority="$KUBECA" \
  patch storageclass "$SC" \
  -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'
