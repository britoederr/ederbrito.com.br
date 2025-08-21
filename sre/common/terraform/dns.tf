# -------------------------------
# DNS Configuration for Monitoring Stack
# -------------------------------

# data "oci_dns_zones" "main_zone" {
#   compartment_id = var.compartment_ocid
#   name           = var.domain_name
# }

# -------------------------------
# DNS Records for Monitoring Services
# -------------------------------

# Grafana DNS Record
resource "oci_dns_record" "grafana" {
  zone_name_or_id = var.domain_name
  domain          = "grafana.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].ip


}

# Prometheus DNS Record
resource "oci_dns_record" "prometheus" {
  zone_name_or_id = "ederbrito.com.br"
  domain          = "prometheus.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].ip


}

# Jaeger DNS Record
resource "oci_dns_record" "jaeger" {
  zone_name_or_id = "ederbrito.com.br"
  domain          = "jaeger.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].ip


}

# Kiali DNS Record
resource "oci_dns_record" "kiali" {
  zone_name_or_id = "ederbrito.com.br"
  domain          = "kiali.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].ip


}

# Loki DNS Record
resource "oci_dns_record" "loki" {
  zone_name_or_id = "ederbrito.com.br"
  domain          = "loki.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service.istio_ingress.status[0].load_balancer[0].ingress[0].ip


}
