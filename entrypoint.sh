#!/bin/bash


echo "$INPUT_KUBECONFIG_FILE" > .kubeconfig
export KUBECONFIG=.kubeconfig

if [ -n "$INPUT_CHART_REPO" ]; then
	echo adding repo $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
    helm repo add $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
fi

helm repo update
helm search repo $INPUT_CHART_REPO_ALIAS

echo helm upgrade --install --wait --timeout 2m0s --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INPUT_RELEASE $INPUT_CHART


helm upgrade --install --wait --timeout 2m0s --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INPUT_RELEASE $INPUT_CHART



