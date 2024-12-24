output "dv_txt_records" {
  description = "Show DNS txt records that need to be created for validation"
  value       = akamai_cps_dv_enrollment.certificate_enrollment
}
