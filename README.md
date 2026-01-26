# ederbrito.com.br

**A complete guide and template for deploying a free Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using Always Free tier resources.**

This repository serves as both a personal portfolio and a comprehensive entrypoint for deploying an entirely free Kubernetes cluster on OCI. The project demonstrates modern DevOps and SRE practices with Infrastructure as Code (IaC), container orchestration, and comprehensive observability, all optimized for OCI's Always Free tier.

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
  - Kubernetes Version: v1.33.1
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

- **Istio Service Mesh**: For traffic management, security, and observability
- **Ingress**: Istio Gateway with TLS termination

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

- **Terraform** >= 1.1
- **OCI CLI** configured with appropriate credentials
- **kubectl** configured to access the OKE cluster
- **OCI Free Tier Account** with:
  - Compartment OCID
  - Object Storage bucket for Terraform state (Always Free tier includes 10GB)
  - DNS zone (optional - can use external DNS provider)
  - SSH public key for node access

> **Note**: Sign up for OCI Free Tier at [oracle.com/cloud/free](https://www.oracle.com/cloud/free/) to get started with Always Free resources and $300 trial credit.

## 🚀 Getting Started

This guide will help you deploy your own free Kubernetes cluster on OCI. You can use this as a template and customize it for your needs.

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

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

This will create:
- VCN with subnets and gateways
- OKE cluster
- Node pool with worker nodes
- Security lists and route tables

### 3. Configure DNS

```bash
cd sre/common/terraform/dns

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

This will create DNS records pointing to the Istio ingress gateway.

### 4. Deploy Observability Stack

```bash
# Apply Kubernetes manifests
kubectl apply -f sre/common/kubernetes/
```

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
- `kubernetes_version` (optional): Kubernetes version to be deployed (default v1.34.1)
- `region` (required): Region to deploy the resources

#### DNS Module (`sre/common/terraform/dns/`)

- `compartment_ocid` (required): OCI compartment OCID
- `domain_name` (required): Domain name
- `dns_ttl` (optional): DNS TTL in seconds (default: 300)
- `region` (required): Region to get the resources

### Terraform Backend

Terraform state is stored in OCI Object Storage:
- Bucket: `your-bucket`
- Namespace: `your-namespace`
- Keys:
  - `your-oke-key` (Kubernetes infrastructure)
  - `your-dns-key` (DNS configuration)

## 📊 Monitoring & Observability

### Accessing Monitoring Tools

All monitoring tools are accessible via HTTPS through the Istio ingress gateway:

- **Prometheus**: https://prometheus.ederbrito.com.br
- **Grafana**: https://grafana.ederbrito.com.br
- **Jaeger**: https://jaeger.ederbrito.com.br
- **Loki**: https://loki.ederbrito.com.br
- **Kiali**: https://kiali.ederbrito.com.br

### Metrics Collection

Prometheus is configured to automatically discover and scrape:
- Kubernetes API server
- Kubernetes nodes
- Kubernetes pods and services
- Istio service mesh metrics

## 🔒 Security

- Worker nodes run in private subnets with NAT Gateway for outbound internet access
- API endpoint is publicly accessible but secured with Kubernetes RBAC
- TLS termination at the Istio ingress gateway
- TLS automatically rotated by cert-manager
- Security lists configured to restrict traffic appropriately

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

| Resource | Always Free | Estimated Cost |
|----------|-------------|----------------|
| VM.Standard.A1.Flex (2 nodes) | ✅ Yes | $0 |
| VCN, Subnets, Internet Gateway | ✅ Yes | $0 |
| NAT Gateway | ✅ Yes | $0 |
| Service Gateway | ✅ Yes | $0 |
| OKE BASIC_CLUSTER | ✅ Yes | $0 |
| Object Storage (10GB) | ✅ Yes | $0 |
| Load Balancer | ✅ Yes | $0 |
| **DNS Zone** | ❌ No | ~$0.50/month + queries |
| **Total** | | **~$0.50/month** (or **$0** with external DNS) |

> **For 100% Free Setup**: 
> - Use external DNS provider (Cloudflare, etc.) instead of OCI DNS to eliminate DNS costs
> - **Result**: **$0/month** with 100% Always Free resources!

## 🎯 Use Cases

This template is perfect for:

- **Learning Kubernetes**: Hands-on experience with a real cluster
- **Personal Projects**: Portfolio websites, side projects, experiments
- **Development/Testing**: Non-production workloads
- **Educational Purposes**: Teaching and demonstrating cloud infrastructure
- **Proof of Concepts**: Validating ideas before production deployment

## ⚠️ Important Notes

- **Idle Instance Reclamation**: Oracle may reclaim idle Always Free instances. Keep your cluster active with periodic workloads.
- **Not for Production**: This setup is optimized for cost, not production-grade security or high availability.
- **Resource Limits**: Always Free tier has resource limits. Monitor your usage in the OCI console.
- **Trial Period**: After the 30-day trial, switch to Pay-As-You-Go to continue using Always Free services.

## 🙏 Acknowledgments

- Oracle Cloud Infrastructure for the generous free tier resources
- The open-source community for the amazing observability tools
- Projects like [free-oke](https://github.com/taha-cmd/free-oke) and [K3S-OCI](https://github.com/AdmiraalA/K3S-OCI) for inspiration

---

**Note**: This project serves as both a personal portfolio infrastructure and a comprehensive guide for deploying free Kubernetes clusters on OCI. The infrastructure is optimized for cost-effectiveness while maintaining production-ready patterns. Use this as a template to deploy your own free Kubernetes cluster!
