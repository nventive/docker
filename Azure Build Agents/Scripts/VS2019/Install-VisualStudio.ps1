################################################################################
##  File:  Install-VS2019.ps1
##  Team:  CI-Build
##  Desc:  Install Visual Studio 2019
##  From: https://raw.githubusercontent.com/microsoft/azure-pipelines-image-generation/master/images/win/scripts/Installers/Vs2019/Install-VS2019.ps1
################################################################################
$ErrorActionPreference = "Stop"

Function InstallVS
{
  Param
  (
    [String]$WorkLoads,
    [String]$Sku,
    [String]$VSBootstrapperURL,
    [String]$InstallationPath
  )

  $exitCode = -1

  try
  {
    Write-Host "Enable short name support on Windows needed for Xamarin Android AOT, defaults appear to have been changed in Azure VMs"
    $shortNameEnableProcess = Start-Process -FilePath fsutil.exe -ArgumentList ('8dot3name', 'set', '0') -Wait -PassThru
    $shortNameEnableExitCode = $shortNameEnableProcess.ExitCode

    if ($shortNameEnableExitCode -ne 0)
    {
      Write-Host -Object 'Enabling short name support on Windows failed. This needs to be enabled prior to VS 2017 install for Xamarin Andriod AOT to work.'
      exit $shortNameEnableExitCode
    }

    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ('/c', $FilePath, $WorkLoads, '--quiet', '--norestart', '--wait', '--nocache', '--installPath', $InstallationPath )

    Write-Host "Starting Install ..."
    $process = Start-Process -FilePath cmd.exe -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010)
    {
      Write-Host -Object 'Installation successful'
      return $exitCode
    }
    else
    {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch
  {
    Write-Host -Object "Failed to install Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$InstallationPath = "C:\VisualStudio"

$WorkLoads = ' --includeOptional ' + `
             ' --includeRecommended ' + `
             ' --add Microsoft.VisualStudio.Workload.Azure ' + `
             ' --add Microsoft.VisualStudio.Workload.ManagedDesktop' + `
             ' --add Microsoft.VisualStudio.Workload.NetCoreTools' + `
             ' --add Microsoft.VisualStudio.Workload.NetCrossPlat ' + `
             ' --add Microsoft.VisualStudio.Workload.Node ' + `
             ' --add Microsoft.VisualStudio.Workload.Universal ' + `
             ' --add Microsoft.VisualStudio.Workload.VisualStudioExtension ' + `
             ' --add Microsoft.VisualStudio.Workload.NetWeb ' + `
             ' --add Microsoft.Net.Core.Component.SDK.2.1' + `
             ' --add Microsoft.Net.Core.Component.SDK.2.2'


#$ReleaseInPath = 'Enterprise'
$Sku = 'Enterprise'
$VSBootstrapperURL = 'https://aka.ms/vs/16/release/vs_Enterprise.exe'

if($env:PREVIEW) {
  $VSBootstrapperURL = 'https://aka.ms/vs/16/pre/vs_Enterprise.exe'
}

$ErrorActionPreference = 'Stop'

# Install VS
$exitCode = InstallVS -WorkLoads $WorkLoads -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL --Loc -InstallationPath $InstallationPath

# Find the version of VS installed for this instance
# Only supports a single instance
$vsProgramData = Get-Item -Path "C:\ProgramData\Microsoft\VisualStudio\Packages\_Instances"
$instanceFolders = Get-ChildItem -Path $vsProgramData.FullName

if($instanceFolders -is [array])
{
    Write-Host "More than one instance installed"
    exit 1
}

$catalogContent = Get-Content -Path ($instanceFolders.FullName + '\catalog.json')
$catalog = $catalogContent | ConvertFrom-Json
$version = $catalog.info.id
Write-Host "Visual Studio version" $version "installed"

# Initialize Visual Studio Experimental Instance
#&"$InstallationPath\Common7\IDE\devenv.exe" /RootSuffix Exp /ResetSettings General.vssettings /Command File.Exit | Wait-Process

# Updating content of MachineState.json file to disable autoupdate of VSIX extensions
#$newContent = '{"Extensions":[{"Key":"1e906ff5-9da8-4091-a299-5c253c55fdc9","Value":{"ShouldAutoUpdate":false}},{"Key":"Microsoft.VisualStudio.Web.AzureFunctions","Value":{"ShouldAutoUpdate":false}}],"ShouldAutoUpdate":false,"ShouldCheckForUpdates":false}'
#Set-Content -Path "$InstallationPathCommon7\IDE\Extensions\MachineState.json" -Value $newContent


# Adding description of the software to Markdown

$SoftwareName = "Visual Studio 2019 Enterprise"

$Description = @"
_Version:_ $version<br/>
_Location:_ $InstallationPath

The following workloads and components are installed with Visual Studio 2019:
"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description

$InstalledWorkloads = Get-ChildItem -Path C:\ProgramData\Microsoft\VisualStudio\Packages -Filter '*,version=*' | Sort-Object -Property Name | foreach {$_.Name}

# Adding explicitly added Workloads details to markdown by parsing $Workloads
Add-ContentToMarkdown -Content $InstalledWorkloads

exit 0