resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = var.vm_password_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "vm" {
  source              = "./modules/vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id
  vm_password         = data.azurerm_key_vault_secret.vm_password.value
}

module "image" {
  source              = "./modules/image"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_id               = module.vm.vm_id
}

module "scale_set" {
  source              = "./modules/scale_set"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id
  image_id            = module.image.image_id
  vm_password         = data.azurerm_key_vault_secret.vm_password.value
}