# escape=`

# Made thanks to the instructions found here https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019

# Use the latest Windows Server Core 1809 image.
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019

# Copy configuration scripts.
COPY ["ImageHelpers", "C:/Program Files/WindowsPowerShell/Modules/ImageHelpers/"]
COPY Scripts\ C:\Scripts\

#Uncomment the following line to use the preview of VS
#RUN SETX PREVIEW True /M

#The following sequence has been extracted from https://github.com/Microsoft/azure-pipelines-image-generation/blob/master/images/win/vs2019-Server2019-Azure.json
RUN powershell -Command "C:\Scripts\VS2019\Initialize-VM.ps1"

RUN powershell -Command "C:\Scripts\VS2019\Install-VisualStudio.ps1"
RUN powershell -Command "C:\Scripts\Install-AzureCli.ps1"

RUN powershell -Command "C:\Scripts\Download-ToolCache.ps1"

RUN powershell -Command "C:\Scripts\VS2019\Install-Python.ps1"
RUN powershell -Command "C:\Scripts\Install-Git.ps1"
RUN powershell -Command "C:\Scripts\Install-NodeLts.ps1"
RUN powershell -Command "C:\Scripts\Install-JavaTools.ps1"

RUN powershell -Command "C:\Scripts\Update-AndroidSDK.ps1"

RUN powershell -Command "C:\Scripts\Validate-ToolCache.ps1"
RUN powershell -Command "C:\Scripts\Validate-Python.ps1"
RUN powershell -Command "C:\Scripts\Validate-Git.ps1"
RUN powershell -Command "C:\Scripts\Validate-NodeLts.ps1"
RUN powershell -Command "C:\Scripts\Validate-JavaTools.ps1"

RUN powershell -Command "C:\Scripts\Set-Environment.ps1"

RUN powershell -Command "C:\Scripts\Finalize-VM.ps1"

RUN powershell -Command "Remove-Item -Recurse -Force C:\Scripts"