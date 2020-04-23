################################################################################
##  File:  Install-AzureCli.ps1
##  Desc:  Install Azure CLI
##  From: https://raw.githubusercontent.com/actions/virtual-environments/win19/20200319.1/images/win/scripts/Installers/Install-AzureCli.ps1
################################################################################

choco install azure-cli -y

$AzureCliExtensionPath = Join-Path $Env:CommonProgramFiles 'AzureCliExtensionDirectory'
New-Item -ItemType "directory" -Path $AzureCliExtensionPath

[Environment]::SetEnvironmentVariable("AZURE_EXTENSION_DIR", $AzureCliExtensionPath, [System.EnvironmentVariableTarget]::Machine)
$Env:AZURE_EXTENSION_DIR = $AzureCliExtensionPath