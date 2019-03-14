# escape=`

# Made thanks to the instructions found here https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2017

# Use the latest Windows Server Core 1809 image.
FROM mcr.microsoft.com/windows/servercore:1809

# Restore the default Windows shell for correct batch processing below.
SHELL ["cmd", "/S", "/C"]

# Copy configuration scripts.
COPY [ "ImageHelpers", "C:/Program Files/WindowsPowerShell/Modules/ImageHelpers/"]
COPY Scripts\ C:\TEMP\

RUN powershell -Command "C:\TEMP\Initialize-VM.ps1"
RUN powershell -Command "C:\TEMP\Install-Git.ps1"
RUN powershell -Command "C:\TEMP\Install-VS2017.ps1"

WORKDIR C:\TEMP

RUN powershell -Command ".\Install-JavaTools.ps1"
RUN powershell -Command ".\Update-AndroidSDK.ps1"
RUN powershell -Command ".\Set-Environment.ps1"
RUN powershell -Command ".\Download-Agent.ps1"

WORKDIR C:\

RUN powershell -Command "Remove-Item -Recurse -Force C:\TEMP"

COPY Scripts\Initialize-Agent.ps1 C:\agent\Initialize-Agent.ps1

#Start the agent initialization script
ENTRYPOINT powershell -NoLogo -ExecutionPolicy Bypass -File C:\agent\Initialize-Agent.ps1