  $ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir      = Split-Path $MyInvocation.MyCommand.Definition
$packageName   = $env:ChocolateyPackageName
$pp            = Get-PackageParameters
$name          = 'Screen Resolution'
$toolsLocation = Get-ToolsLocation
$workDir       = "$toolsLocation\$packageName"

#if (!((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ProductName -like '*Windows Server*')) {
#  throw 'This package requires Windows Server OS.'
#}

if (!$pp['UserName']) { $pp['UserName'] = "$env:UserName" }
if (!$pp['Password']) { $pp['Password'] = Read-Host "Enter password for $($pp['UserName']):" -AsSecureString}
if (!$pp['Password']) { throw "Package needs Password to install, that must be provided in params or in prompt." }

if (!$pp['RdpUserName']) { $pp['RdpUserName'] = 'rdp_local' }
if (!$pp['RdpPassword']) { $pp['RdpPassword'] = $pp['Password'] }
if (!$pp['RdpGroups']) { $pp['RdpGroups'] = @('Administrators', 'Remote Desktop Users') }

if (!$pp['Width']) { $pp['Width'] = 1920 }
if (!$pp['Height']) { $pp['Height'] = 1080 }

if (Get-WmiObject Win32_UserAccount -Filter "LocalAccount='true' and Name='$( $pp['RdpUserName'] )'") {
  Write-Host "Updating $($pp['RdpUserName']) user."
  NET USER "$($pp['RdpUserName'])" "$($pp['RdpPassword'])" /Y
} else {
  Write-Host "Creating $($pp['RdpUserName']) user."
  NET USER /ADD "$($pp['RdpUserName'])" "$($pp['RdpPassword'])" /COMMENT:"Created by $name" /FULLNAME:"RDP Local" /EXPIRES:NEVER /PASSWORDCHG:NO /Y
}

ForEach ($group In $pp['RdpGroups']) {
  try {
    Write-Host "Adding $( $pp['RdpUserName'] ) user to $group."
    NET LOCALGROUP "$group" "$($pp['RdpUserName'])" /ADD
  }
  catch {
    Write-Debug "User $( $pp['RdpUserName'] ) already in $group."
  }
}

$TaskName = 'CreateRdpHomeAndStoreUserCreds'
$Action = New-ScheduledTaskAction -Execute 'cmdkey.exe' -Argument "/add:127.0.0.2 /user:$($pp['UserName']) /pass:$($pp['Password'])"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $TaskName -User $pp['RdpUserName'] -Password $pp['RdpPassword'] -Action $Action -Settings $Settings -RunLevel Highest -Force
Start-ScheduledTask -TaskName $TaskName

$timer =  [Diagnostics.Stopwatch]::StartNew()
while (((Get-ScheduledTask -TaskName $TaskName).State -ne  'Ready') -and  ($timer.Elapsed.TotalSeconds -lt 90)) {
  Write-Debug -Message 'Waiting on scheduled task...'
  Start-Sleep -Seconds  3
}
$timer.Stop()

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

if (!(Test-Path $workDir)) {
  New-Item $workDir -ItemType directory -Force
}

$cmdName = "RDP-to-$($pp['UserName'])-at-res$($pp['Width'])x$($pp['Height'])"
$cmdPath = "$workDir\$cmdName.cmd"

$cmd = "mstsc.exe /v:127.0.0.2 /w:$($pp['Width']) /h:$($pp['Height'])"
$cmd | Set-Content $cmdPath

$startupDir = "C:\Users\$($pp['RdpUserName'])\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

if (!(Test-Path $startupDir)) {
  New-Item $startupDir -ItemType Directory -Force
}

$shortcutArgs = @{
  shortcutFilePath = "$startupDir\$cmdName.lnk"
  targetPath       = "$cmdPath"
  iconLocation     = "$toolsDir\icon.ico"
  workDirectory    = $workDir
}
Install-ChocolateyShortcut @shortcutArgs

# required by uninstaller to remove rdp user
"RdpUserName=$($pp['RdpUserName'])" | Set-Content $toolsDir\uninstall.parameters

# https://technet.microsoft.com/en-us/library/cc722151%28v=ws.10%29.aspx
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Type DWord -Value 0

# http://www.mytecbits.com/microsoft/windows/rdp-identity-of-the-remote-computer
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Terminal Server Client' -Name 'AuthenticationLevelOverride' -Type DWord -Value 0

$rules = Get-NetFirewallRule
$par = @{
  DisplayName   = "$name"
  LocalPort     = 3389
  LocalAddress  = 'any'
  RemoteAddress = 'LocalSubnet'
  Profile       = 'Public'
  Direction     = 'Inbound'
  Protocol      = 'TCP'
  Action        = 'Allow'
}
if (-not $rules.DisplayName.Contains($par.DisplayName)) {
  New-NetFirewallRule @par
}
