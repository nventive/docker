################################################################################
##  File:  Install-VS2017.ps1
##  Team:  CI-Build
##  Desc:  Install Visual Studio 2017
##  From:  https://raw.githubusercontent.com/Microsoft/azure-pipelines-image-generation/master/images/win/scripts/Installers/Vs2017/Install-VS2017.ps1
################################################################################

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
             ' --add Microsoft.VisualStudio.Workload.ManagedDesktop ' + `
             ' --add Microsoft.VisualStudio.Workload.Universal ' + `
             ' --add Microsoft.VisualStudio.Workload.NetCrossPlat ' + `
             ' --add Microsoft.VisualStudio.Workload.VisualStudioExtension ' + `
             ' --add Microsoft.VisualStudio.Workload.Node ' + `
             ' --add Microsoft.VisualStudio.Workload.NetCoreTools ' + `
             ' --add Microsoft.VisualStudio.Workload.Azure ' + `
             ' --add Component.Android.NDK.R15C ' + `
             ' --add Component.Android.SDK23 ' + `
             ' --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 ' + `
             ' --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 ' + `
             ' --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 '

$Sku = 'Enterprise'
$VSBootstrapperURL = 'https://aka.ms/vs/15/release/vs_enterprise.exe'

if($env:PREVIEW) {
  $VSBootstrapperURL = 'https://aka.ms/vs/15/pre/vs_Enterprise.exe'
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

# Adding description of the software to Markdown

$SoftwareName = "Visual Studio 2017 Enterprise"

$Description = @"
_Version:_ $version<br/>
_Location:_ $InstallationPath

The following workloads and components are installed with Visual Studio 2017:

"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description

$InstalledWorkloads = Get-ChildItem -Path C:\ProgramData\Microsoft\VisualStudio\Packages -Filter '*,version=*' | Sort-Object -Property Name | foreach {$_.Name}

# Adding explicitly added Workloads details to markdown by parsing $Workloads
Add-ContentToMarkdown -Content $InstalledWorkloads



exit $exitCode