#!/bin/bash


echo "$INPUT_KUBECONFIG_FILE" > .kubeconfig
export KUBECONFIG=.kubeconfig

if [ -n "$INPUT_CHART_REPO" ]; then
	echo adding repo $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
    helm repo add $INPUT_CHART_REPO_ALIAS $INPUT_CHART_REPO
fi

helm repo update
helm search repo $INPUT_CHART_REPO_ALIAS

export VALFILE="$(echo $INPUT_VALUE_FILES | awk -F, '{print $(NF)}')"
echo Searching for instance specific value file for $VALFILE
export INSTANCE_VALFILE="$(dirname $VALFILE)/${INPUT_INSTANCE}.$(basename $VALFILE)"
if [ -f "$INSTANCE_VALFILE" ]; then
	INCLUDE_VALFILE="-f $INSTANCE_VALFILE"
	echo Found $INSTANCE_VALFILE :
	cat $INSTANCE_VALFILE
fi

echo helm upgrade --install --wait --timeout $INPUT_TIMEOUT --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART

helm template --debug --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART

helm upgrade --install --wait --timeout $INPUT_TIMEOUT --set deploy.project=$INPUT_PROJECT --set deploy.app=$INPUT_APP --set deploy.instance=$INPUT_INSTANCE --set deploy.service=$INPUT_SERVICE --set deploy.version=$INPUT_VERSION -f $(echo $INPUT_VALUE_FILES | sed 's/,/ -f /g') $INCLUDE_VALFILE $INPUT_RELEASE $INPUT_CHART

kubectl rollout restart deployment "$INPUT_PROJECT-$INPUT_APP-$INPUT_SERVICE-$INPUT_INSTANCE" -n $INPUT_PROJECT

echo "* INPUT_PROJECT=${INPUT_PROJECT} " >> $GITHUB_STEP_SUMMARY
echo "* INPUT_APP=${INPUT_APP} " >> $GITHUB_STEP_SUMMARY
echo "* INPUT_SERVICE=${INPUT_SERVICE} " >> $GITHUB_STEP_SUMMARY
echo "* INPUT_INSTANCE=${INPUT_INSTANCE} " >> $GITHUB_STEP_SUMMARY

echo "try this endpoint - url:" >> $GITHUB_STEP_SUMMARY
echo " https://${INPUT_PROJECT}-${INPUT_APP}-${INPUT_SERVICE}-${INPUT_INSTANCE}.dev.datawise.ai " >> $GITHUB_STEP_SUMMARY

INGRES_OUT=`kubectl get ingress -n ${INPUT_PROJECT} ${INPUT_PROJECT}-${INPUT_APP}-${INPUT_SERVICE}-${INPUT_INSTANCE}   -o json 2> /dev/null| jq -r ' .spec.rules[] | .host as $host | .http.paths[] | ( $host + .path)' | sort | grep -v ^/ `

echo " https://${INGRES_OUT} " >> $GITHUB_STEP_SUMMARY
