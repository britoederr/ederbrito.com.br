# Main Record
resource "oci_dns_record" "main" {
  zone_name_or_id = var.domain_name
  domain          = var.domain_name
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}

# Grafana DNS Record
resource "oci_dns_record" "grafana" {
  zone_name_or_id = var.domain_name
  domain          = "grafana.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}

# Prometheus DNS Record
resource "oci_dns_record" "prometheus" {
  zone_name_or_id = var.domain_name
  domain          = "prometheus.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}

# Jaeger DNS Record
resource "oci_dns_record" "jaeger" {
  zone_name_or_id = var.domain_name
  domain          = "jaeger.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}

# Kiali DNS Record
resource "oci_dns_record" "kiali" {
  zone_name_or_id = var.domain_name
  domain          = "kiali.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}

# Loki DNS Record
resource "oci_dns_record" "loki" {
  zone_name_or_id = var.domain_name
  domain          = "loki.${var.domain_name}"
  rtype           = "A"
  ttl             = var.dns_ttl

  rdata = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].ip
}
