module "resource_group" {
  source = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/resource_group/data?ref=v0.0.1"
  name   = "rg-msb-${var.environment}"
}

module "storage_account" {
  source              = "git::https://github.com/msbatista/tf-msb-iac-modules.git//modules/storage_account/resource?ref=v0.0.1"
  name                = "stomsb${var.environment}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}
