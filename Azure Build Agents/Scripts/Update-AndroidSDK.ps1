################################################################################
##  File:  Update-AndroidSDK.ps1
##  Team:  CI-X
##  Desc:  Install and update Android SDK and tools
##  From:  https://raw.githubusercontent.com/Microsoft/azure-pipelines-image-generation/b28be9b3f9d4c9bca3bd54472eaccaffa9beff17/images/win/scripts/Installers/Update-AndroidSDK.ps1
################################################################################

function Add-ContentToMarkdown {
    [CmdletBinding()]
    param(
        $Content = ""
    )

    Add-Content 'C:\InstalledSoftware.md' $Content
}


function Add-SoftwareDetailsToMarkdown {
    [CmdletBinding()]
    param(
        $SoftwareName = "",
        $DescriptionMarkdown = ""
    )

$Content = @"

## $SoftwareName

$DescriptionMarkdown
"@
   Add-ContentToMarkdown -Content $Content
}


# Get the latest command line tools so we can accept all of the licenses.  Alternatively we could just upload them.
# https://developer.android.com/studio/index.html
Invoke-WebRequest -UseBasicParsing -Uri "https://dl.google.com/android/repository/sdk-tools-windows-3859397.zip" -OutFile android-sdk-tools.zip

# Don't replace the one that VS installs as it seems to break things.
Expand-Archive -Path android-sdk-tools.zip -DestinationPath android-sdk -Force

Remove-Item -Path android-sdk-tools.zip

$sdk = Get-Item -Path .\android-sdk

# Accept the standard licenses.  There does not appear to be an easy way to do this
# so we are base64 encoding a zip of the lincenses directory from another installation
$base64Content = "UEsDBBQAAAAAAKJeN06amkPzKgAAACoAAAAhAAAAbGljZW5zZXMvYW5kcm9pZC1nb29nbGV0di1saWNlbnNlDQpmYzk0NmU4ZjIzMWYzZTMxNTliZjBiN2M2NTVjOTI0Y2IyZTM4MzMwUEsDBBQAAAAIAKBrN05E+YSqQwAAAFQAAAAcAAAAbGljZW5zZXMvYW5kcm9pZC1zZGstbGljZW5zZQXByREAIQgEwP9WmYsjhxgOKJN/CNs9vmdOQ2zdRw2dxQnWjqQ/3oIgXQM9vqUiwkiX8ljWea4ZlCF3xTo1pz6w+wdQSwMEFAAAAAAAxV43TpECY7AqAAAAKgAAACQAAABsaWNlbnNlcy9hbmRyb2lkLXNkay1wcmV2aWV3LWxpY2Vuc2UNCjUwNDY2N2Y0YzBkZTdhZjFhMDZkZTlmNGIxNzI3Yjg0MzUxZjI5MTBQSwMEFAAAAAAAzF43TpOr0CgqAAAAKgAAABsAAABsaWNlbnNlcy9nb29nbGUtZ2RrLWxpY2Vuc2UNCjMzYjZhMmI2NDYwN2YxMWI3NTlmMzIwZWY5ZGZmNGFlNWM0N2Q5N2FQSwMEFAAAAAAAz143TqxN4xEqAAAAKgAAACQAAABsaWNlbnNlcy9pbnRlbC1hbmRyb2lkLWV4dHJhLWxpY2Vuc2UNCmQ5NzVmNzUxNjk4YTc3YjY2MmYxMjU0ZGRiZWVkMzkwMWU5NzZmNWFQSwMEFAAAAAAA0l43Tu2ee/8qAAAAKgAAACYAAABsaWNlbnNlcy9taXBzLWFuZHJvaWQtc3lzaW1hZ2UtbGljZW5zZQ0KNjNkNzAzZjU2OTJmZDg5MWQ1YWNhY2ZiZDhlMDlmNDBmYzk3NjEwNVBLAQIUABQAAAAAAKJeN06amkPzKgAAACoAAAAhAAAAAAAAAAEAIAAAAAAAAABsaWNlbnNlcy9hbmRyb2lkLWdvb2dsZXR2LWxpY2Vuc2VQSwECFAAUAAAACACgazdORPmEqkMAAABUAAAAHAAAAAAAAAABACAAAABpAAAAbGljZW5zZXMvYW5kcm9pZC1zZGstbGljZW5zZVBLAQIUABQAAAAAAMVeN06RAmOwKgAAACoAAAAkAAAAAAAAAAEAIAAAAOYAAABsaWNlbnNlcy9hbmRyb2lkLXNkay1wcmV2aWV3LWxpY2Vuc2VQSwECFAAUAAAAAADMXjdOk6vQKCoAAAAqAAAAGwAAAAAAAAABACAAAABSAQAAbGljZW5zZXMvZ29vZ2xlLWdkay1saWNlbnNlUEsBAhQAFAAAAAAAz143TqxN4xEqAAAAKgAAACQAAAAAAAAAAQAgAAAAtQEAAGxpY2Vuc2VzL2ludGVsLWFuZHJvaWQtZXh0cmEtbGljZW5zZVBLAQIUABQAAAAAANJeN07tnnv/KgAAACoAAAAmAAAAAAAAAAEAIAAAACECAABsaWNlbnNlcy9taXBzLWFuZHJvaWQtc3lzaW1hZ2UtbGljZW5zZVBLBQYAAAAABgAGANoBAACPAgAAAAA="
$content = [System.Convert]::FromBase64String($base64Content)
Set-Content -Path .\android-sdk-licenses.zip -Value $content -Encoding Byte
Expand-Archive -Path .\android-sdk-licenses.zip -DestinationPath 'C:\Android\android-sdk\' -Force
Remove-Item -Path .\android-sdk-licenses.zip

