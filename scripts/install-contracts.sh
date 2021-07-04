#!/usr/bin/env bash

if [ -z "$AZURE_PAT" ]
then
  echo "Environment variable AZURE_PAT needs to be set to your personal access token for Azure"
  exit -1
fi
if [ -z "$AZURE_GIT" ]
then
  echo "Environment variable AZURE_GIT needs to be set to clone contracts"
  exit -1
fi

BASEDIR=$(dirname "$0")
mkdir -p "${BASEDIR}/../.deploy"
envsubst < ${BASEDIR}/../../contracts/k8s/contracts.template > ${BASEDIR}/../.deploy/contracts.yaml
kubectl apply -f ${BASEDIR}/../.deploy
