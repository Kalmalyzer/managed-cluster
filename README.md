
# How to run internal IT services effectively for a small games company in 2025

This is an example of how you can run internal IT services efficiently, for a small-to-mid-sized games company, in the year of 2025. Sometimes you can't or don't want to use cloud-based services but run the services yourself. If you are in this situation, then this exmaple is for you.

## Project status

The "local cluster" is working OK, but may need an ingress

On-prem cluster hasn't been tested, and particularly needs a loadbalancer+ingress solution

EKS/GKE isn't present yet

Cluster metrics monitoring & alerting is present via kube-prometheus-stack; no logging though (should use Loki for that)

Still need to do application monitoring/logging

## What you get

You get a complete specification of which applications are installed, and their complete configuration, in a Git repository.

You get an automated mechanism for deploying from the Git repository to the machines where the applications run, including a visual dashboard that shows whether there are any differences between the Git repository and what's currently running.

You get the capability to move applications between machines manually or depending on concurrent use, and pinning applications to specific machines when necessary. 

You get the option to "merge" the disks in all machines into a single, large, virtual disk.

You get a standard way to test-run/deploy the applications one by one on your workstation in a setting that is almost identical to the "production" environment, which is particularly nice when you want to test out updates before rolling them out.

You get a standard way to see whether an application is running or not, when it restarted last, how much memory/CPU it uses, and search through its logs.

The resulting services will require minimal maintenance. Everything will be well documented. If you are out sick or on leave, someone else can pick up the stack with minimal instructions. On the flip side, you do need a lot of DevOps and systems administration know-how to make this work.

## What's not covered

All software will need to be packaged into userspace Linux containers. Software that needs to run directly on bare metal, or directly on VMs, will need to be handled differently. This is typically test devices, and some CI systems' build agents.

All software should preferably be Linux based. Windows will be difficult. MacOS won't work.

