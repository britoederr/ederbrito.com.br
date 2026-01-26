terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }

  required_version = ">=1.1"

  backend "oci" {
    bucket    = ""
    namespace = ""
    key       = ""
  }
}

provider "oci" {
  region = var.region
}

provider "kubernetes" {
  alias = "oke"

  host = local.kubeconfig.clusters[0].cluster.server

  cluster_ca_certificate = base64decode(
    local.kubeconfig.clusters[0].cluster["certificate-authority-data"]
  )

  exec {
    api_version = local.kubeconfig.users[0].user.exec.apiVersion
    command     = local.kubeconfig.users[0].user.exec.command
    args        = local.kubeconfig.users[0].user.exec.args
  }
}
