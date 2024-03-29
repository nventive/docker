################################################################################
##  File:  Update-AndroidSDK.ps1
##  Desc:  Install and update Android SDK and tools
##  From:  https://raw.githubusercontent.com/actions/virtual-environments/win19/20200319.1/images/win/scripts/Installers/Update-AndroidSDK.ps1
################################################################################

# Download the latest command line tools so that we can accept all of the licenses.
# See https://developer.android.com/studio/#command-tools
Invoke-WebRequest -UseBasicParsing -Uri "https://dl.google.com/android/repository/commandlinetools-win-8092744_latest.zip" -OutFile $env:TEMP\android-sdk-tools.zip

# Don't replace the one that VS installs as it seems to break things.
Expand-Archive -Path $env:TEMP\android-sdk-tools.zip -DestinationPath android-sdk -Force

$sdk = Get-Item -Path .\android-sdk

# Install the standard Android SDK licenses. In the past, there wasn't a better way to do this,
# so we are base64-encoding a zip of the licenses directory from another installation.
# To create this base64 string, create a zip file that contains nothing but a 'licenses' folder,
# which folder contains the accepted license files found in 'C:\Program Files (x86)\Android\android-sdk\licenses'.
# Then, run this in PowerShell:
#     $LicensesZipFileName = 'C:\Program Files (x86)\Android\android-sdk\Licenses.zip'
#     $base64Content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($LicensesZipFileName))
#     echo $base64Content
#
# Future: see if the base64 technique can be avoided by running this PowerShell script to accept all licenses.
# This fails when run on a live agent, likely because non-interactive mode is set.
# It may work fine during image generation (this script).
#     for($i=0; $i -lt 100; $i++) { $response += "y`n"}; $response | .\sdkmanager.bat --licenses
$base64Content = "UEsDBBQAAAAAAKJeN06amkPzKgAAACoAAAAhAAAAbGljZW5zZXMvYW5kcm9pZC1nb29nbGV0di1saWNlbnNlDQpmYzk0NmU4ZjIzMWYzZTMxNTliZjBiN2M2NTVjOTI0Y2IyZTM4MzMwUEsDBBQAAAAIAKBrN05E+YSqQwAAAFQAAAAcAAAAbGljZW5zZXMvYW5kcm9pZC1zZGstbGljZW5zZQXByREAIQgEwP9WmYsjhxgOKJN/CNs9vmdOQ2zdRw2dxQnWjqQ/3oIgXQM9vqUiwkiX8ljWea4ZlCF3xTo1pz6w+wdQSwMEFAAAAAAAxV43TpECY7AqAAAAKgAAACQAAABsaWNlbnNlcy9hbmRyb2lkLXNkay1wcmV2aWV3LWxpY2Vuc2UNCjUwNDY2N2Y0YzBkZTdhZjFhMDZkZTlmNGIxNzI3Yjg0MzUxZjI5MTBQSwMEFAAAAAAAzF43TpOr0CgqAAAAKgAAABsAAABsaWNlbnNlcy9nb29nbGUtZ2RrLWxpY2Vuc2UNCjMzYjZhMmI2NDYwN2YxMWI3NTlmMzIwZWY5ZGZmNGFlNWM0N2Q5N2FQSwMEFAAAAAAAz143TqxN4xEqAAAAKgAAACQAAABsaWNlbnNlcy9pbnRlbC1hbmRyb2lkLWV4dHJhLWxpY2Vuc2UNCmQ5NzVmNzUxNjk4YTc3YjY2MmYxMjU0ZGRiZWVkMzkwMWU5NzZmNWFQSwMEFAAAAAAA0l43Tu2ee/8qAAAAKgAAACYAAABsaWNlbnNlcy9taXBzLWFuZHJvaWQtc3lzaW1hZ2UtbGljZW5zZQ0KNjNkNzAzZjU2OTJmZDg5MWQ1YWNhY2ZiZDhlMDlmNDBmYzk3NjEwNVBLAQIUABQAAAAAAKJeN06amkPzKgAAACoAAAAhAAAAAAAAAAEAIAAAAAAAAABsaWNlbnNlcy9hbmRyb2lkLWdvb2dsZXR2LWxpY2Vuc2VQSwECFAAUAAAACACgazdORPmEqkMAAABUAAAAHAAAAAAAAAABACAAAABpAAAAbGljZW5zZXMvYW5kcm9pZC1zZGstbGljZW5zZVBLAQIUABQAAAAAAMVeN06RAmOwKgAAACoAAAAkAAAAAAAAAAEAIAAAAOYAAABsaWNlbnNlcy9hbmRyb2lkLXNkay1wcmV2aWV3LWxpY2Vuc2VQSwECFAAUAAAAAADMXjdOk6vQKCoAAAAqAAAAGwAAAAAAAAABACAAAABSAQAAbGljZW5zZXMvZ29vZ2xlLWdkay1saWNlbnNlUEsBAhQAFAAAAAAAz143TqxN4xEqAAAAKgAAACQAAAAAAAAAAQAgAAAAtQEAAGxpY2Vuc2VzL2ludGVsLWFuZHJvaWQtZXh0cmEtbGljZW5zZVBLAQIUABQAAAAAANJeN07tnnv/KgAAACoAAAAmAAAAAAAAAAEAIAAAACECAABsaWNlbnNlcy9taXBzLWFuZHJvaWQtc3lzaW1hZ2UtbGljZW5zZVBLBQYAAAAABgAGANoBAACPAgAAAAA="
$content = [System.Convert]::FromBase64String($base64Content)
Set-Content -Path $env:TEMP\android-sdk-licenses.zip -Value $content -Encoding Byte
Expand-Archive -Path $env:TEMP\android-sdk-licenses.zip -DestinationPath 'C:\android-sdk' -Force


