
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

variable "domain_name" {
  type        = string
  description = "(REQUIRED) The domain name for the monitoring stack."
  default     = "ederbrito.com.br"
}

# DNS Configuration
variable "dns_ttl" {
  type        = number
  description = "TTL for DNS records in seconds"
  default     = 300
}

variable "ssl_private_key_path" {
  type        = string
  description = "(Required) TLS Certificate Key Path"
  default     = "privkey.pem"
}

variable "ssl_public_cert_path" {
  type        = string
  description = "(Required) TLS Certificate Public Cert"
  default     = "cert.pem"
}

variable "ssl_ca_cert_path" {
  type        = string
  description = "(Required) TLS Certificate CA Cert"
  default     = "chain.pem"
}
