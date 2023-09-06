FROM mcr.microsoft.com/powershell:lts-7.2-ubuntu-22.04

LABEL maintainer="Brandon McClure (brandonmcclure89@gmail.com)"

# Install Dotnet core, needed for nuget
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
RUN apt-get update --yes \
  && apt-get install -y dotnet-sdk-7.0 --no-install-recommends \
  && apt-get install nuget -y --no-install-recommends \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ["pwsh", "-c", "Install-Module PSScriptAnalyzer,PSHTMLTable -Force"]
WORKDIR /app
COPY build-module.ps1 /app/build-module.ps1 
COPY BuildFunctions.ps1 /app/BuildFunctions.ps1 

VOLUME "/build"
ENTRYPOINT ["pwsh","-c", "/app/build-module.ps1"]