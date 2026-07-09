
# -------------------------------
# Locals
# -------------------------------

locals {
  project_name = var.project_name
  prefix_name  = "oke-${local.project_name}" # Prefix used to identity all resources refering to this module

  # Strip leading "v" for image name matching (e.g. v1.36.1 -> 1.36.1).
  kubernetes_version_number = trimprefix(var.kubernetes_version, "v")

  oke_sources = data.oci_containerengine_node_pool_option.oke_node_pool_option.sources

  # Prefer OL8 OKE images matching the cluster Kubernetes version (cgroups v2 for 1.35+).
  oke_ol8_versioned_images = [
    for source in local.oke_sources : source.image_id
    if can(regex("Oracle-Linux-8.*-OKE-${local.kubernetes_version_number}", source.source_name))
  ]

  oke_ol8_any_images = [
    for source in local.oke_sources : source.image_id
    if can(regex("Oracle-Linux-8.*-OKE-", source.source_name))
  ]

  oke_node_image_id = (
    length(local.oke_ol8_versioned_images) > 0 ? local.oke_ol8_versioned_images[0] :
    length(local.oke_ol8_any_images) > 0 ? local.oke_ol8_any_images[0] :
    null
  )
}