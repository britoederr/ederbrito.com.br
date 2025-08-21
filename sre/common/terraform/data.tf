
# -------------------------------
# Data Sources
# -------------------------------

# Retrieve all availability domains for the given compartment
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Retrieve the Oracle Services Network service entry 
# for setting up service gateways
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_containerengine_cluster_kube_config" "oke_kubeconfig" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
}

resource "local_sensitive_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_kubeconfig.content
  filename = "${path.module}/kubeconfig"
}

data "kubernetes_service" "istio_ingress" {
  metadata {
    name      = "istio-ingress"  # default name in Istio Helm
    namespace = "istio-system"
  }

  provider = kubernetes.oke

  depends_on = [helm_release.istio_ingress]
}
