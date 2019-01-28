#Visual Studio
$fullVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property installationVersion
$shortVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property catalog_productDisplayVersion

SETX VisualStudio_FullVersion $($fullVersion) /M
SETX VisualStudio_Version $($shortVersion) /M

#Android
SETX AndroidSdkDirectory $env:ANDROID_HOME /M
SETX AndroidNdkDirectory $env:ANDROID_NDK_HOME /M