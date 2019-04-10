################################################################################
##  File:  Download-ToolCache.ps1
##  Team:  CI-Build
##  Desc:  Download tool cache
##  From:  https://raw.githubusercontent.com/Microsoft/azure-pipelines-image-generation/master/images/win/scripts/Installers/Download-ToolCache.ps1
################################################################################

$SourceUrl = "https://vstsagenttools.blob.core.windows.net/tools"

$Dest = "C:/"

$Path = "hostedtoolcache/windows"

$env:Path = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy;" + $env:Path

Write-Host "Started AzCopy from $SourceUrl to $Dest"

AzCopy /Source:$SourceUrl /Dest:$Dest  /S /V /Pattern:$Path

$ToolsDirectory = $Dest + $Path

$current = Get-Location
Set-Location -Path $ToolsDirectory

Get-ChildItem -Recurse -Depth 4 -Filter install_to_tools_cache.bat | ForEach-Object {
    Write-Host $_.DirectoryName
    Set-Location -Path $_.DirectoryName
    Get-Location | Write-Host
    if (Test-Path 'tool.zip')
    {
        Expand-Archive 'tool.zip' -DestinationPath '.'
    }
    cmd.exe /c 'install_to_tools_cache.bat'
}
Set-Location -Path $current

setx AGENT_TOOLSDIRECTORY $ToolsDirectory /M