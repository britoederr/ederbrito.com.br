# ederbrito.com.br

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/terraform-1.12+-blue.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.33+-blue.svg)](https://kubernetes.io/)
[![OCI](https://img.shields.io/badge/OCI-Always%20Free-orange.svg)](https://www.oracle.com/cloud/free/)

Personal portfolio running on a self-managed Kubernetes cluster hosted entirely on Oracle Cloud Infrastructure's Always Free tier — no monthly infrastructure cost.

**Live**: [ederbrito.com.br](https://ederbrito.com.br)

---

## What This Is

This repository contains the full source for my personal portfolio site and the infrastructure that runs it. It serves two purposes:

1. **A working portfolio** — built with Next.js, featuring a blog, project showcase, photo gallery, and about page.
2. **An infrastructure template** — a reproducible, zero-cost Kubernetes setup on OCI that others can fork and adapt.

## Stack at a Glance

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 16, React 19, TypeScript, Once UI |
| Container | Docker (multi-stage, `node:24-alpine`, non-root) |
| Orchestration | Kubernetes 1.34 on OCI (Oracle Kubernetes Engine) |
| Service Mesh | Istio 1.28 — mTLS, traffic management, ingress |
| TLS | cert-manager + Let's Encrypt |
| Observability | Prometheus, Grafana, Loki, Jaeger, Kiali |
| Infrastructure | Terraform (OCI provider) |
| CI/CD | GitHub Actions |
| Cloud | Oracle Cloud Infrastructure — Always Free tier |

## Architecture Overview

```
Internet
    │
    ▼
OCI Load Balancer (free tier)
    │
    ▼
Istio Ingress Gateway
    │
    ├──▶ ederbrito.com.br          →  Next.js frontend (namespace: ederbrito)
    ├──▶ grafana.ederbrito.com.br  →  Grafana
    ├──▶ jaeger.ederbrito.com.br   →  Jaeger
    ├──▶ prometheus.ederbrito.com.br → Prometheus
    ├──▶ loki.ederbrito.com.br     →  Loki
    └──▶ kiali.ederbrito.com.br    →  Kiali

OKE Cluster (2× VM.Standard.A1.Flex — ARM, 2 OCPUs / 12GB RAM each)
    Private subnet ← NAT Gateway → Internet
```

Terraform provisions the OCI infrastructure (VCN, OKE cluster, DNS). Kubernetes manifests and Helm charts handle everything running inside the cluster.

## Cost

The entire setup runs at **$0/month** using OCI's Always Free tier with an external DNS provider (e.g., Cloudflare). If using OCI DNS, the cost is ~$0.50/month for the DNS zone.

See the [infrastructure README](sre/README.md#cost-breakdown) for a full breakdown.

## Repository Layout

```
ederbrito.com.br/
├── src/
│   └── frontend/       # Next.js application  →  see src/frontend/README.md
└── sre/
    ├── frontend/        # Kubernetes manifests for the frontend app
    └── common/          # Terraform (OCI infra) + observability stack manifests
                         # →  see sre/README.md
```

## Documentation

- [Frontend — setup, local dev, deployment](src/frontend/README.md)
- [Infrastructure — Terraform, Kubernetes, observability, CI/CD](sre/README.md)

## License

MIT — see [LICENSE](LICENSE).

The frontend is based on [Magic Portfolio](https://github.com/once-ui-system/magic-portfolio) (CC BY-NC 4.0). Attribution required; commercial use requires an [Once UI Pro](https://once-ui.com/pricing) license.

## Author

**Éder Brito** — [ederbrito.com.br](https://ederbrito.com.br) · [GitHub](https://github.com/ederbrito)
