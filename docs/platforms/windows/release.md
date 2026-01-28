---
summary: "Windows MSI release build and distribution process"
read_when:
  - Creating a Windows release with MSI installer
  - Publishing Windows installer
---

# Windows MSI Release

Build and release Windows MSI installers for Moltbot.

## Prerequisites

- **Windows 10/11**
- **Node.js ≥22**
- **pnpm**
- **WiX Toolset v3.11+**: `winget install WiXToolset.WiX --version 3.11.2`

## Build MSI

```powershell
.\scripts\package-windows-msi.ps1 -Version "2026.1.27"
```

## GitHub Actions

Workflow runs automatically on release publication, creating and uploading MSI.

## Distribution

MSI files attach to GitHub Releases: `Moltbot-{version}.msi`

## References

- [WiX Toolset](https://wixtoolset.org/)
- [Windows Documentation](/platforms/windows)
