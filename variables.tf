variable "organization" {
  description = "HCP Terraform organization name"
  type        = string
}

variable "variable_set" {
  description = "The variable set assigned to our project"
  type        = string
  default     = "TFE"
}

variable "common_name" {
  description = "Common Name(CN) of the certificate"
  type        = string
  # validation ( make sure it's a decent CN)
}

variable "secure_network" {
  description = "Akamai network to use"
  type        = string
  validation {
    condition     = contains(["enhanced-tls", "standard-tls"], var.secure_network)
    error_message = "A valid Akamai network should be selected."
  }
  default = "enhanced-tls"

}

variable "sans" {
  description = "The Subject Alternative Names (SANS) on the certificate"
  type        = set(string)
  validation {
    condition     = length(var.sans) <= 50
    error_message = "The SAN list cannot contain more than 50 elements."
  }
  default = []
}

variable "group_name" {
  description = "Akamai group to lookup contract_id"
  type        = string
}

variable "entitlement_id" {
  description = "Our unused entitlement_id to to ignore some warnings as it will be set automatically by a variable set."
  type        = number
}

// all required certificate information
variable "customer_cert_info" {
  description = "All info required for our certificate request"
  type        = map(string)
  default = {
    first_name          = "first"
    last_name           = "last"
    organization        = "org"
    email               = "first.last@example.com"
    phone               = "06111111"
    address_line_one    = "address"
    city                = "city"
    region              = "region"
    postal_code         = "postal_code"
    country_code        = "NL"
    organizational_unit = ""
    state               = ""
  }
}

variable "akamai_cert_info" {
  description = "All Akamai required info for our certificate request"
  type        = map(string)
  default = {
    first_name       = "first"
    last_name        = "last"
    organization     = "Akamai"
    email            = "cps@akamai.com"
    phone            = "+1-6174443000"
    address_line_one = "145 Broadway"
    city             = "Cambridge"
    region           = "region"
    postal_code      = "MA 02142"
    country_code     = "US"
  }
}
