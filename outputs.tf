output "id" {
  description = "Our certificate entitlement id"
  value       = resource.null_resource.entitlement.id
}

output "hostnames" {
  value = local.hostnames
}
