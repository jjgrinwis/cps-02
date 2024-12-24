output "dv_txt_records" {
  description = "Show DNS txt records that need to be created for validation"
  value       = akamai_cps_dv_enrollment.certificate_enrollment.dns_challenges
}

output "sans" {
  description = "Show DNS txt records that need to be created for validation"
  value       = akamai_cps_dv_enrollment.certificate_enrollment.sans
}
