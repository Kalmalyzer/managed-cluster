#!/bin/bash

# This script installs an application into a k8s cluster
# If the manifest includes any CRDs, it will first install the CRDs
#  and wait for those to become established, before proceeding
#  with the remaining resources
#
# ArgoCD contains similar built-in logic for its own manifest handling

set -euo pipefail

APP_DIR=$1

TEMPLATE=$(kubectl kustomize --enable-helm "${APP_DIR}")

# Install CRDs if there are any

CRDS=$(echo "${TEMPLATE}" | yq 'select(.kind == "CustomResourceDefinition")')

CRD_NAMES=$(echo "${CRDS}" | yq -N '.metadata.name')

if [[ ! -z ${CRD_NAMES} ]]; then

  echo "${CRDS}" | kubectl apply -f -

  for CRD in ${CRD_NAMES}; do
    kubectl wait --for condition=established --timeout=60s "crd/${CRD}"

  done
fi

# Install remainder of application

echo "${TEMPLATE}" | kubectl apply -f -

