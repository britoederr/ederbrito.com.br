terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=5.0.0"
    }
  }
}

provider "oci" {
  region = "sa-saopaulo-1"
}


# -------------------------------
# OKE Cluster
# -------------------------------
resource "oci_containerengine_cluster" "oke_cluster" {
  name           = "oke-ederbrito-cluster"
  compartment_id = var.compartment_ocid
  kubernetes_version = "v1.33.1"

  # Avoid enhanced cluster costs
  type = "BASIC_CLUSTER"

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  vcn_id = oci_core_vcn.oke_vcn.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.api_endpoint_subnet.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.lb_subnet.id]
  }
}

# -------------------------------
# Node Pool
# -------------------------------
resource "oci_containerengine_node_pool" "oke_k8s_node_pool" {
  name           = "oke-ederbrito-k8s-pool"
  compartment_id = var.compartment_ocid
  cluster_id     = oci_containerengine_cluster.oke_cluster.id
  kubernetes_version = "v1.33.1"
  node_shape     = "VM.Standard.A1.Flex"

  node_config_details {
    size = 2
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    node_pool_pod_network_option_details {
      cni_type = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [oci_core_subnet.node_subnet.id]
    }
  }

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaau5pjbyitadofmvxbyerykujxtjlv4oqumkgdtql4qseamnpby2ra"
  }

  ssh_public_key = var.ssh_public_key
  # Free Tier boot volume size
  node_metadata = {
    "bootVolumeSizeInGB" = "50"
  }

}
