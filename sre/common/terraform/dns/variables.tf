variable "compartment_ocid" {
  type        = string
  description = "(REQUIRED) The OCID of the target OCI compartment where resources will be created."
}

variable "domain_name" {
  type        = string
  description = "(REQUIRED) The domain name for the DNS records."
}

variable "dns_ttl" {
  type        = number
  description = "TTL for DNS records in seconds"
  default     = 300
}

variable "region" {
  type        = string
  description = "The region to deploy the resources"
}