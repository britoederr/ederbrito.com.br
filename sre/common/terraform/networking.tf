# -------------------------------
# Networking
# -------------------------------

# Create the Virtual Cloud Network (VCN) for the OKE cluster
resource "oci_core_vcn" "oke_vcn" {
  cidr_block     = "10.0.0.0/16"
  display_name   = "oke-ederbrito-k8s-vcn"
  compartment_id = var.compartment_ocid
}

# Public Internet Gateway for external access to resources in public subnets
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-ederbrito-k8s-igw"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

# Route Table for public subnets — directs traffic to the Internet Gateway
resource "oci_core_route_table" "oke_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id

  route_rules {
    network_entity_id = oci_core_internet_gateway.oke_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# Public subnet for OKE API endpoint (control plane access)
resource "oci_core_subnet" "api_endpoint_subnet" {
  cidr_block        = "10.0.1.0/24"
  display_name      = "oke-ederbrito-api-endpoint-subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.oke_vcn.id
  route_table_id    = oci_core_route_table.oke_rt.id
  prohibit_public_ip_on_vnic = false
  security_list_ids          = [oci_core_security_list.api_endpoint_sl.id]
}

# Public subnet for Load Balancers (exposing services to the internet)
resource "oci_core_subnet" "lb_subnet" {
  cidr_block        = "10.0.2.0/24"
  display_name      = "oke-ederbrito-lb-subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.oke_vcn.id
  route_table_id    = oci_core_route_table.oke_rt.id
  prohibit_public_ip_on_vnic = false
}

# -------------------------------
# NAT Gateway for Private Nodes
# -------------------------------

# NAT Gateway — allows private nodes to access the internet without public IPs
resource "oci_core_nat_gateway" "oke_nat_gw" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-ederbrito-nat-gw"
  vcn_id         = oci_core_vcn.oke_vcn.id
}

# Service Gateway — allows private nodes to access OCI services without public internet
resource "oci_core_service_gateway" "oke_svc_gw" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-ederbrito-svc-gw"
  vcn_id         = oci_core_vcn.oke_vcn.id

  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

# Private route table — routes through NAT for internet, Service Gateway for OCI services
resource "oci_core_route_table" "node_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id

  route_rules {
    network_entity_id = oci_core_nat_gateway.oke_nat_gw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_service_gateway.oke_svc_gw.id
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
  }
}

# Private subnet for worker nodes (no public IPs)
resource "oci_core_subnet" "node_subnet" {
  cidr_block        = "10.0.3.0/24"
  display_name      = "oke-ederbrito-node-subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.oke_vcn.id
  route_table_id    = oci_core_route_table.node_private_rt.id
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.node_sl.id]
}

# -------------------------------
# Security Lists
# -------------------------------

# Security List for API endpoint subnet — allows inbound Kubernetes API traffic (port 6443)
resource "oci_core_security_list" "api_endpoint_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ederbrito-api-endpoint-sl"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # Internal VCN communication
  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    description = "Allow all internal VCN communication"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Security List for worker node subnet — allows all traffic within VCN and unrestricted outbound
resource "oci_core_security_list" "node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ederbrito-node-sl"

  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "lb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ederbrito-lb-sl"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
