output "servicebus_namespace" { value = azurerm_servicebus_namespace.this.name }
output "servicebus_queue" { value = azurerm_servicebus_queue.orders.name }
output "storage_account" { value = azurerm_storage_account.this.name }
output "storage_queue" { value = azurerm_storage_queue.work.name }
output "container_app_fqdns" { value = { cpu = module.cpu_api.fqdn, memory = module.memory_api.fqdn } }
