resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}
resource "azurerm_servicebus_namespace" "this" {
  name                = "sb-${local.prefix}-${random_string.suffix.result}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Standard"
  tags                = local.tags
}
resource "azurerm_servicebus_queue" "orders" {
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.this.id
}
resource "azurerm_storage_account" "this" {
  name                      = substr(replace("st${local.prefix}${random_string.suffix.result}", "-", ""), 0, 24)
  resource_group_name       = data.azurerm_resource_group.this.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = false
  tags                      = local.tags
}
resource "azurerm_storage_queue" "work" {
  name               = "work-items"
  storage_account_id = azurerm_storage_account.this.id
}
