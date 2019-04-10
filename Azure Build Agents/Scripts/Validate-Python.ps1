################################################################################
##  File:  Validate-Python.ps1
##  Team:  CI-X
##  Desc:  Configure python on path based on what is installed in the tools cache
##         Must run after tools cache is downloaded and validated
##  From:  https://github.com/Microsoft/azure-pipelines-image-generation/blob/master/images/win/scripts/Installers/Validate-Python.ps1
################################################################################

if(Get-Command -Name 'python')
{
    Write-Host "Python $(python --version) on path"
}
else
{
    Write-Host "Python is not on path"
    exit 1
}

$Python3Version = $(python --version)

if ($Python3Version -notlike "Python 3.*")
{
    Write-Error "Python 3 is not in the PATH"
}

$Python2Path = "C:\Python27amd64"
$env:Path = $Python2Path + ";" + $env:Path

$Python2Version = & $env:comspec "/s /c python --version 2>&1"

# Adding description of the software to Markdown
$SoftwareName = "Python (64 bit)"

$Description = @"
#### $Python3Version
_Environment:_
* PATH: contains location of python.exe

#### $Python2Version

_Location:_ $Python2Path
"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description