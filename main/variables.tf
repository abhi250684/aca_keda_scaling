variable "subscription_id" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "app_name" { type = string }
variable "environment" { type = string }
variable "virtual_network_name" { type = string }
variable "address_prefix" { type = string }
variable "aca_subnet_prefix" { type = string }
variable "generic_tags" { type = map(string) }
variable "workload_profile" {
  type = object({ name = string, type = string, minimum_count = number, maximum_count = number })
}
variable "images" {
  type = object({ servicebus_worker = string, storagequeue_worker = string, metrics_api = string })
}
variable "acr_id" { type = string }
variable "scaling" {
  type = object({
    servicebus = object({ min_replicas = number, max_replicas = number, target = number })
    storage    = object({ min_replicas = number, max_replicas = number, target = number })
    cpu        = object({ min_replicas = number, max_replicas = number, target = number })
    memory     = object({ min_replicas = number, max_replicas = number, target = number })
  })
}
