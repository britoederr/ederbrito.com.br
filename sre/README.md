# Infrastructure — ederbrito.com.br

Terraform and Kubernetes configuration for running the portfolio on OCI's Always Free tier. Covers the OKE cluster, networking, DNS, service mesh, observability stack, and the frontend Kubernetes deployment.

## Table of Contents

- [Layout](#layout)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Observability Stack](#observability-stack)
- [Frontend Deployment](#frontend-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Configuration Reference](#configuration-reference)
- [Making It 100% Free](#making-it-100-free)
- [Cost Breakdown](#cost-breakdown)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Important Notes](#important-notes)

## Layout

```
sre/
├── frontend/               # Kubernetes manifests for the Next.js app
│   ├── namespace.yaml      # ederbrito namespace (Istio injection enabled)
│   ├── deployment.yaml     # App deployment (image tag set by CI)
│   ├── service.yaml        # ClusterIP service on port 3000
│   └── virtualservice.yaml # Istio routing for ederbrito.com.br
└── common/
    ├── terraform/
    │   ├── k8s/            # OKE cluster, VCN, subnets, node pool
    │   └── dns/            # OCI DNS zone and A records
    └── kubernetes/         # Observability stack + Istio gateway config
        ├── ingressgateway.yaml
        ├── certificate.yaml
        ├── certissuer.yaml
        ├── prometheus.yaml
        ├── grafana.yaml
        ├── jaeger.yaml
        ├── loki.yaml
        └── kiali.yaml
```

## Architecture

### Cluster

- **Provider**: Oracle Cloud Infrastructure (OCI) — Always Free tier
- **Region**: São Paulo (`sa-saopaulo-1`)
- **Engine**: Oracle Kubernetes Engine (OKE), BASIC_CLUSTER type (free control plane)
- **Nodes**: 2× `VM.Standard.A1.Flex` — ARM64, 2 OCPUs, 12GB RAM, 50GB boot volume each

### Networking

| Subnet | CIDR | Type | Purpose |
|--------|------|------|---------|
| API Endpoint | 10.0.1.0/24 | Public | OKE control plane |
| Load Balancer | 10.0.2.0/24 | Public | Istio ingress gateway |
| Worker Nodes | 10.0.3.0/24 | Private | Application workloads |

The worker node subnet has no inbound public route. Outbound internet access goes through a NAT Gateway. A Service Gateway allows private nodes to reach OCI services without public internet.

### Service Mesh

Istio 1.28 handles all ingress, mTLS between services, and exposes observability metrics. An OCI Load Balancer (10Mbps shape, free tier) fronts the Istio ingress gateway.

### TLS

cert-manager 1.19 issues and renews certificates automatically via Let's Encrypt. Certificates are provisioned per-subdomain through the `ClusterIssuer` defined in `common/kubernetes/certissuer.yaml`.

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.12.2 |
| OCI CLI | latest, configured |
| kubectl | >= 1.34.1 |
| Helm | >= 3.0 |

### OCI Account Setup

Before running Terraform you need:
- A **compartment OCID** where resources will be created
- An **Object Storage bucket** for Terraform state (10GB Always Free)
- An **SSH public key** for node access
- An **API key pair** for Terraform authentication

```bash
# 1. Sign up at oracle.com/cloud/free
# 2. Create API key: Identity → Users → Your User → API Keys
# 3. Create compartment: Identity → Compartments
# 4. Create bucket: Object Storage → Buckets → terraform-state
```

## Getting Started

### 1. Configure OCI credentials

```bash
# Option A: OCI CLI
oci setup config

# Option B: environment variables
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..xxxxx"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
```

### 2. Provision the Kubernetes cluster

```bash
cd sre/common/terraform/k8s

terraform init \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="bucket=terraform-state" \
  -backend-config="namespace=<your-namespace>" \
  -backend-config="key=ederbrito/common/oke" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key_path=oci_api_key.pem" \
  -backend-config="region=sa-saopaulo-1"

terraform plan
terraform apply   # ~15-20 minutes
```

### 3. Get kubeconfig

```bash
CLUSTER_OCID=$(terraform output -raw cluster_id)

oci ce cluster create-kubeconfig \
  --cluster-id $CLUSTER_OCID \
  --file ~/.kube/config \
  --region sa-saopaulo-1 \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT

kubectl get nodes
```

### 4. Configure DNS

```bash
cd sre/common/terraform/dns

terraform init \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="bucket=terraform-state" \
  -backend-config="namespace=<your-namespace>" \
  -backend-config="key=ederbrito/common/dns" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key_path=oci_api_key.pem" \
  -backend-config="region=sa-saopaulo-1"

terraform plan
terraform apply
```

> To avoid the DNS zone cost, skip this step and use an external provider — see [Making It 100% Free](#making-it-100-free).

### 5. Install Istio

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm upgrade --install istio-base istio/base \
  -n istio-system --create-namespace --version 1.28.3

helm upgrade --install istiod istio/istiod \
  -n istio-system --wait --version 1.28.3

helm upgrade --install istio-ingressgateway istio/gateway \
  -n istio-system --wait --version 1.28.3 \
  --set "service.annotations.service\.beta\.kubernetes\.io/oci-load-balancer-shape=10Mbps"
```

### 6. Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.19.2 \
  --set crds.enabled=true
```

### 7. Deploy the observability stack

```bash
kubectl apply -f sre/common/kubernetes/
```

### 8. Deploy the frontend

```bash
kubectl apply -f sre/frontend/
```

See [Frontend Deployment](#frontend-deployment) for image pull secret setup and updating the image tag.

### 9. Verify

```bash
kubectl get nodes
kubectl get pods -n istio-system
kubectl get pods -n cert-manager
kubectl get pods -n ederbrito
kubectl get svc -n istio-system istio-ingressgateway   # check for external IP
```

## Observability Stack

All tools are accessible via HTTPS through the Istio ingress gateway.

| Tool | URL | Purpose |
|------|-----|---------|
| Prometheus | `prometheus.ederbrito.com.br` | Metrics collection, alerting rules |
| Grafana | `grafana.ederbrito.com.br` | Dashboards (Kubernetes, Istio, app metrics) |
| Jaeger | `jaeger.ederbrito.com.br` | Distributed tracing (OTLP ingest) |
| Loki | `loki.ederbrito.com.br` | Log aggregation |
| Kiali | `kiali.ederbrito.com.br` | Service mesh topology and traffic flow |

Prometheus discovers application pods via annotations. The frontend pod sets:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "3000"
prometheus.io/path: "/api/metrics"
```

Prometheus also scrapes the Kubernetes API server, nodes, pods, services, and Istio mesh metrics.

> Default credentials for each tool may need to be configured. Check the relevant manifest in `sre/common/kubernetes/`.

## Frontend Deployment

Manifests in `sre/frontend/` deploy the Next.js app into the `ederbrito` namespace.

**Create the image pull secret before applying:**

```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=<user> \
  --docker-password=<token> \
  -n ederbrito
```

**Apply manifests:**

```bash
kubectl apply -f sre/frontend/
```

**Update the image after a new build:**

```bash
kubectl set image deployment/frontend \
  frontend=britoederr/ederbrito.com.br:<tag> \
  -n ederbrito
```

The `virtualservice.yaml` routes all traffic for `ederbrito.com.br` to `frontend.ederbrito.svc.cluster.local:3000` through the `ederbrito-com-br-gateway` defined in `sre/common/kubernetes/ingressgateway.yaml`.

## CI/CD Pipeline

The GitHub Actions workflow automates the full deployment.

**Triggers**:
- Pull requests → Terraform validate
- Push to `main` → deploy infrastructure + app
- Tags (`v*.*.*`) → versioned release

**Required GitHub Secrets**:

| Secret | Description |
|--------|-------------|
| `TF_VAR_TENANCY_OCID` | OCI tenancy OCID |
| `TF_VAR_USER_OCID` | OCI user OCID |
| `TF_VAR_FINGERPRINT` | API key fingerprint |
| `TF_VAR_PRIVATE_KEY` | OCI API private key (base64 encoded) |
| `TF_VAR_OCI_BUCKET_NAME` | Object Storage bucket for Terraform state |
| `TF_VAR_OCI_COMPARTMENT_ID` | OCI compartment OCID |
| `TF_VAR_SSH_PUBLIC_KEY` | SSH public key for node access |

The pipeline builds the Docker image, pushes to `britoederr/ederbrito.com.br` on Docker Hub, then deploys via `kubectl set image`.

## Configuration Reference

### Kubernetes module (`sre/common/terraform/k8s/`)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `compartment_ocid` | Yes | — | OCI compartment OCID |
| `ssh_public_key` | Yes | — | SSH public key for node access |
| `project_name` | Yes | — | Resource name prefix |
| `kubernetes_version` | No | `v1.34.1` | Kubernetes version |
| `region` | Yes | — | OCI region |

### DNS module (`sre/common/terraform/dns/`)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `compartment_ocid` | Yes | — | OCI compartment OCID |
| `domain_name` | Yes | — | Domain name |
| `dns_ttl` | No | `300` | DNS TTL in seconds |
| `region` | Yes | — | OCI region |

### Terraform state keys

| Module | State key |
|--------|-----------|
| Kubernetes | `ederbrito/common/oke` |
| DNS | `ederbrito/common/dns` |

The Object Storage bucket must exist before `terraform init`. Create it via OCI Console or CLI.

## Making It 100% Free

OCI DNS costs ~$0.50/month. To eliminate that, use an external DNS provider (Cloudflare free tier, Registro.br, etc.):

1. Get the load balancer IP after installing Istio:
   ```bash
   kubectl get svc -n istio-system istio-ingressgateway \
     -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```
2. Create an A record for `ederbrito.com.br` (and any subdomains) pointing to that IP in your DNS provider
3. Skip the `sre/common/terraform/dns` module entirely

## Cost Breakdown

| Resource | Always Free | Cost |
|----------|-------------|------|
| VM.Standard.A1.Flex × 2 | Yes | $0 |
| VCN, Subnets, Internet Gateway | Yes | $0 |
| NAT Gateway | Yes | $0 |
| Service Gateway | Yes | $0 |
| OKE BASIC_CLUSTER (control plane) | Yes | $0 |
| Object Storage (10GB) | Yes | $0 |
| OCI Load Balancer | Yes | $0 |
| OCI DNS Zone | No | ~$0.50/month |
| Data Transfer (first 10TB/month) | Yes | $0 |
| **Total with OCI DNS** | | **~$0.50/month** |
| **Total with external DNS** | | **$0/month** |

## Cleanup

Destroy in order to avoid orphaned resources:

```bash
# 1. DNS
cd sre/common/terraform/dns && terraform destroy

# 2. Kubernetes workloads
kubectl delete -f sre/frontend/
kubectl delete -f sre/common/kubernetes/

# 3. Cluster and networking
cd sre/common/terraform/k8s && terraform destroy
```

> **Warning**: `terraform destroy` permanently deletes all provisioned resources. Back up any stateful data first.

## Troubleshooting

**Terraform init fails**
```bash
oci iam region list   # verify CLI is configured
oci os bucket get --bucket-name terraform-state --namespace <namespace>
```

**`kubectl` cannot reach the cluster**
```bash
oci ce cluster create-kubeconfig \
  --cluster-id <ocid> --file ~/.kube/config \
  --region sa-saopaulo-1 --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT
```

**Istio ingress gateway stuck in `<pending>`**
- OCI load balancer provisioning takes 3-5 minutes
- Check security list rules allow ports 80 and 443 on the load balancer subnet
- Verify the load balancer subnet has a route to the Internet Gateway

**DNS not resolving**
- Confirm the A record points to the correct load balancer IP
- Wait for TTL expiry (default: 300s)
- Re-run `terraform apply` in the DNS module if using OCI DNS

**cert-manager not issuing certificates**
- DNS must be propagated before ACME HTTP-01 or DNS-01 challenges can complete
- Check logs: `kubectl logs -n cert-manager -l app=cert-manager`
- Check `CertificateRequest` and `Order` resources for error messages

**Node shows `NotReady`**
```bash
kubectl describe node <name>
```
Verify security list rules allow communication between the worker node subnet and the API endpoint subnet, and that NAT Gateway routing is correct.

**Frontend pod not starting**
```bash
kubectl describe pod -n ederbrito -l app=frontend
```
Most common cause: missing `dockerhub-secret` in the `ederbrito` namespace. See [Frontend Deployment](#frontend-deployment).

## Important Notes

- **ARM architecture**: All nodes are ARM64 (`aarch64`). Container images must be built for `linux/arm64` or provide a multi-arch manifest.
- **Idle reclamation**: Oracle may reclaim Always Free instances that are idle for extended periods. Keep workloads running or schedule periodic activity.
- **Not for production**: Single region, single AZ, no automated failover or backups. Suitable for personal projects and learning environments.
- **Load balancer shape**: 10Mbps is used to stay within free tier limits. Upgrade the shape annotation if you need more throughput (this will incur cost).
- **Trial period**: The 30-day $300 trial credit expires. Switch to Pay-As-You-Go before it does — Always Free resources remain free indefinitely on PAYG accounts.
