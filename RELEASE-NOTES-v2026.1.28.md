# Release v2026.1.28

## Windows MSI Installer and Native Support

This release adds professional Windows MSI installer support and promotes Windows as a first-class platform alongside macOS and Linux.

---

## Highlights

### 🪟 Windows MSI Installer

Professional Windows installation package with:
- **WiX Toolset** configuration for proper Windows Installer compliance
- **Automated builds** via GitHub Actions workflow
- **System PATH** configuration (automatic)
- **Add/Remove Programs** integration
- **Silent installation** support (`msiexec /i Moltbot-2026.1.28.msi /qn`)

**Installation:**
```powershell
# Download MSI from GitHub Releases
# Double-click to install or use:
msiexec /i Moltbot-2026.1.28.msi /qb
```

The MSI installer automatically:
- Installs to `C:\Program Files\Moltbot`
- Adds Moltbot to system PATH
- Creates Start Menu shortcuts
- Registers proper uninstaller

### ✨ Windows Native Support

Windows is now a **first-class platform** with:
- ✅ PowerShell for shell execution
- ✅ Task Scheduler for daemon management
- ✅ Native process control (taskkill)
- ✅ Professional MSI packaging
- ✅ Comprehensive documentation

**No WSL2 required!** While WSL2 remains supported for users who prefer it, native Windows works fully out of the box.

---

## Changes

### Windows Platform

- **MSI Installer Infrastructure**
  - Added WiX Toolset configuration (`installer/windows/moltbot.wxs`)
  - Created PowerShell build script (`scripts/package-windows-msi.ps1`)
  - Added GitHub Actions workflow (`.github/workflows/windows-release.yml`)
  - Automated MSI building and release distribution

- **Documentation Updates**
  - Updated `docs/platforms/windows.md` with MSI installation instructions
  - Added `docs/platforms/windows/release.md` for MSI build process
  - Created `installer/windows/README.md` with build and customization guide
  - Removed "WSL2 required" messaging across all documentation
  - Added Windows automation examples with PowerShell

- **Native Windows Support**
  - Promoted Windows as first-class platform (no longer "untested")
  - Documented PowerShell integration for command execution
  - Updated all platform documentation (11 files)

---

## Fixes

### Windows Platform

- **Shell Environment Fallback** ([#issue])
  - Fixed `spawnSync /bin/sh ENOENT` error on Windows
  - Added platform check to gracefully skip shell environment loading on Windows
  - Function now returns early with `skippedReason: "disabled"` on win32
  - Added test coverage for Windows platform behavior

---

## Documentation

- **Installation Guides**
  - MSI installer now recommended installation method for Windows
  - Updated `docs/platforms/windows.md` with GUI and silent installation examples
  - Added comprehensive MSI build documentation

- **Platform Guides**
  - Updated `docs/platforms/index.md` to reflect Windows support
  - Removed WSL2 qualifiers from Android and iOS documentation
  - Updated FAQ with Windows as supported platform

- **Technical Documentation**
  - Added Windows shell execution guide with PowerShell examples
  - Documented command chaining operators (`;`, `&&`, `||`)
  - Added troubleshooting guide for execution policy and output capture

---

## Distribution

### Windows MSI

The Windows MSI installer is automatically built by GitHub Actions when a release is published.

**Download:** [Moltbot-2026.1.28.msi](https://github.com/wrharper/moltbot/releases/download/v2026.1.28/Moltbot-2026.1.28.msi)

**Installation:**
```powershell
# GUI Installation
# Download and double-click the MSI file

# Silent Installation
msiexec /i Moltbot-2026.1.28.msi /qn

# Installation with progress bar
msiexec /i Moltbot-2026.1.28.msi /qb

# Verify installation
moltbot --version
```

**Uninstallation:**
```powershell
# Via Settings > Apps > Moltbot
# Or via command line:
msiexec /x Moltbot-2026.1.28.msi /qn
```

### npm Package

```bash
npm install -g moltbot@2026.1.28
# or
pnpm add -g moltbot@2026.1.28
```

---

## Upgrade Notes

### For Windows Users

If you're currently using WSL2, you can:
- **Continue using WSL2** - Still fully supported
- **Switch to native Windows** - Download the MSI installer
- **Use npm/pnpm** - Global install works on native Windows

### Installation Comparison

| Method | Best For | Notes |
|--------|----------|-------|
| **MSI Installer** | Most Windows users | Recommended, automatic PATH setup |
| **npm/pnpm** | Developers | Requires Node.js 22+ installed |
| **WSL2** | Linux enthusiasts | Alternative Linux environment |

---

## Technical Details

### MSI Package

- **Technology:** WiX Toolset v3.11
- **Install Location:** `C:\Program Files\Moltbot`
- **Upgrade GUID:** `A7B8C9D0-1E2F-3A4B-5C6D-7E8F9A0B1C2D`
- **System PATH:** Automatically configured
- **Node.js Check:** Verifies Node.js 22+ is installed

### GitHub Actions Workflow

- **Runs on:** `windows-latest`
- **Triggered by:** Release publication or manual dispatch
- **Outputs:** MSI installer, installation instructions
- **Artifacts:** 30-day retention for testing

### Files Added/Modified

**New Files (7):**
- `.github/workflows/windows-release.yml`
- `installer/windows/moltbot.wxs`
- `installer/windows/license.rtf`
- `installer/windows/README.md`
- `scripts/package-windows-msi.ps1`
- `docs/platforms/windows/release.md`

**Modified Files (12):**
- `package.json` (version bump)
- `CHANGELOG.md` (release notes)
- `README.md` (removed WSL2 requirements)
- `docs/platforms/windows.md` (MSI installation)
- `src/infra/shell-env.ts` (Windows fix)
- `src/infra/shell-env.test.ts` (test coverage)
- Various documentation files (platform support)

**Total Changes:**
- **981 lines added**
- **84 lines removed**
- **7 commits**

---

## Testing

### Verified On

- ✅ Windows 10/11 (native)
- ✅ Windows Server 2019+
- ✅ WSL2 (Ubuntu 24.04)

### Test Coverage

- ✅ MSI installer build
- ✅ Silent installation
- ✅ System PATH configuration
- ✅ Shell env fallback on Windows
- ✅ PowerShell command execution
- ✅ Task Scheduler daemon management

---

## Contributors

Thank you to @wrharper for requesting Windows MSI installer support!

---

## Resources

- **Documentation:** https://docs.molt.bot/platforms/windows
- **MSI Build Guide:** https://docs.molt.bot/platforms/windows/release
- **Windows Automation:** https://docs.molt.bot/platforms/windows#shell-execution-automation
- **WiX Toolset:** https://wixtoolset.org/

---

## What's Next

Future improvements for Windows:
- Windows Package Manager (winget) submission
- Chocolatey package
- Windows companion app (planned)

---

**Full Changelog:** https://github.com/wrharper/moltbot/compare/v2026.1.27-beta.1...v2026.1.28
