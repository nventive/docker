FROM mcr.microsoft.com/dotnet/core/sdk:2.2.105-bionic
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update

# Install mono, msbuild and dependencies
RUN apt-get -y install sudo unzip python mono-devel msbuild libc6 ninja-build

# Setup for GitVersion 4.x 
RUN sudo apt-get install -y libgit2-dev libgit2-26 && \
ln -s /usr/lib/x86_64-linux-gnu/libgit2.so /lib/x86_64-linux-gnu/libgit2-15e1193.so

# Install node and puppeteer dependencies
RUN curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - && \
	sudo apt install -y nodejs gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
	libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
	libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
	libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
	libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

# Install and activate emscripten
RUN git clone https://github.com/juj/emsdk.git && \
	sudo chmod 777 /emsdk && \
    cd emsdk && \
    ./emsdk install sdk-1.38.28-64bit && \
    ./emsdk install sdk-1.38.30-64bit && \
    ./emsdk install sdk-1.38.31-64bit && \
    ./emsdk install sdk-1.38.34-64bit && \
    ./emsdk install latest && \
    ./emsdk activate sdk-1.38.31-64bit && \
    sudo chmod -R 777 /emsdk
