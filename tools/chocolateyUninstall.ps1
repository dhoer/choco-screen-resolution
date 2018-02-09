$toolsDir      = Split-Path $MyInvocation.MyCommand.Definition
$toolsLocation = Get-ToolsLocation
$workDir       = "$toolsLocation\$packageName"
$name          = 'Screen Resolution'

$rules = Get-NetFirewallRule
if ($rules.DisplayName.Contains($name)) { Remove-NetFirewallRule -DisplayName $name }

$props = ConvertFrom-StringData (Get-Content $toolsDir\uninstall.parameters -Raw)
$rdpUserName = $props['RdpUserName']

Write-Debug "Removing $rdpUserName user."
NET USER "$rdpUserName" /DELETE

Get-WmiObject Win32_UserProfile -Filter 'RefCount=0' | ForEach-Object {
  $_.Delete()
}

if (Test-Path $workDir) {
  Remove-Item $workDir -Recurse -Force
}
