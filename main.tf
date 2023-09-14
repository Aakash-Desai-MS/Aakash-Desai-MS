
data "azurerm_virtual_machine" "windowsvm" {
  for_each            = var.virtual_machine_vmaccess_extensions
  name                = each.value.virtual_machine_name
  resource_group_name = each.value.vm_resource_group_name
}

data "azurerm_key_vault" "infrakv" {
  for_each            = var.virtual_machine_vmaccess_extensions
  name                = each.value["infra_keyvault_name"]
  resource_group_name = each.value["kv_resource_group"]
}

data "azurerm_key_vault_secret" "adminpwd" {
  for_each     = local.reset_password
  name         = each.value["password_secret_name"]
  key_vault_id = data.azurerm_key_vault.infrakv[each.key].id
}


data "azurerm_key_vault_secret" "adminrdp" {
  for_each     = local.reset_rdp
  name         = each.value["rdp_key_secret_name"]
  key_vault_id = data.azurerm_key_vault.infrakv[each.key].id
}

resource "azurerm_virtual_machine_extension" "VMAccessForWindows" {
  for_each = local.reset_password == {} ? {}  : var.virtual_machine_vmaccess_extensions 
  name = "enablevmaccess1"
  virtual_machine_id = data.azurerm_virtual_machine.windowsvm[each.key].id
  publisher = "Microsoft.OSTCExtensions"
  type = "VMAccessForWindows"
  type_handler_version =  "1.5"
  # automatic_upgrade_enabled = false
  # auto_upgrade_minor_version = true
  protected_settings = <<SETTINGS
        {
          "username": "${each.value.username}",
          "password": "${trimspace(lookup(data.azurerm_key_vault_secret.adminpwd, each.key)["value"])}"       
        }
    SETTINGS
   depends_on = [
      time_sleep.wait_3_seconds
    ]
}

resource "time_sleep" "wait_3_seconds" {
  create_duration = "3s"
}


resource "azurerm_virtual_machine_extension" "VMAccessForWindowsRDP" {
  for_each = local.reset_ssh == null ? {}  : var.virtual_machine_vmaccess_extensions 
  name              =  each.value.name
  virtual_machine_id = data.azurerm_virtual_machine.linuxvm[each.key].id
  publisher = "Microsoft.OSTCExtensions"
  type = "VMAccessForWindows"
  type_handler_version =  lookup(each.value , "type_handler_version" , "1.5")
  # automatic_upgrade_enabled = false
  auto_upgrade_minor_version = true
  protected_settings = <<SETTINGS
        {
          "username": "${each.value.username}",
           "ssh_key":  "${trimspace(lookup(data.azurerm_key_vault_secret.adminssh, each.key)["value"]) }" 
         
        }
    SETTINGS
    depends_on = [
      time_sleep.wait_3_seconds
    ]
}
