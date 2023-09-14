locals {
    reset_password    = { for k, v in var.virtual_machine_vmaccess_extensions : k => v if lookup(v, "reset_rdp", false) == false }
    reset_rdp    = { for k, v in var.virtual_machine_vmaccess_extensions : k => v if lookup(v, "reset_rdp", false) == true }
    
    # ssh_key = local.reset_ssh == true ? lookup(data.azurerm_key_vault_secret.adminssh, each.key)["value"] : null
}
