locals {
  prefix = lower("${var.app_name}-${var.environment}")
  tags   = var.generic_tags
}
