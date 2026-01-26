# ederbrito.com.br

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/terraform-1.12+-blue.svg)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-1.33+-blue.svg)](https://kubernetes.io/)
[![OCI](https://img.shields.io/badge/OCI-Always%20Free-orange.svg)](https://www.oracle.com/cloud/free/)

**A complete guide and template for deploying a free Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using Always Free tier resources.**

This repository serves as both a personal portfolio and a comprehensive entrypoint for deploying an entirely free Kubernetes cluster on OCI. The project demonstrates modern DevOps and SRE practices with Infrastructure as Code (IaC), container orchestration, and comprehensive observability, all optimized for OCI's Always Free tier.

## 📋 Table of Contents

- [🆓 Free Tier Optimization](#-free-tier-optimization)
- [🏗️ Architecture](#️-architecture)
- [📁 Project Structure](#-project-structure)
- [🛠️ Prerequisites](#️-prerequisites)
- [🚀 Getting Started](#-getting-started)
- [🔄 CI/CD Pipeline](#-cicd-pipeline)
- [💸 Making It 100% Free](#-making-it-100-free)
- [🔧 Configuration](#-configuration)
- [📊 Monitoring & Observability](#-monitoring--observability)
- [🔒 Security](#-security)
- [🧹 Cleanup](#-cleanup)
- [❓ Troubleshooting](#-troubleshooting)
- [💰 Cost Breakdown](#-cost-breakdown)
- [🎯 Use Cases](#-use-cases)
- [⚠️ Important Notes](#️-important-notes)
- [📝 License](#-license)
- [👤 Author](#-author)
- [🤝 Contributing](#-contributing)

## 🆓Free Tier Optimization

This infrastructure is specifically designed to maximize the use of **OCI Always Free tier resources** while providing production-ready capabilities.

### ✅ Confirmed Always Free Resources

- **Compute**: `VM.Standard.A1.Flex` (ARM-based) - 2 OCPUs, 12GB RAM per node (2 nodes)
  - ✅ Always Free tier includes up to **4 OCPUs and 24GB RAM total**
  - ✅ Boot volumes: 50GB per node (within 200GB Always Free limit)
- **Networking Core**: VCN, Subnets, Internet Gateway, Route Tables, Security Lists
  - ✅ All core networking components are free (no hourly charges)
- **NAT Gateway**: ✅ Free for Always Free tier usage
  - Used for private node outbound internet access
  - No additional charges when used within Always Free tier limits
- **Service Gateway**: ✅ Free for Always Free tier usage
  - Allows private nodes to access OCI services without public internet
- **Container Engine**: OKE BASIC_CLUSTER
  - ✅ BASIC_CLUSTER type avoids enhanced cluster costs
  - ✅ Control plane is free for Always Free tier
- **Load Balancer**: ✅ Free for Always Free tier usage
  - Used by Istio Gateway for ingress
  - OCI Load Balancers are included in Always Free tier resources
- **Storage**: Object Storage for Terraform state
  - ✅ Always Free tier includes 10GB Object Storage

### ⚠️ Resources That Incur Costs

The following resources are used for production-grade functionality and **will incur charges**:

- **DNS Zone**: ~$0.50/month per zone + query costs
  - OCI DNS zone management for your domain
  - First 1 million queries/month are typically free, then ~$0.40 per million queries
  - **Alternative**: Use external DNS provider (Registro.br, etc.) for free
- **Data Transfer**: Outbound data transfer may have costs (first 10TB/month often free)

### 💡 Configuration Philosophy

This setup prioritizes:
1. **Security**: Private worker nodes with NAT Gateway
2. **Production-readiness**: Load balancers and proper networking
3. **Observability**: Full monitoring stack with Grafana, Jaeger, Loki, and Prometheus
4. **Service Mesh**: Full implementation of the Istio Service Mesh
5. **TLS Automation**: Full implementation of cert-manager
6. **Cost-awareness**: Uses ARM instances, BASIC_CLUSTER, and free networking to minimize costs

**Current Estimated Cost**: ~$0.50/month (DNS zone only, if using OCI DNS)

> **Note**: If you use an external DNS provider like CloudFlare(free), the total cost is **$0/month** - completely free!

For a **100% free** setup ($0/month), see the [Making It 100% Free](#-making-it-100-free) section below.

## 🏗️ Architecture

### Infrastructure

- **Cloud Provider**: Oracle Cloud Infrastructure (OCI)
- **Region**: São Paulo (sa-saopaulo-1)
- **Container Orchestration**: Oracle Kubernetes Engine (OKE)
  - Kubernetes Version: v1.34.1 (configurable via `kubernetes_version` variable)
  - Cluster Type: BASIC_CLUSTER
  - CNI: OCI VCN IP Native
  - Node Pool: VM.Standard.A1.Flex (2 OCPUs, 12GB RAM, 2 nodes)

### Networking

- **VCN**: 10.0.0.0/16
- **Subnets**:
  - API Endpoint: 10.0.1.0/24 (public)
  - Load Balancer: 10.0.2.0/24 (public)
  - Worker Nodes: 10.0.3.0/24 (private with NAT Gateway)
- **Gateways**: Internet Gateway, NAT Gateway, Service Gateway

### Service Mesh & Ingress

- **Istio Service Mesh** (v1.28.3): For traffic management, security, and observability
  - **Istiod**: Control plane for service mesh
  - **Istio Ingress Gateway**: Entry point for external traffic
  - **Load Balancer**: OCI Load Balancer (10Mbps shape) for ingress gateway
- **cert-manager** (v1.19.2): Automatic TLS certificate management
  - Issues and renews TLS certificates automatically
  - Integrates with Let's Encrypt or other certificate authorities

### Observability Stack

The infrastructure includes a comprehensive monitoring and observability stack:

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Jaeger**: Distributed tracing
- **Loki**: Log aggregation
- **Kiali**: Service mesh observability

All observability tools are accessible via subdomains:
- `prometheus.ederbrito.com.br`
- `grafana.ederbrito.com.br`
- `jaeger.ederbrito.com.br`
- `loki.ederbrito.com.br`
- `kiali.ederbrito.com.br`

### DNS Management

DNS records are managed via OCI DNS and automatically configured to point to the Istio ingress gateway load balancer IP.

## 📁 Project Structure

```
ederbrito.com.br/
├── sre/
│   └── common/
│       ├── terraform/
│       │   ├── dns/          # DNS configuration
│       │   │   ├── dns.tf
│       │   │   ├── data.tf
│       │   │   ├── providers.tf
│       │   │   ├── variables.tf
│       │   │   └── locals.tf
│       │   └── k8s/          # Kubernetes infrastructure
│       │       ├── oracle-kubernetes-engine.tf
│       │       ├── networking.tf
│       │       ├── data.tf
│       │       ├── providers.tf
│       │       ├── variables.tf
│       │       ├── locals.tf
│       │       └── outputs.tf
│       └── kubernetes/        # Kubernetes manifests
│           ├── grafana.yaml
│           ├── prometheus.yaml
│           ├── jaeger.yaml
│           ├── loki.yaml
│           └── kiali.yaml
├── LICENSE
└── README.md
```

## 🛠️ Prerequisites

### Required Tools

- **Terraform** >= 1.12.2 (tested with 1.12.2)
- **OCI CLI** configured with appropriate credentials
- **kubectl** >= 1.34.1 (matching cluster version)
- **Helm** >= 3.0 (for installing Istio and cert-manager)

### OCI Account Setup

You'll need an **OCI Free Tier Account** with:

- ✅ **Compartment OCID**: OCI compartment where resources will be created
- ✅ **Object Storage Bucket**: For Terraform state storage (Always Free tier includes 10GB)
- ✅ **SSH Public Key**: For node access (generate with `ssh-keygen -t rsa -b 4096`)
- ✅ **API Key**: OCI API key pair for Terraform authentication
- ⚠️ **DNS Zone** (optional): OCI DNS zone, or use external DNS provider (Cloudflare, etc.)

### Getting OCI Credentials

1. **Sign up**: Create account at [oracle.com/cloud/free](https://www.oracle.com/cloud/free/)
2. **Create API Key**: 
   - Navigate to Identity → Users → Your User → API Keys
   - Click "Add API Key" and upload your public key or generate a key pair
   - Save the configuration values (fingerprint, private key, etc.)
3. **Create Compartment**: 
   - Navigate to Identity → Compartments
   - Create a new compartment and note the OCID
4. **Create Object Storage Bucket**:
   - Navigate to Object Storage → Buckets
   - Create a bucket for Terraform state (e.g., `terraform-state`)
   - Note your Object Storage namespace

> **Note**: The OCI Free Tier includes Always Free resources and $300 trial credit for 30 days.

## 🚀 Getting Started

This guide will help you deploy your own free Kubernetes cluster on OCI. You can use this as a template and customize it for your needs.

### Quick Start (Automated)

If you're using GitHub Actions for CI/CD, simply:
1. Fork this repository
2. Configure GitHub Secrets (see [CI/CD Pipeline](#-cicd-pipeline) section)
3. Push changes to trigger the workflow

### Manual Deployment

Follow these steps for manual deployment:

### 1. Configure OCI Credentials

Set up your OCI credentials using one of the following methods:

```bash
# Option 1: OCI CLI configuration
oci setup config

# Option 2: Environment variables
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..xxxxx"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
```

### 2. Deploy Kubernetes Infrastructure

```bash
cd sre/common/terraform/k8s

# Initialize Terraform with backend configuration
terraform init \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="bucket=terraform-state" \
  -backend-config="namespace=<your-namespace>" \
  -backend-config="key=ederbrito/common/oke" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key_path=oci_api_key.pem" \
  -backend-config="region=sa-saopaulo-1"

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

This will create:
- ✅ VCN with subnets and gateways
- ✅ OKE cluster (BASIC_CLUSTER type)
- ✅ Node pool with worker nodes (2x VM.Standard.A1.Flex)
- ✅ Security lists and route tables
- ✅ NAT Gateway and Service Gateway

**Expected Duration**: ~15-20 minutes for cluster provisioning

### 3. Get Kubeconfig

After the cluster is created, generate kubeconfig to access the cluster:

```bash
# Get cluster OCID from Terraform output
cd sre/common/terraform/k8s
CLUSTER_OCID=$(terraform output -raw cluster_id)

# Generate kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id $CLUSTER_OCID \
  --file ~/.kube/config \
  --region sa-saopaulo-1 \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT

# Verify cluster access
kubectl get nodes
```

### 4. Configure DNS

```bash
cd sre/common/terraform/dns

# Initialize Terraform with backend configuration
terraform init \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="bucket=terraform-state" \
  -backend-config="namespace=<your-namespace>" \
  -backend-config="key=ederbrito/common/dns" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key_path=oci_api_key.pem" \
  -backend-config="region=sa-saopaulo-1"

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

This will create DNS records pointing to the Istio ingress gateway.

> **Alternative**: If using external DNS (Cloudflare, etc.), skip this step and manually create A records pointing to the load balancer IP after step 5.

### 5. Install Istio Service Mesh

```bash
# Add Istio Helm repository
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Install Istio base components
helm upgrade --install istio-base istio/base \
  -n istio-system \
  --create-namespace \
  --version 1.28.3

# Install Istio control plane (istiod)
helm upgrade --install istiod istio/istiod \
  -n istio-system \
  --wait \
  --version 1.28.3

# Install Istio ingress gateway
helm upgrade --install istio-ingressgateway istio/gateway \
  -n istio-system \
  --wait \
  --version 1.28.3 \
  --set "service.annotations.service\.beta\.kubernetes\.io/oci-load-balancer-shape=10Mbps"
```

### 6. Install cert-manager

```bash
# Add cert-manager Helm repository
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

# Install cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.19.2 \
  --set crds.enabled=true
```

### 7. Deploy Observability Stack

```bash
# Apply Kubernetes manifests
kubectl apply -f sre/common/kubernetes/

# Verify deployments
kubectl get pods -n default
kubectl get pods -n istio-system
```

> **Note**: The observability stack includes Prometheus, Grafana, Jaeger, Loki, and Kiali. Make sure Istio is installed first as some components depend on Istio metrics.

### 8. Verify Deployment

Check that all components are running:

```bash
# Check cluster nodes
kubectl get nodes

# Check Istio components
kubectl get pods -n istio-system

# Check cert-manager
kubectl get pods -n cert-manager

# Check observability stack
kubectl get pods

# Get load balancer IP for Istio ingress
kubectl get svc -n istio-system istio-ingressgateway
```

Once the load balancer has an external IP, your services should be accessible via the configured domain names!

## 🔄 CI/CD Pipeline

This project includes a GitHub Actions workflow (`.github/workflows/terraform-oke.yml`) that automates the entire deployment process:

### Automated Deployment Flow

1. **Terraform Validation**: Validates Terraform configuration on pull requests
2. **Infrastructure Deployment**: 
   - Creates Kubernetes cluster infrastructure
   - Installs Istio service mesh
   - Installs cert-manager for TLS automation
   - Deploys observability stack
3. **DNS Configuration**: Automatically configures DNS records

### Workflow Triggers

- **Pull Requests**: Validates Terraform configuration
- **Push to main**: Deploys infrastructure changes
- **Tags (v*.*.*)**: Triggers deployment for versioned releases

### Required GitHub Secrets

Configure the following secrets in your GitHub repository:

- `TF_VAR_TENANCY_OCID`: OCI tenancy OCID
- `TF_VAR_USER_OCID`: OCI user OCID
- `TF_VAR_FINGERPRINT`: API key fingerprint
- `TF_VAR_PRIVATE_KEY`: OCI API private key (base64 encoded)
- `TF_VAR_OCI_BUCKET_NAME`: Object Storage bucket name for Terraform state
- `TF_VAR_OCI_COMPARTMENT_ID`: OCI compartment OCID
- `TF_VAR_SSH_PUBLIC_KEY`: SSH public key for node access

### Manual Deployment

If you prefer manual deployment, follow the [Getting Started](#-getting-started) section above.

## 💸 Making It 100% Free

To achieve a **completely free** setup ($0/month), simply use an external DNS provider:

### Use External DNS Provider (Eliminate DNS Costs)

Instead of OCI DNS, use a free external DNS provider:
- **Cloudflare**: Free DNS with excellent performance and DDoS protection
- **Other providers**: Many offer free DNS services

**Steps:**
1. Get the Load Balancer IP from your Istio ingress gateway:
   ```bash
   kubectl get svc -n istio-system istio-ingressgateway
   ```
2. Create A records in your external DNS provider pointing to this IP
3. Optionally remove or skip the OCI DNS Terraform configuration

**Trade-off**: None - external DNS is often better, faster, and free!

### Complete Free Setup Summary

With external DNS, your setup is **100% free**:
- ✅ Compute (ARM instances) - **Free**
- ✅ Networking (VCN, NAT Gateway, Service Gateway) - **Free**
- ✅ Load Balancer - **Free**
- ✅ OKE Cluster - **Free**
- ✅ Object Storage - **Free**
- ✅ External DNS (Cloudflare, etc.) - **Free**

**Result**: **$0/month** with 100% Always Free resources while maintaining production-ready architecture and security best practices!

## 🔧 Configuration

### Terraform Variables

#### Kubernetes Module (`sre/common/terraform/k8s/`)

- `compartment_ocid` (required): OCI compartment OCID
- `ssh_public_key` (required): SSH public key for node access
- `project_name` (required): Project name prefix
- `kubernetes_version` (optional): Kubernetes version to be deployed (default: v1.34.1)
- `region` (required): Region to deploy the resources

#### DNS Module (`sre/common/terraform/dns/`)

- `compartment_ocid` (required): OCI compartment OCID
- `domain_name` (required): Domain name
- `dns_ttl` (optional): DNS TTL in seconds (default: 300)
- `region` (required): Region to get the resources

### Terraform Backend

Terraform state is stored in OCI Object Storage using remote state backend:

**Backend Configuration** (configured in `backend-config`):
- **Bucket**: `terraform-state` (or your custom bucket name)
- **Namespace**: Your OCI Object Storage namespace
- **State Keys**:
  - `ederbrito/common/oke` (Kubernetes infrastructure)
  - `ederbrito/common/dns` (DNS configuration)

**Backend Setup Example**:

```bash
terraform init \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="bucket=terraform-state" \
  -backend-config="namespace=<your-namespace>" \
  -backend-config="key=ederbrito/common/oke" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key_path=oci_api_key.pem" \
  -backend-config="region=sa-saopaulo-1"
```

> **Note**: The bucket must exist before running `terraform init`. Create it via OCI Console or CLI if it doesn't exist.

## 📊 Monitoring & Observability

### Accessing Monitoring Tools

All monitoring tools are accessible via HTTPS through the Istio ingress gateway:

- **Prometheus**: https://prometheus.ederbrito.com.br
  - Metrics collection and querying
  - Alerting rules configuration
- **Grafana**: https://grafana.ederbrito.com.br
  - Pre-configured dashboards for Kubernetes and Istio
  - Data source integration with Prometheus and Loki
- **Jaeger**: https://jaeger.ederbrito.com.br
  - Distributed tracing for microservices
  - Request flow visualization
- **Loki**: https://loki.ederbrito.com.br
  - Log aggregation and querying
  - Integration with Grafana for log visualization
- **Kiali**: https://kiali.ederbrito.com.br
  - Service mesh observability
  - Traffic flow visualization and metrics

> **Note**: Default credentials may need to be configured. Check the Kubernetes manifests for authentication setup.

### Metrics Collection

Prometheus is configured to automatically discover and scrape:
- Kubernetes API server
- Kubernetes nodes
- Kubernetes pods and services
- Istio service mesh metrics

## 🔒 Security

### Network Security

- **Private Worker Nodes**: Worker nodes run in private subnets with no direct internet access
- **NAT Gateway**: Provides outbound internet access for worker nodes without exposing them
- **Service Gateway**: Allows private nodes to access OCI services without public internet
- **Security Lists**: Configured to restrict traffic appropriately
  - API endpoint subnet: Allows HTTPS (443) from internet
  - Load balancer subnet: Allows HTTP (80) and HTTPS (443) from internet
  - Worker node subnet: Restricts inbound traffic, allows outbound via NAT Gateway

### Kubernetes Security

- **RBAC**: Kubernetes Role-Based Access Control enabled
- **API Endpoint**: Publicly accessible but secured with Kubernetes authentication
- **Network Policies**: Can be configured for pod-to-pod communication restrictions

### Application Security

- **TLS Termination**: All external traffic terminates TLS at the Istio ingress gateway
- **Automatic Certificate Management**: cert-manager automatically issues and renews TLS certificates
- **Service Mesh Security**: Istio provides mTLS between services within the mesh
- **Secrets Management**: Kubernetes secrets used for sensitive configuration

### Best Practices

- Regularly update Kubernetes and Istio versions
- Monitor security advisories for OCI and Kubernetes
- Use least-privilege access principles
- Enable audit logging for production workloads
- Regularly rotate API keys and certificates

## 🧹 Cleanup

To destroy the infrastructure:

```bash
# Remove DNS records
cd sre/common/terraform/dns
terraform destroy

# Remove Kubernetes infrastructure
cd sre/common/terraform/k8s
terraform destroy
```

> **Warning**: This will permanently delete all resources. Make sure you have backups of any important data.

### Cleanup Order

It's important to destroy resources in the correct order:

1. **DNS records** (dns module) - Remove DNS configuration first
2. **Kubernetes resources** - Remove any deployed applications
3. **Kubernetes infrastructure** (k8s module) - Remove cluster and networking last

This order prevents orphaned resources and ensures clean teardown.

## ❓ Troubleshooting

### Common Issues

#### 1. Terraform Backend Configuration

**Issue**: Terraform fails to initialize backend.

**Solution**: Ensure your OCI credentials are properly configured and the Object Storage bucket exists:

```bash
# Verify OCI CLI configuration
oci iam region list

# Check bucket access
oci os bucket get --bucket-name terraform-state --namespace <your-namespace>
```

#### 2. Kubernetes Cluster Not Accessible

**Issue**: Cannot connect to the cluster with `kubectl`.

**Solution**: Generate a new kubeconfig:

```bash
oci ce cluster create-kubeconfig \
  --cluster-id <cluster-ocid> \
  --file ~/.kube/config \
  --region sa-saopaulo-1 \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT
```

#### 3. Load Balancer Not Getting IP

**Issue**: Istio ingress gateway service shows `<pending>` for external IP.

**Solution**: 
- Wait a few minutes for OCI to provision the load balancer
- Check security lists allow traffic on ports 80 and 443
- Verify the load balancer subnet has proper route table configuration

#### 4. DNS Records Not Updating

**Issue**: DNS records don't point to the correct load balancer IP.

**Solution**: 
- Get the current load balancer IP: `kubectl get svc -n istio-system istio-ingressgateway`
- Update DNS records manually or re-run Terraform DNS module
- Wait for DNS propagation (TTL dependent, typically 5 minutes)

#### 5. Cert-manager Not Issuing Certificates

**Issue**: TLS certificates are not being issued automatically.

**Solution**:
- Verify cert-manager is running: `kubectl get pods -n cert-manager`
- Check ClusterIssuer configuration
- Review cert-manager logs: `kubectl logs -n cert-manager -l app=cert-manager`
- Ensure DNS records are properly configured and propagated

#### 6. Worker Nodes Not Joining Cluster

**Issue**: Nodes show as `NotReady` in `kubectl get nodes`.

**Solution**:
- Check node logs: `kubectl describe node <node-name>`
- Verify security lists allow communication between nodes and control plane
- Ensure NAT Gateway is properly configured for outbound internet access
- Check if nodes can reach container registry and required endpoints

### Getting Help

- Check [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- Review [Terraform OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- Open an [issue](https://github.com/ederbrito/ederbrito.com.br/issues) on GitHub

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Éder Brito**

- Portfolio: https://ederbrito.com.br
- GitHub: [@ederbrito](https://github.com/ederbrito)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free open a Pull Request!

## 💰 Cost Breakdown

### Estimated Monthly Costs (Always Free + Minimal Charges)

| Resource | Always Free | Estimated Cost | Notes |
|----------|-------------|----------------|-------|
| VM.Standard.A1.Flex (2 nodes) | ✅ Yes | **$0** | 2 OCPUs, 12GB RAM per node (within 4 OCPUs, 24GB limit) |
| VCN, Subnets, Internet Gateway | ✅ Yes | **$0** | Core networking components are free |
| NAT Gateway | ✅ Yes | **$0** | Free for Always Free tier usage |
| Service Gateway | ✅ Yes | **$0** | Free for Always Free tier usage |
| OKE BASIC_CLUSTER | ✅ Yes | **$0** | Control plane free for Always Free tier |
| Object Storage (10GB) | ✅ Yes | **$0** | Within 10GB Always Free limit |
| Load Balancer | ✅ Yes | **$0** | Included in Always Free tier |
| **DNS Zone** | ❌ No | **~$0.50/month** | + query costs (first 1M queries/month often free) |
| **Data Transfer** | ⚠️ Partial | **$0** | First 10TB/month often free |
| | | | |
| **Total (with OCI DNS)** | | **~$0.50/month** | DNS zone cost only |
| **Total (with External DNS)** | | **$0/month** | 100% free setup |

> **For 100% Free Setup**: 
> - Use external DNS provider (Cloudflare, etc.) instead of OCI DNS to eliminate DNS costs
> - **Result**: **$0/month** with 100% Always Free resources!

## 🎯 Use Cases

This template is perfect for:

- **Learning Kubernetes**: Hands-on experience with a real production-like cluster
- **Personal Projects**: Portfolio websites, side projects, experiments
- **Development/Testing**: Non-production workloads and staging environments
- **Educational Purposes**: Teaching and demonstrating cloud infrastructure, DevOps, and SRE practices
- **Proof of Concepts**: Validating ideas before production deployment
- **Service Mesh Learning**: Understanding Istio service mesh capabilities
- **Observability Practice**: Learning monitoring, logging, and tracing with modern tools
- **Cost-Effective Hosting**: Running small applications with minimal infrastructure costs

### What You'll Learn

By using this template, you'll gain hands-on experience with:

- Infrastructure as Code (Terraform)
- Kubernetes cluster management
- Service mesh implementation (Istio)
- Observability stack (Prometheus, Grafana, Jaeger, Loki)
- CI/CD pipelines (GitHub Actions)
- Cloud networking and security
- TLS certificate automation
- OCI Always Free tier optimization

## ⚠️ Important Notes

### Always Free Tier Considerations

- **Idle Instance Reclamation**: Oracle may reclaim idle Always Free instances. Keep your cluster active with periodic workloads or scheduled jobs.
- **Resource Limits**: Always Free tier has resource limits. Monitor your usage in the OCI console to avoid unexpected charges.
- **Trial Period**: After the 30-day trial period, switch to Pay-As-You-Go to continue using Always Free services. Always Free resources remain free even after the trial.
- **Availability**: Always Free resources are subject to availability in your region. Some regions may have limited capacity.

### Production Readiness

- **Not for Production**: This setup is optimized for cost, not production-grade security or high availability.
- **Single Region**: Infrastructure is deployed in a single region (São Paulo). For production, consider multi-region deployments.
- **Backup Strategy**: Implement backup strategies for critical data. This template doesn't include automated backups.
- **Monitoring**: While observability tools are included, set up proper alerting for production workloads.
- **Security Hardening**: Review and enhance security configurations for production use (network policies, pod security policies, etc.).

### Performance Considerations

- **ARM Architecture**: Uses ARM-based instances (VM.Standard.A1.Flex). Ensure your applications are compatible with ARM64 architecture.
- **Load Balancer Shape**: Uses 10Mbps load balancer shape. Upgrade for higher traffic requirements.
- **Node Resources**: 2 nodes with 2 OCPUs and 12GB RAM each. Monitor resource usage and scale if needed.

### Maintenance

- **Updates**: Regularly update Kubernetes, Istio, and other components for security patches.
- **State Management**: Terraform state is stored in OCI Object Storage. Ensure proper backup and access controls.
- **Cost Monitoring**: Regularly check OCI cost analysis to ensure you're within Always Free tier limits.

---

## 📚 Additional Resources

- [Oracle Cloud Infrastructure Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Oracle Kubernetes Engine Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [Terraform OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Istio Documentation](https://istio.io/latest/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## 🙏 Acknowledgments

- Oracle Cloud Infrastructure for providing Always Free tier resources
- The open-source community for excellent tools like Terraform, Kubernetes, Istio, and the observability stack

---

**Note**: This project serves as both a personal portfolio infrastructure and a comprehensive guide for deploying free Kubernetes clusters on OCI. The infrastructure is optimized for cost-effectiveness while maintaining production-ready patterns. Use this as a template to deploy your own free Kubernetes cluster!

**⭐ If you find this project helpful, please consider giving it a star!**
