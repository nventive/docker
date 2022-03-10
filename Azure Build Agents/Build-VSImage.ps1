param (
 [int][Parameter(Mandatory)]$MajorVersion,
 [string][Parameter(Mandatory)]$Edition,
 [switch]$PushImage = $false,
 [string]$DockerTagPrefix = ""
)
$ErrorActionPreference = "Stop"
$SupportedVersions = 15,16,17
$SupportedEditions = "Enterprise", "BuildTools"

if(!($SupportedVersions -contains $MajorVersion)) {
    Write-Host "Version $MajorVersion of Visual Studio is currently not supported" 
    return
}

if(!($SupportedEditions -contains $Edition)) {
    Write-Host "$Edition edition of Visual Studio is currently not supported" 
    return
}

$Dockerfile = "vs$MajorVersion"+"_$Edition.dockerfile"

if(![String]::IsNullOrEmpty($Dockerfile)) {
    $TemporaryImageTag = New-Guid
    $ImageTag = $TemporaryImageTag

    #Build the image and log the output to a file
    docker build -t $TemporaryImageTag -m 4G -f $Dockerfile . --isolation=hyperv | Tee-Object -FilePath Docker-$TemporaryImageTag.log

    #Fire up a new container with the newly built image
    $TemporaryContainerId = docker run -m 2G -dt --isolation=hyperv $TemporaryImageTag

    #Retrieve the version of VS
    $VisualStudioVersion = docker exec $TemporaryContainerId powershell -NoLogo "(Get-ChildItem Env:VisualStudio_Version).Value"

    if(![string]::IsNullOrEmpty($VisualStudioVersion)) {
        $ImageTag = $VisualStudioVersion;
        #Tag the image
        docker tag $TemporaryImageTag $ImageTag
        #Remove the temporary tag
        docker rmi $TemporaryImageTag
    }

    #Stop the container to grad the markdown file inside of the image
    docker stop $TemporaryContainerId
    docker cp ${TemporaryContainerId}:'C:\InstalledSoftware.md' .\InstalledSoftware-$ImageTag.md

    #Remove the temporary container
    docker rm $TemporaryContainerId

    if(![string]::IsNullOrWhiteSpace($DockerTagPrefix)) {
        $FullTag = $DockerTagPrefix + ':' + $ImageTag;
        #Tag the image
        docker tag $ImageTag $FullTag

        if($PushImage) {
            #Push the image to Docker Hub
            docker push $FullTag
        }
    }
}
