# Frontend — ederbrito.com.br

Next.js portfolio application. Built on the [Magic Portfolio](https://github.com/once-ui-system/magic-portfolio) template with custom extensions: OpenTelemetry tracing, Prometheus metrics, structured logging, and a production-ready Docker container.

## Table of Contents

- [Stack](#stack)
- [Local Development](#local-development)
- [Environment Variables](#environment-variables)
- [Content Management](#content-management)
- [Build & Container Image](#build--container-image)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Observability](#observability)
- [Project Structure](#project-structure)

## Stack

| Concern | Technology |
|---------|-----------|
| Framework | Next.js 16 (App Router, standalone output) |
| UI | [Once UI](https://once-ui.com) — design system and components |
| Language | TypeScript 5 |
| Styling | SCSS Modules + Once UI design tokens |
| Content | MDX — blog posts and project pages |
| Tracing | OpenTelemetry (OTLP HTTP → Jaeger) |
| Metrics | `prom-client` — exposed at `/api/metrics` |
| Logging | Pino |
| Formatter | Biome |
| Runtime | Node.js >= 24 |

## Local Development

```bash
cd src/frontend
npm install
npm run dev
# http://localhost:3000
```

Other scripts:

```bash
npm run build          # production build
npm run lint           # TypeScript type-check (tsc --noEmit)
npm run biome-write    # format all files with Biome
```

## Environment Variables

Copy `.env.example` to `.env.local` and fill in the values.

| Variable | Required | Description |
|----------|----------|-------------|
| `PAGE_ACCESS_PASSWORD` | No | Password for protected routes |
| `OTEL_SERVICE_NAME` | No | OpenTelemetry service name (default: `ederbrito-frontend`) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | No | OTLP trace export URL (default: `http://localhost:4318/v1/traces`) |
| `LOG_LEVEL` | No | Pino log level (default: `info`) |

In Kubernetes, `OTEL_SERVICE_NAME` and `OTEL_EXPORTER_OTLP_ENDPOINT` are injected by the Deployment manifest and point to the in-cluster Jaeger collector.

## Content Management

All content is file-based MDX. No CMS or database required.

**Blog posts** — add `.mdx` files to `src/app/blog/posts/`

**Work / project entries** — add `.mdx` files to `src/app/work/projects/`

**Site configuration** — `src/resources/once-ui.config.ts` controls theme, navigation, and feature flags.

**Personal content** — `src/resources/content.tsx` contains bio, social links, work history, and page copy.

Pages (blog, work, gallery, about) can be individually enabled or disabled via the config file.

## Build & Container Image

Multi-stage Dockerfile on `node:24-alpine`. The final image:
- Runs as non-root user `nextjs` (UID 1001)
- Exposes port 3000
- Uses Next.js standalone output (no `node_modules` in the runner layer)

```bash
# Build
docker build -t britoederr/ederbrito.com.br:latest src/frontend/

# Run locally
docker run -p 3000:3000 britoederr/ederbrito.com.br:latest
```

The image is built and pushed to Docker Hub (`britoederr/ederbrito.com.br`) by the CI/CD pipeline on every push to `main`.

## Kubernetes Deployment

Manifests are in [`sre/frontend/`](../../sre/frontend/):

| File | Purpose |
|------|---------|
| `namespace.yaml` | `ederbrito` namespace |
| `deployment.yaml` | Single replica; image tag overwritten by CI via `kubectl set image` |
| `service.yaml` | ClusterIP service on port 3000 |
| `httproute.yaml` | Gateway API HTTPRoute routing `ederbrito.com.br` to the frontend |

Apply all manifests:

```bash
kubectl apply -f sre/frontend/
```

Update the running image after a new build:

```bash
kubectl set image deployment/frontend \
  frontend=britoederr/ederbrito.com.br:<tag> \
  -n ederbrito
```

The deployment requires an image pull secret named `dockerhub-secret` in the `ederbrito` namespace:

```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=<user> \
  --docker-password=<token> \
  -n ederbrito
```

## Observability

**Metrics** — Prometheus scrapes `/api/metrics` automatically. The Deployment sets the required annotations:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "3000"
prometheus.io/path: "/api/metrics"
```

**Tracing** — The app uses OpenTelemetry auto-instrumentation (Node.js SDK) initialized in `src/instrumentation.ts`. Traces are exported via OTLP HTTP to the in-cluster Jaeger collector. To use a local collector during development, run Jaeger locally and set:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318/v1/traces
```

**Logs** — Structured JSON logs via Pino, readable from `kubectl logs` or aggregated in Loki.

## Project Structure

```
src/frontend/
├── src/
│   ├── app/
│   │   ├── about/              # About / CV page
│   │   ├── blog/
│   │   │   └── posts/          # MDX blog posts
│   │   ├── gallery/            # Photo gallery
│   │   ├── work/
│   │   │   └── projects/       # MDX project entries
│   │   └── api/
│   │       ├── authenticate/   # Password-protected route auth
│   │       ├── check-auth/
│   │       ├── metrics/        # Prometheus metrics endpoint
│   │       ├── og/             # Open Graph image generation
│   │       └── rss/            # RSS feed
│   ├── components/             # React components (Header, Footer, MDX, etc.)
│   ├── resources/
│   │   ├── once-ui.config.ts   # Theme and feature flags
│   │   ├── content.tsx         # Bio, links, work history, page content
│   │   └── icons.ts
│   ├── types/
│   ├── utils/
│   └── instrumentation.ts      # OpenTelemetry SDK initialization
├── public/
│   ├── images/                 # Static images (avatar, gallery, OG, projects)
│   └── trademarks/
├── Dockerfile
├── next.config.mjs
├── biome.json
└── package.json
```
