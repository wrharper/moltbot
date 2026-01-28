#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build Windows MSI installer for Moltbot
.DESCRIPTION
    Builds the TypeScript project, bundles it as a standalone executable,
    and creates a Windows MSI installer using WiX Toolset.
.PARAMETER Version
    Product version (default: from package.json)
.PARAMETER OutputDir
    Output directory for MSI (default: dist)
.PARAMETER Sign
    Sign the MSI with code signing certificate
.EXAMPLE
    .\scripts\package-windows-msi.ps1 -Version "2026.1.27"
#>

param(
    [string]$Version = "",
    [string]$OutputDir = "dist",
    [switch]$Sign = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "SUCCESS: $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

# Get repository root
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot

Write-Info "Building Moltbot Windows MSI installer..."

# Get version from package.json if not provided
if ([string]::IsNullOrEmpty($Version)) {
    $PackageJson = Get-Content "package.json" | ConvertFrom-Json
    $Version = $PackageJson.version
    Write-Info "Using version from package.json: $Version"
}

# Check for WiX Toolset
Write-Info "Checking for WiX Toolset..."
$WixPath = $env:WIX
if ([string]::IsNullOrEmpty($WixPath)) {
    # Try common installation paths
    $CommonPaths = @(
        "${env:ProgramFiles(x86)}\WiX Toolset v3.11",
        "${env:ProgramFiles}\WiX Toolset v3.11",
        "${env:ProgramFiles(x86)}\WiX Toolset v4.0",
        "${env:ProgramFiles}\WiX Toolset v4.0"
    )
    
    foreach ($Path in $CommonPaths) {
        if (Test-Path "$Path\bin") {
            $WixPath = $Path
            break
        }
    }
    
    if ([string]::IsNullOrEmpty($WixPath)) {
        Write-Error "WiX Toolset not found. Please install from https://wixtoolset.org/"
        Write-Error "Or install via: winget install WiXToolset.WiX --version 3.11.2"
        exit 1
    }
}

$CandlePath = Join-Path $WixPath "bin\candle.exe"
$LightPath = Join-Path $WixPath "bin\light.exe"

if (-not (Test-Path $CandlePath)) {
    Write-Error "candle.exe not found at: $CandlePath"
    exit 1
}

Write-Success "Found WiX Toolset at: $WixPath"

# Check for Node.js
Write-Info "Checking for Node.js..."
$NodeVersion = & node --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Node.js not found. Please install Node.js 22 or later."
    exit 1
}
Write-Success "Node.js version: $NodeVersion"

# Build the project
Write-Info "Building TypeScript project..."
& pnpm install --frozen-lockfile
if ($LASTEXITCODE -ne 0) {
    Write-Error "pnpm install failed"
    exit 1
}

& pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

Write-Success "Build completed"

# Bundle as standalone executable using pkg
Write-Info "Bundling as standalone executable..."

# Check if pkg is available
$PkgInstalled = & npm list -g pkg 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Info "Installing pkg globally..."
    & npm install -g pkg
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install pkg"
        exit 1
    }
}

# Create pkg config if it doesn't exist
$PkgConfig = @{
    "pkg" = @{
        "scripts" = "dist/**/*.js"
        "assets" = @(
            "dist/**/*.json",
            "assets/**/*"
        )
        "targets" = @("node22-win-x64")
        "outputPath" = "dist"
    }
} | ConvertTo-Json -Depth 10

# Note: For actual bundling, we need to handle Node.js app differently
# For now, we'll create a simple batch wrapper
Write-Info "Creating CLI wrapper..."
$WrapperBat = @"
@echo off
setlocal
set "MOLTBOT_HOME=%~dp0"
node "%MOLTBOT_HOME%dist\index.js" %*
"@

$WrapperBat | Out-File -FilePath "dist\moltbot.bat" -Encoding ASCII
$WrapperBat | Out-File -FilePath "dist\clawdbot.bat" -Encoding ASCII

# For MSI, we need an .exe - create a simple launcher
# In production, you'd use pkg or nexe to create a real executable
Write-Info "Note: Using batch file wrapper. For production, bundle with pkg or nexe."

# Ensure output directory exists
$OutputDir = Join-Path $RepoRoot $OutputDir
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Build MSI
Write-Info "Compiling WiX source..."
$WxsFile = Join-Path $RepoRoot "installer\windows\moltbot.wxs"
$WixObjFile = Join-Path $RepoRoot "installer\windows\moltbot.wixobj"
$MsiFile = Join-Path $OutputDir "Moltbot-$Version.msi"

if (-not (Test-Path $WxsFile)) {
    Write-Error "WiX source file not found: $WxsFile"
    exit 1
}

# Compile
& $CandlePath -out $WixObjFile $WxsFile -dVersion=$Version
if ($LASTEXITCODE -ne 0) {
    Write-Error "WiX compilation failed"
    exit 1
}

Write-Success "WiX compilation completed"

# Link
Write-Info "Linking MSI..."
& $LightPath -out $MsiFile $WixObjFile -ext WixUIExtension -cultures:en-us
if ($LASTEXITCODE -ne 0) {
    Write-Error "WiX linking failed"
    exit 1
}

Write-Success "MSI created: $MsiFile"

# Sign if requested
if ($Sign) {
    Write-Info "Signing MSI..."
    $SignTool = "signtool.exe"
    
    # Check for code signing certificate
    $Cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1
    if ($null -eq $Cert) {
        Write-Error "No code signing certificate found in CurrentUser\My store"
        exit 1
    }
    
    & $SignTool sign /sha1 $Cert.Thumbprint /t http://timestamp.digicert.com /fd SHA256 $MsiFile
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Signing failed"
        exit 1
    }
    
    Write-Success "MSI signed successfully"
}

# Clean up intermediate files
Remove-Item $WixObjFile -ErrorAction SilentlyContinue

Write-Success "Windows MSI installer created successfully!"
Write-Info "Output: $MsiFile"
Write-Info ""
Write-Info "To install: msiexec /i `"$MsiFile`" /qb"
Write-Info "To uninstall: msiexec /x `"$MsiFile`" /qb"
