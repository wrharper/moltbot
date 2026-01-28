# Windows MSI Installer

This directory contains the WiX Toolset configuration for building a Windows MSI installer for Moltbot.

## Prerequisites

1. **WiX Toolset v3.11 or later**
   - Download from: https://wixtoolset.org/
   - Or install via winget: `winget install WiXToolset.WiX --version 3.11.2`

2. **Node.js 22 or later**
   - Download from: https://nodejs.org/

3. **Build tools**
   - Visual Studio Build Tools or full Visual Studio with C++ workload
   - Or Windows SDK

## Building the MSI

### Using PowerShell Script (Recommended)

```powershell
# From repository root
.\scripts\package-windows-msi.ps1 -Version "2026.1.27"

# With code signing
.\scripts\package-windows-msi.ps1 -Version "2026.1.27" -Sign
```

### Manual Build

```powershell
# 1. Build the project
pnpm install
pnpm build

# 2. Create batch file wrappers
@echo off > dist\moltbot.bat
echo node "%~dp0dist\index.js" %* >> dist\moltbot.bat

# 3. Compile WiX source
cd installer\windows
candle.exe moltbot.wxs -dVersion=2026.1.27

# 4. Link to create MSI
light.exe -out ..\..\dist\Moltbot-2026.1.27.msi moltbot.wixobj -ext WixUIExtension
```

## Files

- `moltbot.wxs` - WiX source file defining the installer structure
- `license.rtf` - License text shown during installation
- `README.md` - This file

## Customization

### Product Information

Edit `moltbot.wxs` to customize:
- **ProductName**: Display name
- **Manufacturer**: Company/project name  
- **UpgradeCode**: GUID for upgrade detection (don't change once released)

### Components

The installer includes:
- CLI batch files (`moltbot.bat`, `clawdbot.bat`)
- Node.js application files
- Documentation (README, LICENSE, CHANGELOG)
- PATH environment variable configuration

### Adding Files

Use WiX Heat tool to automatically harvest files:

```powershell
heat.exe dir ..\..\dist -cg DistFiles -gg -sfrag -srd -dr INSTALLFOLDER -out dist-files.wxs
```

Then reference `DistFiles` component group in `moltbot.wxs`.

## Distribution

The built MSI can be distributed via:
- GitHub Releases
- Direct download from https://molt.bot
- Windows Package Manager (winget)
- Chocolatey

## Installation

Users can install with:

```powershell
# GUI installer
msiexec /i Moltbot-2026.1.27.msi

# Silent install
msiexec /i Moltbot-2026.1.27.msi /qn

# With logging
msiexec /i Moltbot-2026.1.27.msi /l*v install.log
```

## Uninstallation

```powershell
# Via Add/Remove Programs
# Or via msiexec
msiexec /x Moltbot-2026.1.27.msi /qn
```

## Troubleshooting

### WiX Toolset Not Found

Set the `WIX` environment variable:

```powershell
$env:WIX = "C:\Program Files (x86)\WiX Toolset v3.11"
```

### Node.js Not Detected

The installer checks for Node.js in the registry. Install Node.js before building or testing the MSI.

### Permission Issues

Building the MSI may require administrative privileges if modifying system-wide paths or registry keys.

## References

- [WiX Toolset Documentation](https://wixtoolset.org/documentation/manual/v3/)
- [Windows Installer Guide](https://docs.microsoft.com/en-us/windows/win32/msi/windows-installer-portal)
- [Moltbot Documentation](https://docs.molt.bot/platforms/windows)
