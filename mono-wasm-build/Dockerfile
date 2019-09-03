FROM mcr.microsoft.com/dotnet/core/sdk:2.2.105-bionic
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list

# Install mono, msbuild and dependencies
RUN apt-get update; \
    apt-get -y install sudo unzip python msbuild libc6 ninja-build \
	curl libtool automake autoconf g++ cmake gcc-multilib g++-multilib lld \
	lib32ncurses5-dev nuget mono-devel ninja-build mingw-w64 python3-pip \
	python3-pip locales p7zip-full zip