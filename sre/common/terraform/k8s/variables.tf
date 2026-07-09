
# -------------------------------
# Variables
# -------------------------------

variable "compartment_ocid" {
  type        = string
  description = "(REQUIRED) The OCID of the target OCI compartment where resources will be created."
}

variable "ssh_public_key" {
  type        = string
  description = "(REQUIRED) Public SSH key to access OKE worker nodes. Required for SSH access."
}

variable "project_name" {
  type        = string
  description = "(REQUIRED) The name of the project. It will be appended to name of the resources."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of the Kubernetes cluster."
  default     = "v1.36.1"
}

variable "region" {
  type        = string
  description = "(REQUIRED) The region to deploy the resources"
}