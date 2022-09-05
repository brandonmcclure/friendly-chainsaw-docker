FROM mcr.microsoft.com/powershell:lts-ubuntu-18.04

LABEL maintainer="Brandon McClure (brandonmcclure89@gmail.com)"

# Install Dotnet core, needed for nuget
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
RUN apt-get update --yes  \
&& apt-get install -y wget --no-install-recommends \
&& wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb \
&& apt-get update --yes \
&& apt-get install -y apt-transport-https --no-install-recommends \
&& apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update --yes \
  && apt-get install -y dotnet-sdk-5.0 --no-install-recommends \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN DEBIAN_FRONTEND=noninteractive apt install nuget -y

RUN ["pwsh", "-c", "Install-Module PSScriptAnalyzer,PSHTMLTable -Force"]
WORKDIR /app
COPY build-module.ps1 /app/build-module.ps1 
COPY BuildFunctions.ps1 /app/BuildFunctions.ps1 

VOLUME "/build"
ENTRYPOINT ["pwsh","-c", "/app/build-module.ps1"]