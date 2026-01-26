# Retrieve all availability domains for the given compartment
data "oci_containerengine_clusters" "oke_cluster" {
  compartment_id = var.compartment_ocid
  name           = "${local.prefix_name}-cluster"
  state          = ["ACTIVE"]
}

data "oci_containerengine_cluster_kube_config" "oke_kubeconfig" {
  cluster_id = data.oci_containerengine_clusters.oke_cluster.clusters[0].id
}

data "kubernetes_service_v1" "istio_ingress" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = "istio-system"
  }
  provider = kubernetes.oke
}