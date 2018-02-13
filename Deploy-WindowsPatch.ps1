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
	[string]$KbId,

	[Parameter(Mandatory)]
	[pscredential]$Credential

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

	## Save credential to local cached credentials
	if ((cmdkey /list:($c)) -match '\* NONE \*') {
		$null = cmdkey /add:$c /user:($Credential.UserName) /pass:($Credential.GetNetworkCredential().Password)
	}

	Write-Verbose -Message "Starting deployment job on [$c]..."
	$deploymentScriptBlock = {
		if (-not (Get-WindowsUpdate -KBArticleID $args[0] -IsInstalled)) {
			Install-WindowsUpdate -KBArticleID $args[0] -Confirm:$false
			Write-Verbose -Message "Installed KB [$($args[0])]."
		} else {
			Write-Verbose -Message "The KB [$($args[0])] is already installed."
		}
	}
	$jobs += Invoke-Command -ComputerName $c -ScriptBlock $deploymentScriptBlock -ArgumentList $KbId

}
	

while ($jobs | Where-Object { $_.State -eq 'Running'}) {
	Write-Verbose -Message "Waiting for all computers to finish..."
	Start-Sleep -Second 5
}

## Get the job output
$jobs | Receive-Job

## Cleanup the jobs
$jobs | Remove-Job