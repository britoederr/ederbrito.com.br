locals {
  # OCI LB may still be Pending when DNS plan runs; fail clearly instead of indexing null.
  ingress_lb_ip = try(
    data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip,
    null
  )
}

check "istio_ingress_has_lb_ip" {
  assert {
    condition     = local.ingress_lb_ip != null && local.ingress_lb_ip != ""
    error_message = "Service istio-system/istio-ingressgateway has no LoadBalancer IP yet. Wait for OCI LB provisioning (often 3-5 minutes), then re-run DNS plan. Check: kubectl get svc -n istio-system istio-ingressgateway"
  }
}

# Main Record
resource "oci_dns_record" "main" {
  zone_name_or_id = var.domain_name
  domain          = var.domain_name
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}

# Grafana DNS Record
resource "oci_dns_record" "grafana" {
  zone_name_or_id = var.domain_name
  domain          = "grafana.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}

# Prometheus DNS Record
resource "oci_dns_record" "prometheus" {
  zone_name_or_id = var.domain_name
  domain          = "prometheus.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}

# Jaeger DNS Record
resource "oci_dns_record" "jaeger" {
  zone_name_or_id = var.domain_name
  domain          = "jaeger.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}

# Kiali DNS Record
resource "oci_dns_record" "kiali" {
  zone_name_or_id = var.domain_name
  domain          = "kiali.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}

# Loki DNS Record
resource "oci_dns_record" "loki" {
  zone_name_or_id = var.domain_name
  domain          = "loki.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = local.ingress_lb_ip
}
