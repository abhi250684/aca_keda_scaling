data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}
resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  address_space       = [var.address_prefix]
  tags                = local.tags
}
resource "azurerm_subnet" "aca" {
  name                 = "snet-aca-${local.prefix}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aca_subnet_prefix]
  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
