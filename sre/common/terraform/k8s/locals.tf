
# -------------------------------
# Locals
# -------------------------------

locals {
  project_name = var.project_name
  prefix_name  = "oke-${local.project_name}" # Prefix used to identity all resources refering to this module
}