# run the updates.
# keep newer versions in descending order

$sdk_root = "C:\android-sdk"

# The NDK is installed by Visual Studio at this location:
# $ndk_root = "C:\Microsoft\AndroidNDK64\"

# if(Test-Path $ndk_root){

#     $androidNDKs = Get-ChildItem -Path $ndk_root | Sort-Object -Property Name -Descending | Select-Object -First 1
#     $latestAndroidNDK = $androidNDKs.FullName;

#     setx ANDROID_HOME $sdk_root /M
#     setx ANDROID_NDK_HOME $latestAndroidNDK /M
#     setx ANDROID_NDK_PATH $latestAndroidNDK /M
# }
# else {
#     Write-Host "NDK is not installed at path $ndk_root"
#     exit 1
# }


Push-Location -Path $sdk.FullName

& '.\cmdline-tools\bin\sdkmanager.bat' --sdk_root=$sdk_root `
    "platform-tools" `
    "platforms;android-31" `
    "platforms;android-30" `
    "platforms;android-29" `
    "platforms;android-28" `
    "build-tools;31.0.0" `
    "build-tools;30.0.3" `
    "build-tools;29.0.3" `
    "build-tools;28.0.3" `
    "extras;android;m2repository" `
    "extras;google;m2repository" `
    "extras;google;google_play_services" `
    "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" `
    "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.1" `
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" `
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" `
    "add-ons;addon-google_apis-google-24" `
    "add-ons;addon-google_apis-google-23" `
    "add-ons;addon-google_apis-google-22" `
    "add-ons;addon-google_apis-google-21" `
    "cmake;3.6.4111459" `
    "cmake;3.10.2.4988404" `
    "patcher;v4" `
    "ndk-bundle" `
    "ndk;21.3.6528147"

Pop-Location

# The NDK is installed by the SDK manager at this location
$ndk_root = "C:\android-sdk\ndk-bundle\"

if(Test-Path $ndk_root){
     setx ANDROID_HOME $sdk_root /M
     setx ANDROID_NDK_HOME $ndk_root /M
     setx ANDROID_NDK_PATH $ndk_root /M
}
else {
    Write-Host "NDK is not installed at path $ndk_root"
    exit 1
}


# Adding description of the software to Markdown
$Header = @"

## Android SDK Build Tools

"@

Add-ContentToMarkdown -Content $Header

$BuildTools =(Get-ChildItem "C:\android-sdk\build-tools\") `
           | Where { $_.Name -match "[0-9].*" } `
           | Sort-Object -Descending `
           | % { "#### $($_.Name)`n`n_Location:_ $($_.FullName)`n" }

Add-ContentToMarkdown -Content $BuildTools


# Adding description of the software to Markdown
$Header = @"

## Android SDK Platforms

"@

Add-ContentToMarkdown -Content $Header

$SdkList =(Get-ChildItem "C:\android-sdk\platforms\") | Sort-Object -Descending | %{ $_.FullName }

foreach($sdk in $SdkList)
{
    $sdkProps = ConvertFrom-StringData (Get-Content "$sdk\source.properties" -Raw)

    $content = @"
#### $($sdkProps.'Platform.Version') (API $($sdkProps.'AndroidVersion.ApiLevel'))

_Location:_ $sdk

"@
    Add-ContentToMarkdown -Content $content
}
