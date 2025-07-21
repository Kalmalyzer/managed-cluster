.PHONY: validate
.PHONY: install-core-services-manually-managed install-core-services-self-managed delete-default-project
.PHONY: restart-argocd-server restart-argocd-application-controller restart-argocd-dex-server
.PHONY: get-admin-password

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

# Validation of all kustomizations & terraform logic

validate:
	kubectl kustomize core-services/manually-managed/argocd/phase1 >/dev/null
	kubectl kustomize core-services/manually-managed/argocd/phase2/overlays/${ENV} >/dev/null
	kubectl kustomize core-services/manually-managed/external-secrets >/dev/null
	kubectl kustomize core-services/self-managed/argo-cd/overlays/${ENV} >/dev/null

# Management operations for cluster

install-core-services-manually-managed:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl apply -k core-services/manually-managed/argocd/phase1
	kubectl apply -k core-services/manually-managed/argocd/phase2/overlays/${ENV}
	kubectl apply -k core-services/manually-managed/external-secrets

install-core-services-self-managed:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl apply -k core-services/self-managed/argo-cd/overlays/${ENV}

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

get-admin-password:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
