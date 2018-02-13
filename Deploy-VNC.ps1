<#
	.SYNOPSIS
		This function deploys the UltraVNC software package to a remote computer.
		
	.EXAMPLE
		PS> $cred = Get-Credential
		PS> .\Deploy-VNC.ps1 -ComputerName CLIENT1 -InstallFolder \\MEMBERSRV1\VNC -Credential $cred
	
		This example copies all files from \\MEMBERSRV1\VNC which should contain a file called setup.exe representing the UltraVNC
		installer and silentinstall.inf representing the UltraVNC silent install answer file. These files will be copied to
		CLIENT1 in a VNC folder and executed to install UltraVNC.
		
	.PARAMETER ComputerName
		The name of the computer(s) you'd like to run this function against. This is mandatory.
	
	.PARAMETER InstallerFolderPath
		The folder that contains the UltraVNC installer (setup.exe) and the UltraVNC answer file (silentinstall.inf). This is mandatory.

	.PARAMETER Credential
		A PSCredential object representing alternate username and password to connect to the remote computer.
	#>
[CmdletBinding()]
param
(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string[]]$ComputerName,
		
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -Path $_ -PathType Container })]
	[string]$InstallerFolderPath,

	[Parameter(Mandatory)]
	[pscredential]$Credential
)

$jobs = @()
foreach ($c in $ComputerName) {

	## Save credential to local cached credentials
	if ((cmdkey /list:($c)) -match '\* NONE \*') {
		$null = cmdkey /add:$c /user:($Credential.UserName) /pass:($Credential.GetNetworkCredential().Password)
	}

	Write-Verbose -Message "Starting deployment job on [$c]..."
	$jobBlock = {
		try {
			$installFolderName = $args[0] | Split-Path -Leaf
			$uncInstallerFolder = "\\$c\c$\$installFolderName"
			Copy-Item -Path $args[0] -Destination "\\$($args[1])\c$" -Recurse -Force
					
			$scriptBlock = { 
				$VerbosePreference = $using:VerbosePreference
					
				## Remotely invoke the VNC installer on the computer
				$localInstallFolder = "C:\$($args[2])"
				$localInstaller = "$localInstallFolder\Setup.exe"
				$localInfFile = "$localInstallFolder\silentinstall.inf"

				Write-Host "Running installer [$localInstaller]..."
				Start-Process $localInstaller -Args "/verysilent /loadinf=`"$localInfFile`"" -Wait -NoNewWindow
			}
			$icmParams = @{
				ComputerName = $args[1]
				ScriptBlock  = $scriptBlock
				ArgumentList = $args[0], $args[1], $installFolderName
			}
			Invoke-Command @icmParams
		} catch {
			$PSCmdlet.ThrowTerminatingError($_)
		} finally {
			$remoteInstallFolder = "\\$c\c$\$installFolderName"
			Remove-Item $remoteInstallFolder -Recurse -ErrorAction Ignore
		}
	}
	$jobs += Start-Job -ScriptBlock $jobBlock -ArgumentList $InstallerFolderPath
	while ($jobs | Where-Object { $_.State -eq 'Running'}) {
		Write-Verbose -Message "Waiting for all computers to finish..."
		Start-Sleep -Second 5
	}

	## Get the job output
	$jobs | Receive-Job

	## Cleanup the jobs
	$jobs | Remove-Job
}
