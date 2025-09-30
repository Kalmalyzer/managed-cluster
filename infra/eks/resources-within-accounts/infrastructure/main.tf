
module "kalms-argocd" {
  source = "./accounts/kalms-argocd"
}

module "kalms-external-secrets" {
  source = "./accounts/kalms-external-secrets"
}

module "kalms-managed-cluster" {
  source = "./accounts/kalms-managed-cluster"
}

module "kalms-p4" {
  source = "./accounts/kalms-p4"
}

