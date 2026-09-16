variable "container_defaults" {
  type    = object({ cpu = number, memory = string })
  default = { cpu = 0.5, memory = "1Gi" }
}
