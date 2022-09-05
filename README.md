# friendly-chainsaw-docker

This is docker images that I use to build/test my [friendly-chainsaw](https://github.com/brandonmcclure/friendly-chainsaw) powershell modules

## How to use

With a script module directory like:
```
-MyModule
--public
----Get-Foo.ps1
--MyModule.psm1
--MyModule.psd1
-Module2
--public
----Invoke-Bar.ps1
--Module2.psm1
--Module2.psd1
```

From one level above the `MyModule` directory, we are going to run a container and bind mount to the `/build` path on the container to our local current directory (`${pwd}`).

run the following to build all the modules in the individuals folders:
`docker run --rm -it -w /build -v $${PWD}:/build bmcclure89/fc_pwsh_build -Verbose -moduleAuthor "Brandon McClure"`

to build a single module:
`docker run --rm -it -w /build -v $${PWD}:/build bmcclure89/fc_pwsh_build -moduleName @('MyModule.psm1') -Verbose -moduleAuthor "Brandon McClure"`

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/brandonmcclure/friendly-chainsaw-docker/blob/main/readme.md)