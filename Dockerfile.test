FROM mcr.microsoft.com/powershell:lts-ubuntu-18.04

LABEL maintainer="Brandon McClure (brandonmcclure89@gmail.com)"

RUN ["pwsh", "-c", "Install-Module pester -Force"]
WORKDIR /tests

VOLUME "/tests"
CMD ["pwsh","-c", "Invoke-Pester -OutputFile /tests/PesterResults.xml -OutputFormat NUnitXml; "]