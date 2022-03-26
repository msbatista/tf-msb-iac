variable "rg_name" {
  type        = string
  description = "Target resource group."
}


variable "environment" {
  type        = string
  description = "Target environment that changes will be applied to."
}

variable "admin_user" {
  type        = string
  description = "The name for VM's administrative user."
  sensitive   = true
}

variable "os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
  })
  description = "A block that defines the type of th cache and the type of the storage account."
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Specifies which image and version will used."
}

variable "size" {
  type        = string
  description = "The SKU which should be used for this Virtual Machine."
}

variable "secret_identifier" {
  type = string
  description = "The id of the secret certificate."
}
