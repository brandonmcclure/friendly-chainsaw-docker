FROM mcr.microsoft.com/powershell:lts-7.2-ubuntu-22.04

LABEL maintainer="Brandon McClure (brandonmcclure89@gmail.com)"

RUN ["pwsh", "-c", "Install-Module pester -Force"]
WORKDIR /tests

VOLUME "/tests"
CMD ["pwsh","-c", "Invoke-Pester -OutputFile /tests/PesterResults.xml -OutputFormat NUnitXml; "]