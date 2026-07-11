# Agent guide — ederbrito.com.br

Short index for AI tools. Prefer this file over reading every README.

## Monorepo map

| Path | What it is | Deep docs |
|------|------------|-----------|
| `src/frontend/` | Next.js 16 portfolio (Once UI) | `src/frontend/README.md` |
| `src/backend/` | Ideas only — no runnable APIs yet | `*/idea.md` |
| `sre/frontend/` | App K8s manifests (Deployment, Service, HTTPRoute) | `sre/README.md` |
| `sre/common/terraform/k8s/` | OKE cluster + VCN (Terraform) | `sre/README.md` |
| `sre/common/terraform/dns/` | OCI DNS A records → Cilium gateway LB | `sre/README.md` |
| `sre/common/kubernetes/` | Platform: Gateway, cert-manager, observability | `sre/README.md` |
| `sre/dashboards/` | Grafana JSON (manual import; do not load into context) | `sre/README.md` |
| `.github/workflows/` | CI: frontend deploy + OKE/platform bootstrap | — |

## Edit X → read Y

- Frontend UI/components → `src/frontend/AGENTS.md` + `.cursor/rules/frontend.mdc`
- Frontend content (blog/work) → MDX under `src/frontend/src/app/` + `src/resources/content.tsx`
- Terraform / OCI → `.cursor/rules/sre-terraform.mdc` + `sre/README.md`
- K8s manifests / Cilium / certs → `.cursor/rules/sre-k8s.mdc` + `sre/README.md`
- CI behavior → `.github/workflows/*.yml` (path filters matter)

## Hard constraints

- **Cloud:** OCI OKE Always Free (`sa-saopaulo-1`), not AWS EKS.
- **Nodes:** ARM64 `VM.Standard.A1.Flex` — images must be `linux/arm64` (or multi-arch).
- **CNI / ingress:** Cilium (exclusive) + Hubble; Gateway API for ingress. No Istio/Kiali.
- **Image tags:** CI sets frontend image via `kubectl set image` — do not hardcode SHAs in manifests for deploys.
- **Secrets:** Never commit `.env`, `.tfvars`, OCI keys, or Docker Hub tokens.

## Key commands

```bash
# Frontend
cd src/frontend && npm ci && npx tsc --noEmit && npx biome check . && npm run build

# Terraform (from module dir; needs OCI creds + backend)
cd sre/common/terraform/k8s && terraform init && terraform plan
cd sre/common/terraform/dns && terraform init && terraform plan
```

## Deploy ownership

1. Terraform applies OKE + DNS.
2. Platform workflow installs Cilium/Hubble, cert-manager, applies `sre/common/kubernetes/`.
3. Frontend workflow builds/pushes Docker image and applies `sre/frontend/`.

PRs: plan/validate only. Push to `main` / tags: apply + deploy.

## Token hygiene

Do not load `node_modules`, `.next`, lockfiles, `.terraform`, or large Grafana JSON into context. Use `.cursorignore`. Keep answers as patches, not README dumps.
