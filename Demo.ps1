#region Demo 1
## Deploy a new zero-day KB patch to multiple computers
& "$PSScriptRoot\Deploy-WindowsPatch.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -Verbose

## Deploy VNC to a couple of computers
$credential = Get-Credential
& "$PSScriptRoot\Deploy-VNC.ps1" -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -Verbose -Credential $credential
#endregion

#region Demo 2
GUI based -- appveyor and PSADSync
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