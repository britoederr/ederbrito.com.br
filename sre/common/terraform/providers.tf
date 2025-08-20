terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.14.0"
    }
  }

  required_version = ">=1.7"

  backend "oci" {
    bucket    = "terraform-state"
    namespace = "grop2geoxikg"
    key       = "ederbrito/common/oke"
  }
}

provider "oci" {
  region = "sa-saopaulo-1"
}

provider "kubernetes" {
  alias       = "oke"
  config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes = {
    config_path = local_file.kubeconfig.filename
  }
}