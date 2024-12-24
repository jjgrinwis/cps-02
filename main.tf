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


resource "akamai_cps_dv_enrollment" "certificate_enrollment" {
  common_name                           = var.common_name
  allow_duplicate_common_name           = false
  sans                                  = local.hostnames.value
  secure_network                        = var.secure_network
  sni_only                              = true
  acknowledge_pre_verification_warnings = false
  admin_contact {
    first_name       = "first"
    last_name        = "last"
    organization     = "org"
    email            = "first.last@example.com"
    phone            = "06111111"
    address_line_one = ""
    city             = ""
    region           = ""
    postal_code      = ""
    country_code     = "NL"
  }
  certificate_chain_type = "default"
  csr {
    country_code        = "NL"
    city                = "city"
    organization        = "org"
    organizational_unit = ""
    state               = ""
  }
  network_configuration {
    /*
    client_mutual_authentication {
      send_ca_list_to_client = true
      ocsp_enabled           = false
      set_id                 = "84344"
    }
    */
    disallowed_tls_versions = ["TLSv1", "TLSv1_1", ]
    clone_dns_names         = true
    geography               = "core"
    must_have_ciphers       = "ak-akamai-2020q1"
    ocsp_stapling           = "on"
    preferred_ciphers       = "ak-akamai-2020q1"
  }
  signature_algorithm = "SHA-256"
  tech_contact {
    first_name   = "first"
    last_name    = "last"
    organization = "Akamai"
    email        = "test@akamai.com"
    phone        = "061111111"
  }
  organization {
    name             = "org"
    phone            = "1111111"
    address_line_one = "street"
    city             = "city"
    region           = "region"
    postal_code      = "postal"
    country_code     = "NL"
  }
  contract_id = data.akamai_contract.contract.id
}

