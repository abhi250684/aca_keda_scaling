variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_id" { type = string }
variable "environment_id" { type = string }
variable "workload_profile_name" { type = string }
variable "image" { type = string }
variable "cpu" { type = number }
variable "memory" { type = string }
variable "min_replicas" { type = number }
variable "max_replicas" { type = number }
variable "identity_id" {
  type    = string
  default = null
}
variable "external_ingress" {
  type    = bool
  default = false
}
variable "target_port" {
  type    = number
  default = 8080
}
variable "env" {
  type    = map(string)
  default = {}
}
variable "rules" { type = list(object({ name = string, type = string, identity = optional(string), metadata = map(string) })) }
variable "tags" { type = map(string) }
variable "depends_on_resources" {
  type    = list(string)
  default = []
}
