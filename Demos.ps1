<#
Ensure the Azure VMs CLIENTJUMP, CLIENTSERVER1 and CLIENTSERVER2 are started
RDP to CLIENTJUMP (52.179.99.65) (user: adam, password: I like azure.)
Open PowerShell console
#>

$demoFolder = 'C:\users\adam\Documents\GitHub\Webinar-Altaro-4-Ways-to-Improve-your-MSP-by-Embracing-Automation-and-DevOps\'
cd $demoFolder

#region Demo 1

#region Patch deployment

## Download the hotfix from the MS website
$hotfixUri = 'https://download.microsoft.com/download/F/D/0/FD0B0093-DE8A-4C4E-BDC4-F0C56D72018C/50907.00/Silverlight_x64.exe'
$hotfixFilePath = "$demoFolder\Silverlight_x64.exe"
Invoke-WebRequest -Uri $hotfixUri -OutFile $hotfixFilePath

## The Silverlight installer is KB4023307
## Show that KB patch KB4023307 is needed -- this returns all patches needed
## CLIENTSERVER1 already has the patch and will skip over
Get-WindowsUpdate -ComputerName CLIENTSERVER2

## Deploy a new zero-day KB patch to multiple computers
.\Deploy-WindowsPatch.ps1 -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -InstallerFilePath $hotfixFilePath -InstallerArguments '/q' -Verbose

## The patch has been installed since it doesn't show up here anymore
Get-WindowsUpdate -ComputerName CLIENTSERVER2
#endregion

#region Deploy VNC to a couple of computers
.\Deploy-VNC.ps1 -ComputerName 'CLIENTSERVER1', 'CLIENTSERVER2' -InstallerFolderPath "$demoFolder\VNC" -Verbose

#endregion
#endregion

#region Demo 2

<# 
	Intro Github PSADSync repo - https://github.com/adbertram/PSADSync
	Intro AppVeyor - https://ci.appveyor.com/projects
	Find-Module -Name PSADSync -- notice version
	Show build scripts in Github repo
	Commit change to PSAdSync module
	Show AppVeyor build
	Find-Module -Name PSADSync -- notice version
#>

#endregion