# docker
A repository containing the definition for various Docker images.


## Azure Build Agents
### Prerequisite
The images produced by the dockerfiles available here contain a full installation of Visual Studio, and thus require around 40G of disk space. 
To increase that limit, the docker configuration can be updated [as outlined here](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage#storage-limits)

### Build the image
To build an image, simply run the following command in the Azure Build Agents directory:
```powershell
# Visual Studio 2017
Build-VSImage.ps1 -MajorVersion 15
# Visual Studio 2019
Build-VSImage.ps1 -MajorVersion 16
# Visual Studio 2012
Build-VSImage.ps1 -MajorVersion 17
```
This script will build the image for the corresponding version of Visual Studio, log all the output in a Docker-{guid}.log file, tag the image with the corresponding version of VS (only `Major.Minor.Patch`; ie. `vs16.3.5`) and generate a Markdown file summarizing what has been installed on the image.

Additional options are available in this script:
- `PushImage`: indicates whether to attempt to push the image; must be used with `DockerTagPrefix`
- `DockerTagPrefix`: a prefix to apply to the image docker tag; must be used with `PushImage`

### Using the image
This image can be run using a simple `docker run` command.
```docker
docker run -m 4G -dt vs16.3.5
```
It is also compatible with [Azure Pipelines container jobs](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops&tabs=yaml). Given the size of the resulting image (between 40 and 50G), it is not advised to use with [Azure Pipelines agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops) as the pull of the image takes around 1 hour, which will cause a timeout. To use it, configure a [self-hosted agent](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops) and execute the pull command pre-emptively.
