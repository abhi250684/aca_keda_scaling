resource "azurerm_user_assigned_identity" "api" {
  name                = "id-${local.prefix}-api"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}
resource "azurerm_role_assignment" "api_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.api.principal_id
}
resource "azurerm_role_assignment" "servicebus_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.servicebus.principal_id
}
resource "azurerm_role_assignment" "storage_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}
resource "azurerm_user_assigned_identity" "servicebus" {
  name                = "id-${local.prefix}-servicebus"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-${local.prefix}-storage"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}
resource "azurerm_role_assignment" "servicebus_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.servicebus.principal_id
}
resource "azurerm_role_assignment" "storage_processor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Message Processor"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}
