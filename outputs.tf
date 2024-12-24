output "dv_txt_records" {
  description = "Show DNS txt records that need to be created for validation"
  value       = akamai_cps_dv_enrollment.certificate_enrollment.dns_challenges
}

output "sans" {
  description = "Show DNS txt records that need to be created for validation"
  value       = akamai_cps_dv_enrollment.certificate_enrollment.sans
}

output "number_of_san_entries" {
  description = "The number of items in our san list, should't be to large"
  value       = length(akamai_cps_dv_enrollment.certificate_enrollment.sans) + 1
}
