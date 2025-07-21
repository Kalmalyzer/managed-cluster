
# Quick setup

```
brew install siderolabs/tap/talosctl

# Create a cluster called "talos-default" within a Docker container
# The cluster will be active both in talosctl (as "talos-default")
#   and in kubectl (as "admin@talos-default")
# This takes typically 1-4 minutes to complete
# The control plane node will receive IP 10.5.0.2
talosctl cluster create

# List all nodes (both control plane and workers):
kubectl get nodes -o wide

# Configure talosctl to default to operating against the control plane node
talosctl config node 10.5.0.2
```