# run the updates.
# keep newer versions in descending order

$sdk_root = "C:\Android\android-sdk"

#NDK is installed by VS
$ndk_root = "C:\Microsoft\AndroidNDK64\"

if(Test-Path $ndk_root){

    $androidNDKs = Get-ChildItem -Path $ndk_root | Sort-Object -Property Name -Descending | Select-Object -First 1
    $latestAndroidNDK = $androidNDKs.FullName;

    setx ANDROID_HOME $sdk_root /M
    setx ANDROID_NDK_HOME $latestAndroidNDK /M
    setx ANDROID_NDK_PATH $latestAndroidNDK /M
}
else {
    Write-Host "NDK is not installed at path $ndk_root"
    exit 1
}


Push-Location -Path $sdk.FullName

& '.\tools\bin\sdkmanager.bat' --sdk_root=$sdk_root `
    "platform-tools" `
    "platforms;android-28" `
    "platforms;android-27" `
    "platforms;android-26" `
    "platforms;android-25" `
    "platforms;android-24" `
    "platforms;android-23" `
    "platforms;android-22" `
    "platforms;android-21" `
    "platforms;android-19" `
    "platforms;android-17" `
    "platforms;android-15" `
    "platforms;android-10" `
    "build-tools;28.0.0" `
    "build-tools;27.0.3" `
    "build-tools;27.0.1" `
    "build-tools;26.0.3" `
    "build-tools;26.0.1" `
    "build-tools;25.0.3" `
    "build-tools;24.0.3" `
    "build-tools;23.0.3" `
    "build-tools;23.0.1" `
    "build-tools;22.0.1" `
    "build-tools;21.1.2" `
    "build-tools;19.1.0" `
    "build-tools;17.0.0" `
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
    "patcher;v4"

Pop-Location



# Adding description of the software to Markdown
$Header = @"

## Android SDK Build Tools

"@

Add-ContentToMarkdown -Content $Header

$BuildTools =(Get-ChildItem "C:\Android\android-sdk\build-tools\") `
           | Where { $_.Name -match "[0-9].*" } `
           | Sort-Object -Descending `
           | % { "#### $($_.Name)`n`n_Location:_ $($_.FullName)`n" }

Add-ContentToMarkdown -Content $BuildTools


# Adding description of the software to Markdown
$Header = @"

## Android SDK Platforms

"@

Add-ContentToMarkdown -Content $Header

$SdkList =(Get-ChildItem "C:\Android\android-sdk\platforms\") | Sort-Object -Descending | %{ $_.FullName }

foreach($sdk in $SdkList)
{
    $sdkProps = ConvertFrom-StringData (Get-Content "$sdk\source.properties" -Raw)

    $content = @"
#### $($sdkProps.'Platform.Version') (API $($sdkProps.'AndroidVersion.ApiLevel'))

_Location:_ $sdk

"@
    Add-ContentToMarkdown -Content $content
}