subscription_id     = "<SUBSCRIPTION_ID>"
resource_group_name = "<RESOURCE_GROUP_NAME>"
location            = "Southeast Asia"
app_name            = "aca-keda"
environment         = "dev"
virtual_network_name = "vnet-aca-keda-dev"
address_prefix       = "10.26.20.0/24"
aca_subnet_prefix    = "10.26.20.0/25"

workload_profile = {
  name          = "dedicated-D4"
  type          = "D4"
  minimum_count = 1
  maximum_count = 5
}

# az acr show --name <acr-name> --query id --output tsv
acr_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.ContainerRegistry/registries/<ACR_NAME>"

images = {
  servicebus_worker   = "<ACR_NAME>.azurecr.io/aca-servicebus-worker:1.0.0"
  storagequeue_worker = "<ACR_NAME>.azurecr.io/aca-storagequeue-worker:1.0.0"
  metrics_api         = "<ACR_NAME>.azurecr.io/aca-metrics-api:1.0.0"
}

scaling = {
  servicebus = { min_replicas = 0, max_replicas = 10, target = 20 }
  storage    = { min_replicas = 0, max_replicas = 10, target = 20 }
  cpu        = { min_replicas = 1, max_replicas = 6, target = 70 }
  memory     = { min_replicas = 1, max_replicas = 6, target = 75 }
}

generic_tags = {
  Application = "aca-keda"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
