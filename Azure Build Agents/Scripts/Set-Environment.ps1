#Visual Studio
if($env:PREVIEW) {
    $fullVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property installationVersion -prerelease
    $shortVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property catalog_productSemanticVersion -prerelease
} else {
    $fullVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property installationVersion
    $shortVersion = & 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe' -property catalog_productSemanticVersion
}

SETX VisualStudio_FullVersion $($fullVersion) /M
SETX VisualStudio_Version $($shortVersion.Split('+')[0]) /M

#Android
SETX AndroidSdkDirectory $env:ANDROID_HOME /M
SETX AndroidNdkDirectory $env:ANDROID_NDK_HOME /M