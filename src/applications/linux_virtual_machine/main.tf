module "resource_group" {
  source = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/resource_group/data?ref=v0.0.1"
  name   = var.rg_name
}

module "virtual_network" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/virtual_network/resource?ref=v0.0.1"
  name                = "vnet-vm-msb-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}

module "subnet" {
  source               = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/subnet/resource?ref=v0.0.1"
  name                 = "nic-vm-msb-${var.environment}"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip_address" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/public_ip_address/resource?ref=v0.0.1"
  name                = "pip-vm-msb-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  allocation_method   = "Dynamic"
  domain_name_label   = "vm-msb-${module.resource_group.location}-${var.environment}"
}

module "network_interface" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/network_interface/resource?ref=v0.0.1"
  name                = "subnet-vm-msb-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  ip_configurations = [{
    name                          = "nic-vm-msb-${var.environment}"
    subnet_id                     = module.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.public_ip_address.id
  }]
}

module "storage_account" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/storage_account/data?ref=v0.0.1"
  name                = "stomsb${var.environment}"
  resource_group_name = module.resource_group.name
}

locals {
  virtual_machine_name = upper("VM${module.resource_group.location}msb${var.environment}")
}

module "linux_virtual_machine" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/virtual_machine/resource/linux?ref=v0.0.1"
  name                = local.virtual_machine_name
  size                = var.size
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  computer_name       = "vm-msb-${var.environment}"

  network_interface_ids = [
    module.network_interface.id,
  ]

  os_disk = merge({ name = "OSDISK${local.virtual_machine_name}" }, var.os_disk)

  source_image_reference = var.source_image_reference
  storage_account_uri    = module.storage_account.primary_blob_endpoint
}

resource "null_resource" "configure_xrdp_server" {

  provisioner "local-exec" {
    command     = "./scripts/install-xrdp.sh"
    interpreter = ["/bin/bash"]
  }

  depends_on = [
    module.linux_virtual_machine
  ]
}
