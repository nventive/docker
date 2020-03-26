################################################################################
##  File:  Install-Git.ps1
##  Desc:  Install Git for Windows
##  From:  https://raw.githubusercontent.com/actions/virtual-environments/win19/20200319.1/images/win/scripts/Installers/Install-Git.ps1
################################################################################

Import-Module -Name ImageHelpers

# Install the latest version of Git which is bundled with Git LFS.
# See https://chocolatey.org/packages/git
choco install git -y --package-parameters="/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration"
choco install hub

# Disable GCM machine-wide
[Environment]::SetEnvironmentVariable("GCM_INTERACTIVE", "Never", [System.EnvironmentVariableTarget]::Machine)

Add-MachinePathItem "C:\Program Files\Git\bin"

exit 0