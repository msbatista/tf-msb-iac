data "azurerm_subscription" "current" {
}

module "resource_group" {
  source = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/resource_group/data?ref=v0.0.10"
  name   = var.rg_name
}

module "network_security_group" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_security_group/resource?ref=v0.0.10"
  name                = "nsg-influxdb-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "network_security_rule_ssh_port_22" {
  source = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_security_rule/resource?ref=v0.0.10"

  name = "nsg-rule-ssh-${var.environment}"

  network_security_group_name = module.network_security_group.name
  resource_group_name         = module.resource_group.name

  rule = {
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "network_security_rule_influxdb_port_8086" {
  source = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_security_rule/resource?ref=v0.0.10"

  name = "nsg-rule-influxdb-${var.environment}"

  network_security_group_name = module.network_security_group.name
  resource_group_name         = module.resource_group.name

  rule = {
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8086"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "virtual_network" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/virtual_network/resource?ref=v0.0.10"
  name                = "vnet-vm-influxdb-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}

module "subnet" {
  source               = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/subnet/resource?ref=v0.0.10"
  name                 = "nic-vm-influxdb-${var.environment}"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip_address" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/public_ip_address/resource?ref=v0.0.10"
  name                = "pip-vm-influxdb-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  allocation_method   = "Dynamic"
  domain_name_label   = "vm-influxdb-${module.resource_group.location}-${var.environment}"
}

module "network_interface" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_interface/resource?ref=v0.0.10"
  name                = "subnet-vm-influxdb-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  ip_configurations = [{
    name                          = "nic-vm-influxdb-${var.environment}"
    subnet_id                     = module.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.public_ip_address.id
  }]
}

module "nsg_rule_association" {
  source                    = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_interface_security_group_association/resource?ref=v0.0.10"
  network_interface_id      = module.network_interface.id
  network_security_group_id = module.network_security_group.id
}

module "storage_account" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/storage_account/data?ref=v0.0.10"
  name                = "stomsb${var.environment}"
  resource_group_name = module.resource_group.name
}

locals {
  virtual_machine_name = upper("VMTSDB${module.resource_group.location}influxdb${var.environment}")
}

resource "tls_private_key" "vm_influxdb_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "tls_private_key" {
  value     = tls_private_key.vm_influxdb_ssh.private_key_pem
  sensitive = true
}

module "linux_virtual_machine" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/virtual_machine/resource/linux_ssh?ref=v0.0.10"
  name                = local.virtual_machine_name
  size                = var.size
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  admin_username      = var.admin_user
  computer_name       = "vm-tsdb-influxdb-msb-${var.environment}"

  network_interface_ids = [
    module.network_interface.id,
  ]

  os_disk = merge({ name = "OSDISK${local.virtual_machine_name}" }, var.os_disk)

  source_image_reference = var.source_image_reference
  storage_account_uri    = module.storage_account.primary_blob_endpoint

  url_certifcates = [
    {
      url = "https://kms-msb-${var.environment}.vault.azure.net/secrets/influxdb-self-signed-certificate/${var.secret_identifier}"
    }
  ]

  key_vault_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rg-msb-${var.environment}/providers/Microsoft.KeyVault/vaults/kms-msb-${var.environment}"

  public_key = tls_private_key.vm_influxdb_ssh.public_key_openssh

  tags = {
    environment = var.environment
  }
}
