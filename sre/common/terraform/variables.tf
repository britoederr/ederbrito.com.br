
# -------------------------------
# Variables
# -------------------------------

variable "compartment_ocid" {
  type = string
  description = "(REQUIRED) The OCID of the target OCI compartment where resources will be created."
}

variable "ssh_public_key" {
  type = string
  description = "(REQUIRED) Public SSH key to access OKE worker nodes. Required for SSH access."
}
