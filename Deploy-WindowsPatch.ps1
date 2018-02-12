<#
	.SYNOPSIS
		This function deploys a Windows patch to a remote computer.
		
	.EXAMPLE
		PS> $cred = Get-Credential
		PS> .\Deploy-WindowsPatch.ps1 -ComputerName CLIENT1 -KbId KBXXXXXXX -Credential $cred
	
		This example installs the Kb KBXXXXXXX on the remote computer.
		
	.PARAMETER ComputerName
		The name of the computer(s) you'd like to run this function against. This is mandatory.
	
	.PARAMETER KbId
		The KB ID to install. This is mandatory.
	#>
[CmdletBinding()]
param
(
	[Parameter(Mandatory)]
	[string[]]$ComputerName,

	[Parameter(Mandatory)]
	[string]$KbId
)

if (-not (Get-Module -Name PSWindowsUpdate -List)) {
	## Download the PSWindowsUpdate module from the PowerShell Gallery
	$provParams = @{
		Name           = 'NuGet'
		MinimumVersion = '2.8.5.208'
		Force          = $true
	}

	$null = Install-PackageProvider @provParams
	$null = Import-PackageProvider @provParams

	Install-Module -Name 'PSWindowsUpdate' -Force -Confirm:$false
}

$jobs = @()

foreach ($c in $ComputerName) {
	Write-Verbose -Message "Starting deployment job on [$c]..."
	$deploymentScriptBlock = {
		Install-WindowsUpdate -KBArticleID $args[0] -Confirm:$false
	}
	$jobs += Start-Job -ScriptBlock $deploymentScriptBlock -ArgumentList $KbId

}
	

while ($jobs | Where-Object { $_.State -eq 'Running'}) {
	Write-Verbose -Message "Waiting for all computers to finish..."
	Start-Sleep -Second 1
}

## Get the job output
$jobs | Receive-Job

## Cleanup the jobs
$jobs | Remove-Job