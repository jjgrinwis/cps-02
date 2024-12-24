variable "common_name" {
  description = "Common Name(CN) of the certificate"
  type        = string
  # validation ( make sure it's a decent CN)
}

variable "secure_network" {
  description = "Akamai network to use"
  type        = string
  validation {
    condition     = contains(["enhanced-tls", "standard-tls"], var.region)
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
}