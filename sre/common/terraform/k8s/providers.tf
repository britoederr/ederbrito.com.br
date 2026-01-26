terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.14.0"
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