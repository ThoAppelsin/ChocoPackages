
$ErrorActionPreference = 'Stop';

$packageName= 'powershell-core'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$Version = "6.2.0-rc.1"
Try {
  [Version]$Version
  $InstallFolder = "$env:ProgramFiles\PowerShell\$($version.split('.')[0])"
}
Catch {
  Write-output "Note: This is a prelease package"
  $PreleasePackage = $true
  $InstallFolder = "$env:ProgramFiles\PowerShell\$($version.split('.')[0])-preview"
}

If (Test-Path "$InstallFolder\pwsh.exe")
{
  Write-output "$packagename version $PFSubfolder is already installed by another means."
  Exit 0
}

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url           = "https://github.com/PowerShell/PowerShell/releases/download/v$version/PowerShell-$version-win-x86.msi"
  url64bit      = "https://github.com/PowerShell/PowerShell/releases/download/v$version/PowerShell-$version-win-x64.msi"

  softwareName  = "PowerShell-6.0.*"

  checksum      = 'DEA825F48A666966B12B08BA224E8EF0BA6BE651DBD1B961193D4B1ECCA3F7F2'
  checksumType  = 'sha256'
  checksum64    = '0C0F5D68D3C69D36BE4151C3C98BF44F3C6EA33769E19295BE136A785EC10054'
  checksumType64= 'sha256'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes= @(0, 3010, 1641)
  }

$pp = Get-PackageParameters

if ($pp.CleanUpPath) {
  Write-Host "/CleanUpSystemPath was used, removing all PowerShell Core path entries before installing"
  & "$toolsDir\Reset-PWSHSystemPath.ps1" -PathScope Machine, User -RemoveAllOccurances
}

Write-Warning "If you started this package under PowerShell core, replacing an in-use version may be unpredictable, require multiple attempts or produce errors."

Install-ChocolateyPackage @packageArgs

Write-Output "************************************************************************************"
Write-Output "*  INSTRUCTIONS: Your system default WINDOWS PowerShell version has not been changed."
Write-Output "*   PowerShell CORE $version, was installed to: `"$installfolder`""
If ($PreleasePackage) {
Write-Output "*   To start PowerShell Core PRERELEASE $version, at a prompt execute:"
Write-Output "*      `"$installfolder\pwsh.exe`""
Write-Output "*   IMPORTANT: Prereleases are not put on your path, nor made the default version of CORE."
}
else {
Write-Output "*   To start PowerShell Core $version, at a prompt or the start menu execute:"
Write-Output "*      `"pwsh.exe`""
Write-Output "*   Or start it from the desktop or start menu shortcut installed by this package."
Write-Output "*   This is your new default version of PowerShell CORE (pwsh.exe)."
}
Write-Output "************************************************************************************"

Write-Output "**************************************************************************************"
Write-Output "*  As of OpenSSH 0.0.22.0 Universal Installer, a script is distributed that allows   *"
Write-Output "*  setting the default shell for openssh. You could call it with code like this:     *"
Write-Output "*    If (Test-Path `"$env:programfiles\openssh-win64\Set-SSHDefaultShell.ps1`")         *"
Write-Output "*      {& `"$env:programfiles\openssh-win64\Set-SSHDefaultShell.ps1`" [PARAMETERS]}     *"
Write-Output "*  Learn more with this:                                                             *"
Write-Output "*    Get-Help `"$env:programfiles\openssh-win64\Set-SSHDefaultShell.ps1`"               *"
Write-Output "*  Or here:                                                                          *"
Write-Output "*    https://github.com/DarwinJS/ChocoPackages/blob/master/openssh/readme.md         *"
Write-Output "**************************************************************************************"
