[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[parameter(Mandatory = $false)][string[]] $moduleName = @()
	,[string]$pathToSearch = (Split-Path $PSCommandPath -Parent)
	, [switch] $forceConfigUpdate = $true
	, [switch] $skipScriptAnalyzer = $true
)

function ManageModule($moduleName) {
	if (Get-Module -ListAvailable -Name $moduleName) {
		Import-Module $moduleName -ErrorAction Stop
	} 
	else {
		Install-Module $moduleName -Force -Verbose -Scope CurrentUser
		Import-Module $moduleName -ErrorAction Stop
	}
}

ManageModule 'BuildHelpers'
ManageModule 'PSScriptAnalyzer'
. $PSScriptRoot/BuildFunctions.ps1
$origLocation = Get-Location

try {
	if ([string]::IsNullOrEmpty($moduleName)) {
		$modules = Get-ChildItem -Path $pathToSearch  -Recurse | Where-Object { $_.Extension -eq '.psm1' }
	}
	else {
		$modules = Get-ChildItem -Path $pathToSearch  -Recurse | Where-Object { $_.Extension -eq '.psm1' -and $_.Name -in $moduleName }
	}
	foreach ($module in $modules) {
		$ModuleName = $module.BaseName 
		$modulePath = $module.FullName
		$moduleDir = Split-Path $module.FullName -Parent
		Write-Verbose "moduleDir: $moduleDir"
		$ManifestPath = "$moduleDir\$moduleName.psd1"
		Write-Verbose "ManifestPath: $ManifestPath"
		$ManifestConfigPath = "$moduleDir\moduleManifest.json"
		Write-Verbose "ManifestConfigPath: $ManifestConfigPath"
		$updateManifestFromConfig = 0
        
		Write-Output "Checking the $ModuleName module"
		Write-Output "At: $modulePath"
		Remove-Module $ModuleName -ErrorAction Ignore
        
		Write-Output "Does a module manifest exist?"
		If (!(Test-Path $ManifestPath)) {
			Write-Output "Manifest does not exist, does a configuration exist?"
			If (!(Test-Path $ManifestConfigPath)) {
				Write-Output "Manifest config does not exist, skipping"
				break
			}

			$updateManifestFromConfig = 1
		}

		if ($updateManifestFromConfig -eq 1 -or $forceConfigUpdate) {
			if ($forceConfigUpdate) {
				Write-Output "Forcibly updating the manifest from the config if it exists"
			}
			If (!(Test-Path $ManifestConfigPath)) {
				Write-Output "Manifest config does not exist, skipping"
			}
			else {
				Update-ManifestFromConfig -ManifestConfigPath $ManifestConfigPath -ManifestPath $ManifestPath -moduleName $moduleName
			}
		}

		Remove-Module $moduleName -Force -ErrorAction Ignore
		Import-Module $modulePath -Force -ErrorAction Stop
		Get-Module $moduleName | Format-List
		$commandList = Get-Command -Module $moduleName
		Remove-Module $moduleName -Force -ErrorAction Ignore

		Update-ModuleManifest -Path $ManifestPath -FunctionsToExport ($commandList | Select-Object -ExpandProperty Name)

		Write-Output 'Calculating fingerprint'
		$fingerprint = foreach ( $command in $commandList ) {
			foreach ( $parameter in $command.parameters.keys ) {
				'{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
				$command.parameters[$parameter].aliases | 
				Foreach-Object { '{0}:{1}' -f $command.name, $_ }
			}
		}
		if ( Test-Path "$moduleDir\fingerprint" ) {
			$oldFingerprint = Get-Content "$moduleDir\fingerprint"
		}

		Write-Output "There are $($fingerprint | Measure-Object | Select-Object -ExpandProperty Count) Fingerprint items"
		Write-Output "There are $($oldFingerprint | Measure-Object | Select-Object -ExpandProperty Count) oldFingerprint items"
		$bumpVersionType = ''

		$fingerprint | Where-Object { $_ -notin $oldFingerprint } | 
		ForEach-Object { $bumpVersionType = 'Patch'; "  $_" }
		'Detecting new features'
		$fingerprint | Where-Object { $_ -notin $oldFingerprint } | 
		ForEach-Object { $bumpVersionType = 'Minor'; "  $_" }
		'Detecting breaking changes'
		$oldFingerprint | Where-Object { $_ -notin $fingerprint } | 
		ForEach-Object { $bumpVersionType = 'Major'; "  $_" }

		Write-Verbose "Bumpversion: $bumpVersionType"
		$fingerprintPath = "$moduleDir\fingerprint" 
		Write-Verbose "fingerprintPath: $fingerprintPath"
		Set-Content -Path $fingerprintPath -Value $fingerprint

		if (!([string]::IsNullOrEmpty($bumpVersionType))) {
			Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType
		}

		if (!($skipScriptAnalyzer)) {
			Invoke-ScriptAnalyserWithReport -moduleDir $moduleDir
		}

		Write-Verbose "Creating the nuget package"
		#https://roadtoalm.com/2017/05/02/using-vsts-package-management-as-a-private-powershell-gallery/#comments
		nuget spec $ModuleName -Force

		[string]$nugetHack = Get-Content "$moduleDir\$ModuleName.nuspec"
		$moduleVersion = Get-Metadata $ManifestPath
		   
		$a = $nugetHack.replace("1.0.0" , $moduleVersion) 
		$a | Set-Content "$moduleDir\$ModuleName.nuspec" -Force
	}
}
catch {
	$ex = $_.Exception
	$errorLine = $_.InvocationInfo.ScriptLineNumber
	$errorMessage = $ex.Message 

	Set-Location $origLocation
	Write-Error "Error detected at line $errorLine, Error message: $errorMessage" -ErrorAction Stop
}

Set-Location $origLocation