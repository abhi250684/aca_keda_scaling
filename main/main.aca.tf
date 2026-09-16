resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${local.prefix}"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = var.location
  infrastructure_subnet_id   = azurerm_subnet.aca.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  workload_profile {
    name                  = var.workload_profile.name
    workload_profile_type = var.workload_profile.type
    minimum_count         = var.workload_profile.minimum_count
    maximum_count         = var.workload_profile.maximum_count
  }
  tags = local.tags
}

module "servicebus_worker" {
  source                = "./modules/container-app"
  name                  = "ca-${local.prefix}-servicebus"
  location              = var.location
  resource_group_id     = data.azurerm_resource_group.this.id
  environment_id        = azurerm_container_app_environment.this.id
  workload_profile_name = var.workload_profile.name
  image                 = var.images.servicebus_worker
  cpu                   = var.container_defaults.cpu
  memory                = var.container_defaults.memory
  min_replicas          = var.scaling.servicebus.min_replicas
  max_replicas          = var.scaling.servicebus.max_replicas
  identity_id           = azurerm_user_assigned_identity.servicebus.id
  env = {
    SERVICEBUS_NAMESPACE = "${azurerm_servicebus_namespace.this.name}.servicebus.windows.net"
    SERVICEBUS_QUEUE     = azurerm_servicebus_queue.orders.name
    AZURE_CLIENT_ID      = azurerm_user_assigned_identity.servicebus.client_id
  }
  rules = [{
    name     = "servicebus-queue", type = "azure-servicebus", identity = azurerm_user_assigned_identity.servicebus.id,
    metadata = { namespace = azurerm_servicebus_namespace.this.name, queueName = azurerm_servicebus_queue.orders.name, messageCount = tostring(var.scaling.servicebus.target), activationMessageCount = "1" }
  }]
  tags                 = local.tags
  depends_on_resources = [azurerm_role_assignment.servicebus_receiver.id, azurerm_role_assignment.servicebus_acr_pull.id]
}

module "storage_worker" {
  source                = "./modules/container-app"
  name                  = "ca-${local.prefix}-storage"
  location              = var.location
  resource_group_id     = data.azurerm_resource_group.this.id
  environment_id        = azurerm_container_app_environment.this.id
  workload_profile_name = var.workload_profile.name
  image                 = var.images.storagequeue_worker
  cpu                   = var.container_defaults.cpu
  memory                = var.container_defaults.memory
  min_replicas          = var.scaling.storage.min_replicas
  max_replicas          = var.scaling.storage.max_replicas
  identity_id           = azurerm_user_assigned_identity.storage.id
  env = {
    STORAGE_ACCOUNT_URL = azurerm_storage_account.this.primary_queue_endpoint
    STORAGE_QUEUE       = azurerm_storage_queue.work.name
    AZURE_CLIENT_ID     = azurerm_user_assigned_identity.storage.client_id
  }
  rules = [{
    name     = "storage-queue", type = "azure-queue", identity = azurerm_user_assigned_identity.storage.id,
    metadata = { accountName = azurerm_storage_account.this.name, queueName = azurerm_storage_queue.work.name, queueLength = tostring(var.scaling.storage.target) }
  }]
  tags                 = local.tags
  depends_on_resources = [azurerm_role_assignment.storage_processor.id, azurerm_role_assignment.storage_acr_pull.id]
}

module "cpu_api" {
  source                = "./modules/container-app"
  name                  = "ca-${local.prefix}-cpu"
  location              = var.location
  resource_group_id     = data.azurerm_resource_group.this.id
  environment_id        = azurerm_container_app_environment.this.id
  workload_profile_name = var.workload_profile.name
  image                 = var.images.metrics_api
  cpu                   = var.container_defaults.cpu
  memory                = var.container_defaults.memory
  min_replicas          = var.scaling.cpu.min_replicas
  max_replicas          = var.scaling.cpu.max_replicas
  identity_id           = azurerm_user_assigned_identity.api.id
  external_ingress      = true
  rules                 = [{ name = "cpu", type = "cpu", identity = null, metadata = { type = "Utilization", value = tostring(var.scaling.cpu.target) } }]
  tags                  = local.tags
  depends_on_resources  = [azurerm_role_assignment.api_acr_pull.id]
}

module "memory_api" {
  source                = "./modules/container-app"
  name                  = "ca-${local.prefix}-memory"
  location              = var.location
  resource_group_id     = data.azurerm_resource_group.this.id
  environment_id        = azurerm_container_app_environment.this.id
  workload_profile_name = var.workload_profile.name
  image                 = var.images.metrics_api
  cpu                   = var.container_defaults.cpu
  memory                = var.container_defaults.memory
  min_replicas          = var.scaling.memory.min_replicas
  max_replicas          = var.scaling.memory.max_replicas
  identity_id           = azurerm_user_assigned_identity.api.id
  external_ingress      = true
  rules                 = [{ name = "memory", type = "memory", identity = null, metadata = { type = "Utilization", value = tostring(var.scaling.memory.target) } }]
  tags                  = local.tags
  depends_on_resources  = [azurerm_role_assignment.api_acr_pull.id]
}
