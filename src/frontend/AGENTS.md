# Frontend agents

Next.js 16 + Once UI portfolio app.

- Conventions: `.cursor/rules/frontend.mdc` (and legacy notes below if needed).
- Human docs: `README.md` in this directory.
- Content: MDX pages + `src/resources/content.tsx`.
- Observability: OTEL → Jaeger; metrics at `/api/metrics`; Pino logs.
- Deploy: Docker multi-arch → OKE via `.github/workflows/frontend-deploy.yml`.

Do not reintroduce Istio sidecar annotations or VirtualServices; routing is Gateway API / HTTPRoute under `sre/frontend/`.
