data "azurerm_availability_zones" "zones" {
  location = var.location
}

resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {
  name                = "web-scale-set"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_B1s"
  instances           = length(data.azurerm_availability_zones.zones.names)
  admin_username      = "azureuser"
  admin_password      = var.vm_password
  source_image_id     = var.image_id
  upgrade_mode        = "Manual"
  zone_balance        = true
  zones               = data.azurerm_availability_zones.zones.names

  network_interface {
    name    = "web-nic"
    primary = true

    ip_configuration {
      name      = "web-ipconfig"
      subnet_id = var.subnet_id
      primary   = true
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}