# escape=`

# Made thanks to the instructions found here https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2017

# Use the latest Windows Server Core 1709 image.
FROM microsoft/windowsservercore:1709

# Restore the default Windows shell for correct batch processing below.
SHELL ["cmd", "/S", "/C"]

# Copy configuration scripts.
COPY [ "ImageHelpers", "C:/Program Files/WindowsPowerShell/Modules/ImageHelpers/"]
COPY Scripts\ C:\TEMP\

RUN powershell -Command "C:\TEMP\Initialize-VM.ps1"
RUN powershell -Command "C:\TEMP\Install-Git.ps1"

# Download the VS Enterpise bootstrapper.
ADD https://aka.ms/vs/15/release/vs_enterprise.exe C:\TEMP\vs.exe

# Install VS with necessary components.
RUN C:\TEMP\vs.exe --quiet --wait --norestart --nocache `
    --installPath C:\VisualStudio `
    --add Microsoft.VisualStudio.Workload.ManagedDesktop `
    --add Microsoft.VisualStudio.Workload.Universal `
    --add Microsoft.VisualStudio.Workload.NetCrossPlat `
    --add Microsoft.Net.Component.4.6.SDK --add Microsoft.Net.Component.4.6.TargetingPack `
    --add Microsoft.Net.Component.4.6.2.SDK --add Microsoft.Net.Component.4.6.2.TargetingPack `
    --add Microsoft.Net.Component.4.7.SDK --add Microsoft.Net.Component.4.7.TargetingPack `
    --add Microsoft.Net.Component.4.7.2.SDK --add Microsoft.Net.Component.4.7.2.TargetingPack `
    --add Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --add Microsoft.VisualStudio.ComponentGroup.Windows10SDK.16299 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.17134 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.17763 `
    --add Component.Android.SDK25 --add Component.Android.NDK.R15C `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

WORKDIR C:\TEMP

RUN powershell -Command ".\Install-JavaTools.ps1"
RUN powershell -Command ".\Update-AndroidSDK.ps1"
RUN powershell -Command ".\Set-Environment.ps1"
RUN powershell -Command ".\Download-Agent.ps1"

WORKDIR C:\

RUN powershell -Command "Remove-Item -Recurse -Force C:\TEMP"

COPY Scripts\Initialize-Agent.ps1 C:\agent\Initialize-Agent.ps1

#Start the agent initialization script
ENTRYPOINT powershell -NoLogo -ExecutionPolicy Bypass -File C:\agent\Initialize-Agent.ps1 & powershell&