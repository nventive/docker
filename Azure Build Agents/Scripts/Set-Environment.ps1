#Visual Studio
if($env:BUILD_TOOLS)
{
    if($env:PREVIEW) {
        $fullVersion = vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -property installationVersion -prerelease
        $shortVersion = vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -property catalog_productSemanticVersion -prerelease
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $($(vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -prerelease -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1 | Get-Item).Directory.FullName), [System.EnvironmentVariableTarget]::Machine)

    } else {
        $fullVersion = vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -property installationVersion
        $shortVersion = vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -property catalog_productSemanticVersion
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $($(vswhere -products 'Microsoft.VisualStudio.Product.BuildTools' -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1 | Get-Item).Directory.FullName), [System.EnvironmentVariableTarget]::Machine)
    }
}
else {
    if($env:PREVIEW) {
        $fullVersion = vswhere -property installationVersion -prerelease
        $shortVersion = vswhere -property catalog_productSemanticVersion -prerelease
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $($(vswhere -prerelease -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1 | Get-Item).Directory.FullName), [System.EnvironmentVariableTarget]::Machine)

    } else {
        $fullVersion = vswhere -property installationVersion
        $shortVersion = vswhere -property catalog_productSemanticVersion
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $($(vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1 | Get-Item).Directory.FullName), [System.EnvironmentVariableTarget]::Machine)
    }    
}

SETX VisualStudio_FullVersion $($fullVersion) /M
SETX VisualStudio_Version $($shortVersion.Split('+')[0]) /M

#Android
SETX AndroidSdkDirectory $env:ANDROID_HOME /M
SETX AndroidNdkDirectory $env:ANDROID_NDK_HOME /M