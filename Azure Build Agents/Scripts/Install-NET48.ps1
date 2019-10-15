################################################################################
##  File:  Install-NET48.ps1
##  Team:  CI-Build
##  Desc:  Install .NET 4.8
##  From:  https://github.com/microsoft/azure-pipelines-image-generation/blob/c98bbdd4492d2dd21d4a0ec1993c2e79abcc4218/images/win/scripts/Installers/Install-NET48.ps1
################################################################################

Import-Module -Name ImageHelpers -Force

# .NET 4.8 Dev pack
$InstallerURI = "https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c8c829444416e811be84c5765ede6148/NDP48-DevPack-ENU.exe"
$InstallerName = "NDP48-DevPack-ENU.exe"
$ArgumentList = ('Setup', '/passive', '/norestart' )

Install-EXE -Url $InstallerURI -Name $InstallerName -ArgumentList $ArgumentListdo