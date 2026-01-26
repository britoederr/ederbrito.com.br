locals {
  project_name = "ederbrito"
  prefix_name  = "oke-${local.project_name}" # Prefix used to identity all resources refering to this module

  kubeconfig = yamldecode(
    data.oci_containerengine_cluster_kube_config.oke_kubeconfig.content
  )

}
