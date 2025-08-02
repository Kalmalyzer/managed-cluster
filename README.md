
# How to run internal IT services effectively for a small games company in 2025

This is an example of how you can run internal IT services efficiently, for a small-to-mid-sized games company, in the year of 2025. Sometimes you can't or don't want to use cloud-based services but run the services yourself. If you are in this situation, then this exmaple is for you.

The resulting services will require minimal maintenance. Everything will be well documented. If you are out sick or levae, someone else can pick up the stack with minimal instructions. On the flip side, you do need a lot of DevOps and systems administration know-how to make this work.

## Project status

The "local cluster" is working OK, but may need an ingress

On-prem cluster hasn't been tested, and particularly needs a loadbalancer+ingress solution

EKS/GKE isn't present yet

Still need to do cluster monitoring/logging

Still need to do application monitoring/logging

## Overview

We use Kuberenetes as the operational platform. This is suitable for running most types of services, as long as they can be run on Linux.

We cover several ways of setting up the Kubernetes cluster istelf: a local cluster on your development workstation, a cluster run on bare-metal machines or VMs that you operate yourself, or a cluster provided by Google's Kubernetes Engine / Amazon's Elastic Kubernetes Service.

We declare a standard pattern for deploying applications to the cluster. It will be straightforward to understand which applications are currently running.

We set up a CI/CD pipeline for deployment. You can trust the Git repository as the source of truth. The CI/CD pipeline will automatically deploy changes and detect & correct drift (unexpected differences between the Git repository and the currently-live configuraton).

We introduce ways to monitor and understand cluster utilization and health. This is not always straightforward, but necessary so you don't "go blind" when the cluster isn't working correctly.

We intrduce ways to monitor and understand what individual applications on the cluster are doing.

## What's not covered

Software that needs to run directly on bare metal or on VMs are not covered here. Typical examples are test devices, and some CI systems' build agents.

## Before you start: Self-hosted or cloud-hosted?

You can either run the cluster on your own hardware, or use various managed offerings.

**Cost**
This depends on how you want to handle cost. The cloud offerings allow you to add/remove capacity at a minute's notice and you pay only for what you use at any moment. You pay month-to-month for each bit of capacity. You should expect a minimum fee of a few hundred $/month.

The self-hosted approach, on the other hand, allows you to avoid that monthly cost and instead re-purpose existing hardware or make a few up-front investments. You can get as low as $0 + power & network.

**Connectivity to/from other services**
This also depends on where other things are outside of the cluster. If you have other locally-hosted services and file stores on an internal network, and expect the services that run on the cluster to talk a lot to those, then it's easier to also run the cluster internally. You can set up tunnels but it is additional work.

The more you want your services to be directly exposed to the Internet, or the more you want your services to utilize other cloud-hosted services (managed databases etc), the easier it is to run your services in a cloud-hosted cluster as well.

**Maintenance effort**
Self-hosting will require more setup and maintenance work than cloud-hosted. Any less than 100% server grade hardware will break and cause problems every now and then. Whenever this happens, your cluster is broken or at reduced capacity, and until you have acquired new parts, the cluster will remain broken or at reduced capacity. The OSes will need to be kept up-to-date and security patched by you. You will need to develop all snapshot/backup/restore strategies for state.

Cloud-hosted will practically never see downtime or infrastructure-related failure modes. The cloud provider always has redundant hardware ready. The cloud provider manages the OS on the machines for you. OS and Kubernetes version upgrades happen transparently in the background (sometimes involving failover and service restarts). You can expect that the cluster always is present - your responsibility begins at the Kubernetes API level. The more you rely on cloud-hosted services, the more you get snashots/backups/restore solved for you.

**Access**

Cloud-hosted allows people in different locations in the world to work on all aspects of the cluster. 

Self-hosted will sometimes require people to visit the hardware.

## Before you start: Amazon vs Google Cloud vs Azure?

If you want to go cloud-hosted, then all three major providers offer managed Kubernetes services. They all work reasonably well and costs are not wildly different. Pick the one that is most aligned with your needs outside of this cluster specifically. AWS is largest. Google offers the most robust developer experience. Azure is best for anything involving Microsof/Windows services.

## Before you start: k3s vs k8s vs OpenShift vs Talos?

If you want to go self-hosted, then the traditional [k8s](https://kubernetes.io/releases/download/) and [OpenShift](https://developers.redhat.com/products/openshift/overview) are a lot of work.

If you don't want to spend more time than absolutely necessary with OS updates and hardening the host machines, then Talos Linux is currently the best option. It is a Linux OS that has been hardened and stripped down to _only_ run Kubernetes. There's no SSH. There's no command line. The only way you can run software on the machine is by launching Pods via Kubernetes. You use `talosctl` to manage your machines. There is [SaaS support](https://www.siderolabs.com/platform/saas-for-kubernetes/) for managing your individual machines as well, which makes maintenance even easier.

If you for some reason want to run Kubernetes on a machine and still have access to the Linux OS (perhaps because you want to run non-Kubernetes-related things on the same machine), then [k3s](https://k3s.io/) is your best bet. It comes as a single binary. K3s is also more battle-tested than Talos.



# Local development setup

## Create a local, Docker-based cluster

We will use Talos for creating a local cluster. It will start up two containers. These respresent one control plane and one worker node.

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

## Install core services (External Secrets Operator + ArgoCD) on cluster

```
make install-core-services
make delete-default-project
install-local-secret-store
```

ArgoCD will have a Sync Window configured that prevents any automatic synchronization. This is to ensure that you can apply local changes to your local cluster, without ArgoCD automatically backing them out.

## Create secrets used for local testing

For local testing, create the following secrets in your local store:

```
argocd
  argocd-github-app-private-key: ...
  argocd-github-webhook-secret: NOT_USED
```

## Install additional applications

For each application that you want to install:
```
./install_kustomization.sh apps/<app_name>/overlays/local
```
