<#
Ensure the Azure VMs CLIENTJUMP, CLIENTSERVER1 and CLIENTSERVER2 are started
RDP to CLIENTJUMP (user: adam, password: I like azure.)
#>


#region Demo 1
## Deploy a new zero-day KB patch to multiple computers
& "$PSScriptRoot\Deploy-WindowsPatch.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -KbId 'KB4052623' -Verbose

## Deploy VNC to a couple of computers
$credential = Get-Credential
& "$PSScriptRoot\Deploy-VNC.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -Verbose -Credential $credential
#endregion

#region Demo 2

<# 
	Intro Github PSADSync repo
	Intro AppVeyor
	Find-Module -Name PSADSync -- notice version
	Show build scripts
	Commit change to PSAdSync module
	Show AppVeyor build
	Find-Module -Name PSADSync -- notice version
#>

#endregion

#region Demo 3

## Download the MyTwitter PowerShell module from Github
$repoZipFile = "$PSScriptRoot\MyTwitter.zip"
Invoke-WebRequest -Uri 'https://github.com/MyTwitter/MyTwitter/archive/master.zip' -OutFile $repoZipFile

$modulePath = 'C:\Program Files\WindowsPowerShell\Modules'
$repoTempPath = "$env:Temp\MyTwitter-master"
Expand-Archive -Path $repoZipFile -DestinationPath ($repoTempPath | Split-Path -Parent) -Force

"$env:Temp\MyTwitter", "$modulePath\MyTwitter", $repoZipFile | foreach {
	Remove-Item -Path $_ -ErrorAction Ignore -Recurse
}

$moduleFolder = Rename-Item -Path $repoTempPath -NewName 'MyTwitter' -PassThru -Force
Move-Item -Path $moduleFolder.FullName -Destination $modulePath -Force
#endregion