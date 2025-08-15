
# -------------------------------
# Data Sources
# -------------------------------

# Retrieve all availability domains for the given compartment
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Retrieve the Oracle Services Network service entry 
# for setting up service gateways
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}