locals {
  registry_server = split("/", var.image)[0]
}
resource "azapi_resource" "this" {
  type      = "Microsoft.App/containerApps@2025-01-01"
  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags
  schema_validation_enabled = false
  identity {
    type         = var.identity_id == null ? "SystemAssigned" : "UserAssigned"
    identity_ids = var.identity_id == null ? [] : [var.identity_id]
  }
  body = {
    properties = {
      managedEnvironmentId = var.environment_id
      workloadProfileName  = var.workload_profile_name
      configuration = merge(
        { activeRevisionsMode = "Single" },
        var.identity_id == null ? {} : { registries = [{ server = local.registry_server, identity = var.identity_id }] },
        var.external_ingress ? { ingress = { external = true, targetPort = var.target_port, transport = "auto", traffic = [{ latestRevision = true, weight = 100 }] } } : {}
      )
      template = {
        containers = [{
          name      = "app", image = var.image,
          resources = { cpu = var.cpu, memory = var.memory },
          env       = [for k, v in var.env : { name = k, value = v }],
          probes = var.external_ingress ? [
            { type = "Liveness", httpGet = { path = "/health", port = var.target_port }, initialDelaySeconds = 10, periodSeconds = 10 },
            { type = "Readiness", httpGet = { path = "/health", port = var.target_port }, initialDelaySeconds = 5, periodSeconds = 5 }
          ] : []
        }]
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
          rules = [for r in var.rules : {
            name   = r.name
            custom = merge({ type = r.type, metadata = r.metadata }, try(r.identity, null) == null ? {} : { identity = r.identity })
          }]
        }
      }
    }
  }
  response_export_values = ["properties.configuration.ingress.fqdn"]
  depends_on             = [terraform_data.dependencies]
}
resource "terraform_data" "dependencies" { input = var.depends_on_resources }
