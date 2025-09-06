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

if [[ -f "${APP_ROOT_DIR}/${ENV}/k8s/kustomization.yaml" ]]; then
  APP_DIR="${APP_ROOT_DIR}/${ENV}/k8s"
elif [[ -f "${APP_ROOT_DIR}/k8s/kustomization.yaml" ]]; then
  APP_DIR="${APP_ROOT_DIR}/k8s"
else
  echo "Error: Could not find kustomization.yaml in either:"
  echo "  ${APP_ROOT_DIR}/${ENV}/k8s/kustomization.yaml"
  echo "  ${APP_ROOT_DIR}/k8s/kustomization.yaml"
  exit 1
fi

# Activate kubectl context
KUBECTL_CONTEXT_NAME=$(yq .${ENV}.kubectlContextName < environments.yaml)
kubectl config use-context "${KUBECTL_CONTEXT_NAME}"

# Process the kustomization into a single list of manifests

TEMPLATE=$(kubectl kustomize --enable-helm "${APP_DIR}")

# Remove finalizers from Application, AppProject and ApplicationSetresources in the manifest
# For each such resource in the manifest, patch the live resource to remove finalizers if it exists
# Othwerise the finalizer may cause deadlocks during deletion since ArgoCD isn't there to react to the finalizer
RESOURCES_WITH_PROBLEMATIC_FINALIZERS=$(echo "${TEMPLATE}" | yq 'select(.kind == "Application" or .kind == "AppProject" or .kind == "ApplicationSet")')

RESOURCES_TO_REMOVE_FINALIZERS_FROM=$(echo "${RESOURCES_WITH_PROBLEMATIC_FINALIZERS}" | yq -r '. as $item ireduce ([]; ["\($item.kind) \($item.metadata.name) \($item.metadata.namespace)"]) | .[]')

if [[ "${RESOURCES_TO_REMOVE_FINALIZERS_FROM}" != *"null null null"* ]]; then
  while read -r line; do
    KIND=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $2}')
    NAMESPACE=$(echo "$line" | awk '{print $3}')
    kubectl patch "$KIND" "$NAME" -n "$NAMESPACE" --type=merge -p '{"metadata":{"finalizers":[]}}' || true
  done <<< "${RESOURCES_TO_REMOVE_FINALIZERS_FROM}"
fi

# Remove all resources

echo "${TEMPLATE}" | kubectl delete -f - --wait=true
