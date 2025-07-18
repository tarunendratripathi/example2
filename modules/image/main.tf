resource "azurerm_image" "vm_image" {
  name                = "web-image"
  location            = var.location
  resource_group_name = var.resource_group_name
  source_virtual_machine_id = var.vm_id
}