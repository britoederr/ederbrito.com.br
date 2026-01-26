# -------------------------------
# Outputs
# -------------------------------

# OKE Cluster Outputs
output "oke_cluster_id" {
  description = "The OCID of the OKE cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "oke_cluster_endpoint" {
  description = "The Kubernetes API endpoint"
  value       = oci_containerengine_cluster.oke_cluster.endpoints[0].kubernetes
}

output "oke_cluster_ip_address" {
  description = "The Kubernetes API endpoint IP address"
  value       = oci_containerengine_cluster.oke_cluster.endpoints[0].kubernetes
}

# Network Outputs
output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.oke_vcn.id
}

output "lb_subnet_id" {
  description = "The OCID of the load balancer subnet"
  value       = oci_core_subnet.lb_subnet.id
}

output "node_subnet_id" {
  description = "The OCID of the worker node subnet"
  value       = oci_core_subnet.node_subnet.id
}

output "api_endpoint_subnet_id" {
  description = "The OCID of the API endpoint subnet"
  value       = oci_core_subnet.api_endpoint_subnet.id
}
