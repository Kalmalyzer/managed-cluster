.PHONY: activate
.PHONY: install-local-secret-store export-local-secrets import-local-secrets

activate:
	docker start talos-default-worker-1 talos-default-controlplane-1

# Other utility functions

install-local-secret-store:
	kubectl config use-context $(KUBECTL_CONTEXT_NAME)
	kubectl apply -k apps/local-secret-store

export-local-secrets:
	kubectl get secret -n local-secret-store -o yaml > local-secrets.yaml

import-local-secrets:
	kubectl apply -f local-secrets.yaml
