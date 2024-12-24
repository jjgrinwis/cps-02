terraform {
  cloud {
    organization = "grinwis-com"
    workspaces {
      name = "cps-02"
    }
  }
}

# just use group_name to lookup our contract_id and group_id
# this will simplify our variables file as this contains contract and group id
# use "akamai property groups list" to find all your groups
data "akamai_contract" "contract" {
  group_name = var.group_name
}

// get all workspaces based on tags
// when running 'remote', we need to set TFE token in provider config or ENV var
// https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#authentication
data "tfe_workspace_ids" "properties" {
  tag_names    = ["mtls"]
  organization = var.organization
}

data "tfe_outputs" "all" {
  for_each     = data.tfe_workspace_ids.properties.ids
  organization = var.organization
  workspace    = each.key
}

locals {
  // hostnames var is a list of hostnames we're going to use in our SAN list of our certificate.
  hostnames = {

    // flatten the list so we get just one list.
    // we're converting a list to a set.
    value = toset(flatten([
      // first loop over the output of set of workspaces
      for item in data.tfe_outputs.all : [
        // for each workspace, get the value of the specific output field (map)
        // if key doesn't exists in the map, make it null
        // only add item to our list if it's not null
        lookup(item.nonsensitive_values, "created_hostnames", null)
      ] if lookup(item.nonsensitive_values, "created_hostnames", null) != null
    ]))
  }
}

// let's store our entitlement id our pre-configured variable set in HCP Terraform.
data "tfe_variable_set" "test" {
  name         = var.variable_set
  organization = var.organization
}

// if variable already exists in your variable set just delete it.
resource "tfe_variable" "cps_entitlement_id" {
  key             = "entitlement_id"
  value           = resource.akamai_cps_dv_enrollment.certificate_enrollment.id
  category        = "terraform"
  description     = "Our CPS entitlement id set as a Terraform variable so used as input var for our properties"
  variable_set_id = data.tfe_variable_set.test.id
}

// make sure san list it not too long. 
resource "akamai_cps_dv_enrollment" "certificate_enrollment" {
  common_name                           = var.common_name
  allow_duplicate_common_name           = false
  sans                                  = local.hostnames.value
  secure_network                        = var.secure_network
  sni_only                              = true
  acknowledge_pre_verification_warnings = false
  admin_contact {
    first_name       = var.customer_cert_info.first_name
    last_name        = var.customer_cert_info.last_name
    organization     = var.customer_cert_info.organization
    email            = var.customer_cert_info.email
    phone            = var.customer_cert_info.phone
    address_line_one = var.customer_cert_info.address_line_one
    city             = var.customer_cert_info.city
    region           = var.customer_cert_info.region
    postal_code      = var.customer_cert_info.postal_code
    country_code     = var.customer_cert_info.country_code
  }
  certificate_chain_type = "default"
  csr {
    country_code        = var.customer_cert_info.country_code
    city                = var.customer_cert_info.city
    organization        = var.customer_cert_info.organization
    organizational_unit = var.customer_cert_info.organizational_unit
    state               = var.customer_cert_info.state
  }
  network_configuration {
    /*
    client_mutual_authentication {
      send_ca_list_to_client = true
      ocsp_enabled           = false
      set_id                 = "84344"
    }
    */
    disallowed_tls_versions = var.disallowed_tls_versions
    clone_dns_names         = true
    geography               = "core"
    must_have_ciphers       = var.must_have_ciphers
    ocsp_stapling           = "on"
    preferred_ciphers       = var.preferred_ciphers
  }
  signature_algorithm = "SHA-256"
  tech_contact {
    first_name   = var.akamai_cert_info.first_name
    last_name    = var.akamai_cert_info.last_name
    organization = var.akamai_cert_info.organization
    email        = var.akamai_cert_info.email
    phone        = var.akamai_cert_info.phone
  }
  organization {
    name             = var.akamai_cert_info.organization
    phone            = var.akamai_cert_info.phone
    address_line_one = var.akamai_cert_info.address_line_one
    city             = var.akamai_cert_info.city
    region           = var.akamai_cert_info.region
    postal_code      = var.akamai_cert_info.postal_code
    country_code     = var.akamai_cert_info.country_code
  }
  contract_id = data.akamai_contract.contract.id
}

