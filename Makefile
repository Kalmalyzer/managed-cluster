.PHONY: validate validate-apps validate-apps-config validate-infra
.PHONY: install-core-services delete-default-project
.PHONY: restart-argocd-server restart-argocd-application-controller restart-argocd-dex-server
.PHONY: port-forward-argocd-server get-admin-password install-local-secret-store export-local-secrets import-local-secrets

# Check if ENV is set and valid
ifeq ($(strip $(ENV)),)
ENV:=local
endif

VALID_ENVS := $(shell yq 'keys | .[]' environments.yaml)
ENV_VALID := $(filter $(ENV),$(VALID_ENVS))
ifeq ($(strip $(ENV_VALID)),)
$(error ENV '$(ENV)' is not a valid environment. Valid values are: $(VALID_ENVS))
endif

KUBECTL_CONTEXT_NAME:=$(shell yq .${ENV}.kubectlContextName < environments.yaml)
CLUSTER_NAME:=$(shell yq .${ENV}.clusterName < environments.yaml)

validate: validate-apps validate-apps-config validate-infra

# Find and validate all root kustomization.yaml files in apps folder
# This finds kustomization.yaml files at any depth, but ignores nested ones
# when a parent directory already has a kustomization.yaml file
validate-apps:
	@echo "Validating kustomization.yaml files in apps folder..."
	@find apps -name "kustomization.yaml" -type f | while read file; do \
		dir=$$(dirname $$(dirname "$$file")); \
		parent_has_kustomization=false; \
		while [ "$$dir" != "apps" ] && [ "$$dir" != "." ]; do \
			if [ -f "$$dir/kustomization.yaml" ]; then \
				parent_has_kustomization=true; \
				break; \
			fi; \
			dir=$$(dirname "$$dir"); \
		done; \
		if [ "$$parent_has_kustomization" = "false" ]; then \
			echo "Validating: $$file"; \
			kubectl kustomize --enable-helm "$$(dirname "$$file")" >/dev/null; \
		fi; \
	done

# Find and validate all root kustomization.yaml files in apps-config folder
# This finds kustomization.yaml files at any depth, but ignores nested ones
# when a parent directory already has a kustomization.yaml file
validate-apps-config:
	@echo "Validating kustomization.yaml files in apps-config folder..."
	@find apps-config -name "kustomization.yaml" -type f | while read file; do \
		dir=$$(dirname $$(dirname "$$file")); \
		parent_has_kustomization=false; \
		while [ "$$dir" != "apps-config" ] && [ "$$dir" != "." ]; do \
			if [ -f "$$dir/kustomization.yaml" ]; then \
				parent_has_kustomization=true; \
				break; \
			fi; \
			dir=$$(dirname "$$dir"); \
		done; \
		if [ "$$parent_has_kustomization" = "false" ]; then \
			echo "Validating: $$file"; \
			kubectl kustomize --enable-helm "$$(dirname "$$file")" >/dev/null; \
		fi; \
	done

# Find and validate all terraform projects in the repository
# A terraform project is defined here as a folder that has a .terraform-version file in it
validate-infra:
	@echo "Validating terraform projects..."
	@find . -name ".terraform-version" -type f | while read file; do \
		dir=$$(dirname $$(dirname "$$file")); \
		echo "Validating: $$dir"; \
		(cd "$$dir" && terraform validate); \
	done

# Management operations for cluster

install-core-services:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	ENV=$(ENV) ./install-app.sh apps/external-secrets
	ENV=$(ENV) ./install-app.sh apps/argocd

delete-default-project:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl delete appproject default -n argocd

restart-argocd-server:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl rollout restart deployment argocd-server -n argocd

restart-argocd-application-controller:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl rollout restart statefulset argocd-application-controller -n argocd

restart-argocd-dex-server:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl rollout restart deployment argocd-dex-server -n argocd

port-forward-argocd-server:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl port-forward services/argocd-server 8000:80 -n argocd

get-admin-password:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

install-local-secret-store:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl apply -k apps/local-secret-store

export-local-secrets:
	kubectl get secret -n local-secret-store -o yaml > local-secrets.yaml

import-local-secrets:
	kubectl apply -f local-secrets.yaml
