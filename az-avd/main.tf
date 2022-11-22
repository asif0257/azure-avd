resource "azurerm_virtual_desktop_host_pool" "avd-hp" {
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name

  name                     = "testhostpool"
  friendly_name            = "avdpool"
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;"
  description              = "avd host-poool demo"
  type                     = "Pooled"
  maximum_sessions_allowed = 5
  load_balancer_type       = "DepthFirst"
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = "AVD-Desktop"
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.avd-hp.id
  friendly_name = "AVD-application"
  description   = "avd applications"
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "AVD-WORKSPACE"
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  friendly_name = "ANS-AVD_WRSPC"
  description   = "Work Purporse"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  depends_on = [
      azurerm_network_interface.sessionhost_nic
  ]
  count=2
  name                = "avdvm-${count.index}"
  resource_group_name = azurerm_resource_group.rg-avd.name
  location            = azurerm_resource_group.rg-avd.location
  size                = "Standard_B2MS"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  provision_vm_agent = true
  
  network_interface_ids = [azurerm_network_interface.sessionhost_nic.*.id[count.index]]

  identity {
    type  = "SystemAssigned"
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

 source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }
}

locals {
 registration_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ4NEJBMzVERTg5RjQxODlEQUQ4RDREMUFBRDg3MzBCRkZCNzg2QzAiLCJ0eXAiOiJKV1QifQ.eyJSZWdpc3RyYXRpb25JZCI6IjlhMWEzNTI5LTgwNmEtNDFkZC04MDBkLWJlYjJiZTM4YzdjMiIsIkJyb2tlclVyaSI6Imh0dHBzOi8vcmRicm9rZXItZy1ldS1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1VyaSI6Imh0dHBzOi8vcmRkaWFnbm9zdGljcy1nLWV1LXIwLnd2ZC5taWNyb3NvZnQuY29tLyIsIkVuZHBvaW50UG9vbElkIjoiNGQ5MGIzOGQtODk3Ni00NzU4LTgzZjYtYWNjNTVkZjRkMmFkIiwiR2xvYmFsQnJva2VyVXJpIjoiaHR0cHM6Ly9yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJHZW9ncmFwaHkiOiJFVSIsIkdsb2JhbEJyb2tlclJlc291cmNlSWRVcmkiOiJodHRwczovLzRkOTBiMzhkLTg5NzYtNDc1OC04M2Y2LWFjYzU1ZGY0ZDJhZC5yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJCcm9rZXJSZXNvdXJjZUlkVXJpIjoiaHR0cHM6Ly80ZDkwYjM4ZC04OTc2LTQ3NTgtODNmNi1hY2M1NWRmNGQyYWQucmRicm9rZXItZy1ldS1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1Jlc291cmNlSWRVcmkiOiJodHRwczovLzRkOTBiMzhkLTg5NzYtNDc1OC04M2Y2LWFjYzU1ZGY0ZDJhZC5yZGRpYWdub3N0aWNzLWctZXUtcjAud3ZkLm1pY3Jvc29mdC5jb20vIiwiQUFEVGVuYW50SWQiOiI2M2NmMTRiNC03ZDBlLTQ0OTgtOTg3OS03NjIyYTIxZWEwOTIiLCJuYmYiOjE2Njg3NTI1ODAsImV4cCI6MTY2OTA1NTQwMCwiaXNzIjoiUkRJbmZyYVRva2VuTWFuYWdlciIsImF1ZCI6IlJEbWkifQ.jgbYCDupG2IMYdRKRJ5uC7lobytem6Fh0Q0thnQQ0Zrj5M9IeDOTSXbMEdJX4MuwpLJNY1Gi3Ao0C5PXCEREPLPn7vWw0ArkV4cCH6ycPhBEkSGlh5s85CLRUxMaWhs2ilO0E7qs3DNrxdF0YpgOkrNjuUTz8FneV5GzPsLiAv_vkEvU03XLdPE5LQMdKEwBLkAZWzfaLYHH_T6dvu-i85m6l3p3WGh-Yh9jMcKfv-5OO5pJNXcmvW5Nd8Z1U8n2QxPHXYWWTgJxTmNbbDbVLCUv23GfHFeqBhVBg57Hy0CpnpXMua607bz1etERLE9FtVilkucZPzsIqPkxDD4iYA"
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  commandtorun         = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command   = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "AVDModule" {
  depends_on = [
      azurerm_windows_virtual_machine.avd_sessionhost
  ]
  count = 2
  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"
  settings = <<-SETTINGS
    {
        "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_11-22-2021.zip",
        "ConfigurationFunction": "Configuration.ps1\\AddSessionHost",
        "Properties" : {
          "hostPoolName" : "${azurerm_virtual_desktop_host_pool.avd-hp.name}",
          "aadJoin": true
        }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

}
resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  depends_on = [
      azurerm_windows_virtual_machine.avd_sessionhost,
        azurerm_virtual_machine_extension.AVDModule
  ]
  count = 2
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "addaadjprivate" {
    depends_on = [
      azurerm_virtual_machine_extension.AADLoginForWindows
    ]
    count              = 2
  name                 = "AADJPRIVATE"
  virtual_machine_id   =  azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}