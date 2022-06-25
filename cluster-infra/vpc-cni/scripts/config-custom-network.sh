#!/bin/bash

set -e

echo "Calling $KUBESERVER ..."
CUR_VALUE=`kubectl describe ds aws-node --server=$KUBESERVER --token=$KUBETOKEN --certificate-authority=$KUBECA -n kube-system | grep AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG`

if [[ $CUR_VALUE == *"false"* ]]; then
  echo "Setting custom configuration to true"
  kubectl set env ds aws-node --server=$KUBESERVER --token=$KUBETOKEN --certificate-authority=$KUBECA -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true ENABLE_PREFIX_DELEGATION=true WARM_PREFIX_TARGET=1 ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
  INSTANCES=`aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:kubernetes.io/cluster/$CLUSTERNAME,Values=owned --query "Reservations[].Instances[].InstanceID" --output text`
  aws ec2 terminate-instances --no-cli-pager --instance-ids $INSTANCES
fi
