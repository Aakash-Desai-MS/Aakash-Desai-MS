variable "virtual_machine_vmaccess_extensions" {
  description = "Specifies the name of the Virtual Machine Extension should be installed"
  type = map(object({
    name                      = string
    virtual_machine_name      = string
    vm_resource_group_name    = string
    type_handler_version      = optional(string)
    infra_keyvault_name             = string
    kv_resource_group               = string
    username                  = string
    password_secret_name      = string
    reset_ssh                 = bool
    ssh_key_secret_name       = string
    remove_user               = string
  }))

default = {
  "key" = {
    name                  = "reset1"
    password_secret_name = "testpass"
    remove_user = ""
    reset_rdp = true
    infra_keyvault_name             = "infrakv011"
    kv_resource_group               = "vm-rg"
    rdp_key_secret_name = "rdpkey-pubkey"
    type_handler_version = "1.5"
    username = "shyam121"
    virtual_machine_name = "testvm"
    vm_resource_group_name = "vm-rg"
  }
}
}
