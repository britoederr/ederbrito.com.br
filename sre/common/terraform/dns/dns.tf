locals {
  # OCI LB may still be Pending when DNS plan runs; fail clearly instead of indexing null.
  gateway_lb_ip = try(
    data.kubernetes_service_v1.cilium_gateway.status[0].load_balancer[0].ingress[0].ip,
    null
  )
}

check "cilium_gateway_has_lb_ip" {
  assert {
    condition     = local.gateway_lb_ip != null && local.gateway_lb_ip != ""
    error_message = "Service kube-system/ederbrito-gateway has no LoadBalancer IP yet. Wait for OCI LB provisioning (often 3-5 minutes), then re-run DNS plan. Check: kubectl get svc -n kube-system ederbrito-gateway"
  }
}

# Main Record
resource "oci_dns_record" "main" {
  zone_name_or_id = var.domain_name
  domain          = var.domain_name
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}

# Grafana DNS Record
resource "oci_dns_record" "grafana" {
  zone_name_or_id = var.domain_name
  domain          = "grafana.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}

# Prometheus DNS Record
resource "oci_dns_record" "prometheus" {
  zone_name_or_id = var.domain_name
  domain          = "prometheus.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}

# Jaeger DNS Record
resource "oci_dns_record" "jaeger" {
  zone_name_or_id = var.domain_name
  domain          = "jaeger.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}

# Hubble DNS Record
resource "oci_dns_record" "hubble" {
  zone_name_or_id = var.domain_name
  domain          = "hubble.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}

# Loki DNS Record
resource "oci_dns_record" "loki" {
  zone_name_or_id = var.domain_name
  domain          = "loki.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.gateway_lb_ip
}
