# friendly-chainsaw-docker
This is docker images that I use to build/test my [friendly-chainsaw](https://github.com/brandonmcclure/friendly-chainsaw) powershell modules

## Example
With a script module directory like:
```
-MyModule
--public
----Invoke-MyFunction.ps1
--MyModule.psm1
--MyModule.psd1
```

From one level above the `MyModule` directory, run the following: 
`docker run --rm -it -w /build -v $${PWD}:/build bmcclure89/fc_pwsh_build -moduleName @('MyModule.psm1') -Verbose -moduleAuthor "Brandon McClure"`