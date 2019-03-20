FROM mcr.microsoft.com/dotnet/core/sdk:2.2.105-bionic
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update
RUN apt-get -y install sudo unzip python mono-devel msbuild libc6 ninja-build
RUN git clone https://github.com/juj/emsdk.git && \
	sudo chmod 777 /emsdk && \
    cd emsdk && \
    ./emsdk install sdk-1.38.28-64bit && \
    ./emsdk install latest && \
    ./emsdk activate sdk-1.38.28-64bit
