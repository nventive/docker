param (
 [int][Parameter(Mandatory)]$MajorVersion,
 [switch]$PushImage = $false,
 [string]$DockerTagPrefix = ""
)
$ErrorActionPreference = "Stop"
$SupportedVersions = 15,16

if(!($SupportedVersions -contains $MajorVersion)) {
    Write-Host "Version $MajorVersion of Visual Studio is currently not supported" 
    return
}

$Dockerfile = ""

if($MajorVersion -eq 15) {
    $Dockerfile = "vs15_enterprise.dockerfile"
} elseif ($MajorVersion -eq 16) {
    $Dockerfile = "vs16_enterprise.dockerfile"
}

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
        $ImageTag = 'vs' + $VisualStudioVersion;
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

    if($PushImage -And ![string]::IsNullOrWhiteSpace($DockerTagPrefix)) {
        $FullTag = $DockerTagPrefix + ':' + $ImageTag;
        #Tag the image
        docker tag $ImageTag $FullTag
        #Push the image to Docker Hub
        docker push $FullTag
    }
}
