# Retrieve all availability domains for the given compartment
data "oci_containerengine_clusters" "oke_cluster" {
  compartment_id = var.compartment_ocid
  name           = "${local.prefix_name}-cluster"
  state          = ["ACTIVE"]
}

data "oci_containerengine_cluster_kube_config" "oke_kubeconfig" {
  cluster_id = data.oci_containerengine_clusters.oke_cluster.clusters[0].id
}

# Cilium creates a LoadBalancer Service named after the Gateway resource.
data "kubernetes_service_v1" "cilium_gateway" {
  metadata {
    name      = "ederbrito-gateway"
    namespace = "kube-system"
  }
  provider = kubernetes.oke
}