This will require a secret manager outside of the cluster. There are [a ton of options](https://external-secrets.io/latest/provider/aws-secrets-manager/) to choose from.

## 1-page introduction

We use Kuberenetes as the operational platform. This is suitable for running most types of services, as long as they can be run on Linux.

We cover several ways of setting up the Kubernetes cluster istelf: a local cluster on your development workstation, a cluster run on bare-metal machines or VMs that you operate yourself, or a cluster provided by Google's Kubernetes Engine / Amazon's Elastic Kubernetes Service.

We declare a standard pattern for deploying applications to the cluster. It will be straightforward to understand which applications are currently running.

We set up a CI/CD pipeline for deployment. You can trust the Git repository as the source of truth. The CI/CD pipeline will automatically deploy changes and detect & correct drift (unexpected differences between the Git repository and the currently-live configuraton).

We introduce ways to monitor and understand cluster utilization and health. This is not always straightforward, but necessary so you don't "go blind" when the cluster isn't working correctly.

We intrduce ways to monitor and understand what individual applications on the cluster are doing.

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

If you don't want to spend more time than absolutely necessary with OS updates and hardening the host machines, then [Talos Linux](https://www.talos.dev/) is currently the best option. It is a Linux OS that has been hardened and stripped down to _only_ run Kubernetes. There's no SSH. There's no command line. The only way you can run software on the machine is by launching Pods via Kubernetes. You use `talosctl` to manage your machines. There is [SaaS support](https://www.siderolabs.com/platform/saas-for-kubernetes/) for managing your individual machines as well, which makes maintenance even easier.

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
./install-app.sh apps/<app_name>
```

## Remove applications


For each application that you want to remove:
```
./remove-app.sh apps/<app_name>
```

This assumes that the manifest is accurate. Many times, the manifest will result in the removal of a namespace, and therefore also any additional resources within that namespace. You may sometimes need to do additional cleanup though.


# GKE cluster setup

## Decide on location

Decide on a [datacenter region](https://cloud.google.com/about/locations) that is close to you.

## Rename and make it yours

Search through the entire repository for the word `kalms.org` and change it to your domain name.

There are some resources in Google Cloud that need globally unique identifiers. For example, any Cloud Storage buckets need to have names not already claimed by any other Google Cloud user. Search through the entire repository for the word `kalms` and change it to a prefix that works for you. The prefix should be max 9 characters in length.

In the rest of the documentation, we will refer to that prefix as `${prefix}`.

## Setup Google Cloud Identity

(This is if you don't already have Google Workspace)

Folow [Google's setup instructions](https://cloud.google.com/identity/docs/set-up-cloud-identity-admin). You will need to own a domain and have a credit card ready.

## Create Google Cloud root folder/project

Create a folder called `${prefix}-managed-cluster` in Google Cloud.

Create a project within the `${prefix}-managed-cluster` folder. Call it `${prefix}-managed-gcp-projects`. Connect it to billing.

Create a Cloud Storage bucket named `${prefix}-managed-managed-gcp-projects-state` within this project. Choose the region where youwill run the cluster. All other settings can be left as default.

## Configure and create remaining GKE projects

Visit [IAM](https://console.cloud.google.com/iam-admin/iam) for your root organization.  Ensure you have the `Folder Admin` role.

Visit your billing account. Choose "manage billing acount". Ensure you have the `Billing Account Administrator` role.

## Create additional GKE projects & Terraform stae buckets

Go through the settings in [infra/gke/gcp-projects/terraform.tfvars](infra/gke/gcp-projects/terraform.tfvars) and update them. Look specifically for any mentions of a region/zone (normally `eurupe-west1`), `billing_account_id`, and `cluster_folder_id`; these need to be updated to match your preferences.

Create additional GKE projects, with a state bucket in each:

```
(cd infra/gke/gcp-projects && terraform init && terraform apply)
````

## Configure and deploy GKE cluster

Also go through the settings in [infra/gke/cluster/terraform.tfvars](infra/gke/cluster/terraform.tfvars) and update them. Look specifically for any mentions of a region/zone (normally `eurupe-west1`); this needs to be updated to match your preferences.

Deploy and bring up the GKE cluster:

```
(cd infra/gke/cluster && terraform init && terraform apply)
````

Once Terraform completes, you should be able to view your cluster in the [Google Cloud web UI](https://console.cloud.google.com/kubernetes/list/overview), as long as you switch to the right project.

## Configure and deploy external-secrets

Begin by creating the GCP resources necessary for External Secrets Opeator to function on GKE:
```
(cd apps/external-secrets/tf/gke && terraform init && terraform apply)
```

After this, install the software onto the cluster manually:

```
ENV=gke ./install-app.sh apps/external-secrets
```

## Configure and deploy Argo CD

Begin by creating the GCP resources necessary for Argo CD to function on GKE:
```
(cd apps/argocd/tf/gke && terraform init && terraform apply)
```

### Configure OAuth for ArgoCD

Configure an [OAuth consent screen](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/#configure-your-oauth-consent-screen) in GCP Console for the `wl-argocd` project.

Configure a new [OAuth Client ID](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/#configure-a-new-oauth-client-id) in GCP Console for the `${prefix}-argocd` project.

Inject this into [apps/argocd/tf/gke/argocd-cm/authenticate-with-google-workspace.patch.yaml](apps/argocd/tf/gke/argocd-cm/authenticate-with-google-workspace.patch.yaml).

### Configure GitHub webhook for ArgoCD

Configure a [GitHub Webhook](https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/) for this repo.

Inject secret into `core-services/self-managed/argo-cd/argocd-secret/github-webhook-secret.yaml`

Add the secret to [Secret Manager](https://console.cloud.google.com/security/secret-manager) in your "${prefix}-argocd" project.

After this, install the software onto the cluster manually:

```
ENV=gke ./install-app.sh apps/argocd
```

You can then access the software, without configuring any domains or SSL certificates, by port-forwarding:

```
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Visit [http://localhost:8080](http://localhost:8080) in a web browser. Username: `admin`, password: run `ENV=gke make get-admin-password`. You should now see the ArgoCD web front-end.
