# Screen Resolution

[![Chocolatey](https://img.shields.io/chocolatey/dt/screen-resolution.svg)](https://chocolatey.org/packages/screen-resolution)
[![AppVeyor branch](https://img.shields.io/appveyor/ci/dhoer/choco-screen-resolution/master.svg)](https://ci.appveyor.com/project/dhoer/choco-screen-resolution)

Screen Resolution sets the screen resolution on Windows virtual machines (VMs). This tool is useful for UI automated testing when the default resolution is not at the desired resolution.

Installation of this package will do the following:

- Create a local user account to Remote Desktop Protocol (RDP) at specified screen resolution (default is 1920x1080) into another user account on same virtual machine
- Enable [Remote Desktop connections](https://technet.microsoft.com/en-us/library/cc722151%28v=ws.10%29.aspx)
- Bypass [Identity Of The Remote Computer Verification](http://www.mytecbits.com/microsoft/windows/rdp-identity-of-the-remote-computer)
- Allow TCP Port 3389 used by Windows Remote Desktop Protocol (RDP) in Windows Firewall

Tested on Windows Server 2012R2, Windows Server 2016, and Windows 10 virtual machines (VMs).

## Usage

A [Vagrantfile](https://github.com/dhoer/choco-screen-resolution/blob/master/Vagrantfile) to provision a Chrome Selenium-Grid on Windows 10 with screen resolution set to 1366x768 is available. See [TESTING.md](https://github.com/dhoer/choco-screen-resolution/blob/master/TESTING.md) for more information.

### Quick Start

Set screen resolution to 1920x1080 (default) and prompt for password:

```
choco install -y screen-resolution
```

Set screen resolution to 1366×768 and provide passwords:

```
choco install -y screen-resolution --params "'/Width:1366 /Height:768 /Password:redacted /RdpPassword:redacted'"
```

### Package Parameters

The following package parameters can be set:

- `/Password:` - Password of account to RDP into. Prompts for password,
    when it is not provided.
- `/RdpPassword:` - Password of RDP local user account to create.
    Defaults to Password of account to RDP into, when it is not
    provided.
- `/UserName:` - Username of account to RDP into.
    Default: `$env:UserName`.
- `/RdpUserName:` - Username of RDP local user account to create.
    Default: `rdp_local`.
- `/RdpGroups:` - RDP group members.
    Default: `@('Administrators', 'Remote Desktop Users')`.
- `/Width:` - Display width in pixels. Default: `1920`.
- `/Height:` - Display height in pixels. Default: `1080`.

These parameters can be passed to the installer with the use of
`--params`. For example: `--params "'/Password:redacted'"`.

### AutoLogon

To automatically set Screen Resolution on server startup, you need
to install package
[autologon](https://chocolatey.org/packages/autologon).  Then run
`autologon <RdpUserName> <RdpDomain> <RdpPassword>` once to set it up.

```
choco install -y autologon
autologon rdp_local $env:userdomain redacted
```

### RDP Wrapper

Non-Windows Servers, e.g., Windows 10, requires package
[rdpwrapper](https://chocolatey.org/packages/rdpwrapper) to be
installed. No other configuration is required.

```
choco install -y rdpwrapper
```
