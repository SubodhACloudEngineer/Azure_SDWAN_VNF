output "public_ips" {
  description = "Map of site => public IP"
  value       = { for k, m in module.vm : k => m.public_ip }
}

output "vm_names" {
  value = { for k, m in module.vm : k => m.vm_name }
}

output "resource_groups" {
  value = { for k, m in module.network : k => m.resource_group_name }
}
