param (
 [int][Parameter(Mandatory)]$MajorVersion
)
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
    docker build -t $TemporaryImageTag -m 4G -f vs15_enterprise.dockerfile . 
    #Fire up a new container with the newly built image
    $TemporaryContainerId = docker run -m 2G -dt $TemporaryImageTag
    #Retrieve the version of VS
    $VisualStudioVersion = docker exec $TemporaryContainerId powershell -NoLogo "(Get-ChildItem Env:VisualStudio_Version).Value"
    #Tag the image
    docker tag $TemporaryImageTag nventive/build-agent:$VisualStudioVersion
    #Remove the temporary tag
    docker rmi $TemporaryImageTag
    #Stop the container to grad the markdown file inside of the image
    docker stop $TemporaryContainerId
    docker cp ${TemporaryContainerId}:'C:\InstalledSoftware.md' .\InstalledSoftware.md
    #Remove the temporary container
    docker rm $TemporaryContainerId
    #Push the image to Docker Hub
    docker push nventive/build-agent:$VisualStudioVersion
}
