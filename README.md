# docker
A repository containing the definition for various Docker images.


## Azure Build Agents
To build the vs15_enterprise image, simply run the following command in the Azure Build Agents directory:
```
docker build -m 4G -f vs15_enterprise.dockerfile .
```