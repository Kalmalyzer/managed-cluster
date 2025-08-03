#!/bin/bash

# This script installs a kustomization into a k8s cluster
# If the manifest includes any CRDs, it will first install the CRDs
#  and wait for those to become established, before proceeding
#  with the remaining resources
#
# ArgoCD contains similar built-in logic for its own manifest handling for an app
#
# Usage: [ENV=<env>] ./install_app.sh <app_root_dir>

set -euo pipefail

APP_ROOT_DIR=$1

# APP_ROOT_DIR must be specified
if [[ -z "${APP_ROOT_DIR}" ]]; then
  echo "Usage: [ENV=<env>] ./install_app.sh <app_root_dir>"
  exit 1
fi

# ENV is provided as an environment variable, or defaults to "local"
ENV="${ENV:-local}"

# Ensure that ENV is valid by looking up environments.yaml
if ! yq ".${ENV}" environments.yaml > /dev/null 2>&1; then
  KNOWN_ENVS=$(yq 'keys | join(", ")' environments.yaml)
  echo "Error: Environment ${ENV} is not known. Known names are: ${KNOWN_ENVS}."
  exit 1
fi

# Locate the kustomization.yaml file for the app

if [[ -f "${APP_ROOT_DIR}/overlays/${ENV}/kustomization.yaml" ]]; then
  APP_DIR="${APP_ROOT_DIR}/overlays/${ENV}"
elif [[ -f "${APP_ROOT_DIR}/kustomization.yaml" ]]; then
  APP_DIR="${APP_ROOT_DIR}"
else
  echo "Error: Could not find kustomization.yaml in either:"
  echo "  ${APP_ROOT_DIR}/overlays/${ENV}/kustomization.yaml"
  echo "  ${APP_ROOT_DIR}/kustomization.yaml"
  exit 1
fi

# Activate kubectl context
KUBECTL_CONTEXT_NAME=$(yq .${ENV}.kubectlContextName < environments.yaml)
kubectl config use-context "${KUBECTL_CONTEXT_NAME}"

# Process the kustomization into a single list of manifests

TEMPLATE=$(kubectl kustomize --enable-helm "${APP_DIR}")

# Install CRDs if there are any

CRDS=$(echo "${TEMPLATE}" | yq 'select(.kind == "CustomResourceDefinition")')
if [[ -n "${CRDS}" ]]; then
  CRD_NAMES=$(echo "${CRDS}" | yq -N '.metadata.name')

  echo "${CRDS}" | kubectl apply --server-side -f -

  for CRD in ${CRD_NAMES}; do
    kubectl wait --for condition=established --timeout=60s "crd/${CRD}"
  done
fi

# Install remainder of application

echo "${TEMPLATE}" | kubectl apply --server-side -f -

