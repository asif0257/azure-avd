data "azuread_client_config" "current" {}

resource "azuread_user" "aad_user" {
  user_principal_name = "user3@asifmohammed2022outlook.onmicrosoft.com"
  display_name = "user3"
  mail_nickname = "User"
  password = "Secret123@"
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

resource "azuread_group" "aad_group" {
  display_name     = "MyGrp"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.aad_user.object_id,
    /* more users */
  ]
}


resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.desktopapp.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aad_group.id
}

#variable "avd_users" {
 # description = "AVD users"
 # default = [
 #   "avduser01@contoso.net",
 #   "avduser02@contoso.net"
 # ]
#}

variable "aad_group_name" {
  type        = string
  default     = "AVDUsers"
  description = "Azure Active Directory Group for AVD users"
}
