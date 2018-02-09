$ErrorActionPreference = 'Stop'; # stop on all errors
$Password = 'vagrant'
$RdpPassword = 'bfnhQ8UXRQ7R4eqb'


##
# Install Chocolatey - https://chocolatey.org
##

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


##
# Install RDP Wrapper - required for Windows 10 only - comment out for Windows Server 2012R2 and 2016
##

choco install -y rdpwrapper


##
# Install Screen Resolution
##

choco pack C:\vagrant\screen-resolution.nuspec --outputdirectory C:\vagrant
choco install -y screen-resolution --params "'/Width:1366 /Height:768 /Password:$Password /RdpPassword:$RdpPassword'" -d -s C:\vagrant --force


##
# Configure AutoLogon
##

# cleanup original vagrant autologon setup
$RegPath ="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Remove-ItemProperty -Path $RegPath -Name "AutoLogonCount" -ErrorAction SilentlyContinue

choco install -y autologon
autologon rdp_local $env:userdomain $RdpPassword
