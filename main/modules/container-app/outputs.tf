output "id" { value = azapi_resource.this.id }
output "fqdn" { value = try(azapi_resource.this.output.properties.configuration.ingress.fqdn, null) }
