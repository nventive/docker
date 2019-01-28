################################################################################
##  File:  Install-Git.ps1
##  Team:  CI-Platform
##  Desc:  Install Git for Windows
##  From: https://raw.githubusercontent.com/Microsoft/azure-pipelines-image-generation/18a5015449355275c160f46d3861398efbd4de88/images/win/scripts/Installers/Install-Git.ps1
################################################################################

Import-Module -Name ImageHelpers

# Install the latest version of Git which is bundled with Git LFS.
# See https://chocolatey.org/packages/git
choco install git -y --package-parameters= "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration"

Add-MachinePathItem "C:\Program Files\Git\mingw64\bin"
Add-MachinePathItem "C:\Program Files\Git\usr\bin"
Add-MachinePathItem "C:\Program Files\Git\bin"
exit 0