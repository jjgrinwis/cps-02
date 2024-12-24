terraform {
  cloud {
    organization = "grinwis-com"
    workspaces {
      name = "cps-02"
    }
  }
}

resource "null_resource" "entitlement" {
}

/*
resource "akamai_cps_dv_enrollment" "certificate_enrollment" {
  common_name                           = var.common_name
  allow_duplicate_common_name           = false
  sans                                  = var.sans
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
    country_code     = ""
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
    client_mutual_authentication {
      send_ca_list_to_client = true
      ocsp_enabled           = false
      set_id                 = "84344"
    }
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
    email        = "test@example.com"
    phone        = "061111111"
  }
  organization {
    name             = "org"
    phone            = "1111111"
    address_line_one = "street"
    city             = "city"
    region           = "region"
    postal_code      = ""
    country_code     = ""
  }
  contract_id = "ctr_M-1WJGRZ7"
}
*/
