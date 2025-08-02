#!/bin/bash

# This script removes a kustomization into a k8s cluster
# It assumes that the manifest lists exactly all resources related to the app as it
#  currently is deployed
#
# ArgoCD has smarter built-in logic for its own manifest handling for an app;
#  it assigns labels to resources during installation time. This is
#  a poor man's replacement for that mechanism.
#
# Usage: [ENV=<env>] ./remove_app.sh <app_root_dir>

set -euo pipefail

APP_ROOT_DIR=$1

# APP_ROOT_DIR must be specified
if [[ -z "${APP_ROOT_DIR}" ]]; then
  echo "Usage: [ENV=<env>] ./remove_app.sh <app_root_dir>"
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

# Remove all resources

echo "${TEMPLATE}" | kubectl delete -f - --wait=true
