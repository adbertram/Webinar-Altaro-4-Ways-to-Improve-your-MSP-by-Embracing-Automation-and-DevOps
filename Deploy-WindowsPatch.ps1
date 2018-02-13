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
	[string]$InstallerFilePath,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$InstallerArguments

)

foreach ($c in $ComputerName) {
	## Copy the hotfix installer to the remote computer
	Write-Verbose -Message "Copying installer to remote computer [$($c)]..."
	Copy-Item -Path $InstallerFilePath -Destination "\\$c\c$"
	
	## Invoke the installer on the remote computer
	Write-Verbose -Message "Invoking hotfix installer on remote computer [$($c)]..."
	$icmParams = @{
		ComputerName = $c
		ScriptBlock  = { Start-Process -FilePath "C:\$($using:InstallerFilePath | Split-Path -Leaf)" -ArgumentList $using:InstallerArguments -Wait -NoNewWindow }
	}
	Invoke-Command @icmParams
}
Write-Verbose -Message 'Done.'