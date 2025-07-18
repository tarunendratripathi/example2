resource "azurerm_network_interface" "nic" {
  name                = "nic-web"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = var.vm_password
  network_interface_ids = [azurerm_network_interface.nic.id]
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "osdisk-web"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
      "echo '<h1>Hello from Apache on Azure VM</h1>' | sudo tee /var/www/html/index.html"
    ]

    connection {
      type     = "ssh"
      user     = "azureuser"
      password = var.vm_password
      host     = azurerm_network_interface.nic.private_ip_address
    }
  }
}