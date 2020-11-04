locals {
  #anywhere = "0.0.0.0/0"
  osn_cidrs = {for x in data.oci_core_services.all_services.services : x.cidr_block => x.id}
}

data "oci_core_services" "all_services" {
}

### VCN
resource "oci_core_vcn" "this" {
  dns_label      = var.vcn_dns_label
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
}

### Internet Gateway
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.service_label}-Internet-Gateway"
}

### NAT Gateway
resource "oci_core_nat_gateway" "this" {
    compartment_id = var.compartment_id
    display_name  = "${var.service_label}-NAT-Gateway"
    vcn_id         = oci_core_vcn.this.id

    block_traffic = var.block_nat_traffic
}

### Service Gateway
resource "oci_core_service_gateway" "this" {
    compartment_id = var.compartment_id
    display_name   = "${var.service_label}-Service-Gateway"
    vcn_id         = oci_core_vcn.this.id
    services {
      service_id = local.osn_cidrs[var.service_gateway_cidr]
    }
}

### Subnets
resource "oci_core_subnet" "these" {
  for_each = var.subnets
    vcn_id                      = oci_core_vcn.this.id
    cidr_block                  = each.value.cidr
    compartment_id              = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id
    defined_tags                = each.value.defined_tags
    freeform_tags               = each.value.freeform_tags
    display_name                = each.key
    prohibit_public_ip_on_vnic  = each.value.private
    dns_label                   = each.value.dns_label
    dhcp_options_id             = each.value.dhcp_options_id
    route_table_id              = each.value.route_table_id
    security_list_ids           = each.value.security_list_ids
}

### Route tables
resource "oci_core_route_table" "these" {
  for_each = var.route_tables
    display_name   = each.key
    vcn_id         = oci_core_vcn.this.id
    compartment_id = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id

    dynamic "route_rules" {
      iterator = rule
      for_each = [for r in each.value.route_rules : {
        dst : r.destination
        dst_type : r.destination_type
        ntwk_entity_id : r.network_entity_id
      }]

      content {
        destination = rule.value.dst
        destination_type = rule.value.dst_type
        network_entity_id = rule.value.ntwk_entity_id
      }
    }
}

/*
### Internet Route Table
resource "oci_core_route_table" "internet" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-Internet-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

### Private App Subnet Route Table
resource "oci_core_route_table" "private_subnet_app" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-Private-Subnet-App-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = var.service_gateway_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  } 

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

}

### Private Db Subnet Route Table
resource "oci_core_route_table" "private_subnet_db" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_label}-Private-Subnet-Db-Route"
  vcn_id         = oci_core_vcn.this.id
  
  route_rules {
    destination       = var.service_gateway_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  } 

}
*/