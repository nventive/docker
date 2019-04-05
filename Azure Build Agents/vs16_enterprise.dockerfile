# escape=`

# Made thanks to the instructions found here https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019

# Use the latest Windows Server Core 1809 image.
FROM mcr.microsoft.com/windows/servercore:1809

# Copy configuration scripts.
COPY [ "ImageHelpers", "C:/Program Files/WindowsPowerShell/Modules/ImageHelpers/"]
COPY Scripts\ C:\TEMP\

RUN powershell -Command "C:\TEMP\Initialize-VM.ps1"
RUN powershell -Command "C:\TEMP\Install-NodeLts.ps1"
RUN powershell -Command "C:\TEMP\Install-Git.ps1"
RUN powershell -Command "C:\TEMP\Install-VS2019.ps1"

RUN powershell -Command "C:\TEMP\Install-JavaTools.ps1"
RUN powershell -Command "C:\TEMP\Update-AndroidSDK.ps1"
RUN powershell -Command "C:\TEMP\Set-Environment.ps1"

RUN powershell -Command "Remove-Item -Recurse -Force C:\TEMP"