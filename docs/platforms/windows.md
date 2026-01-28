---
summary: "Windows support + companion app status"
read_when:
  - Installing Moltbot on Windows
  - Looking for Windows companion app status
---
# Windows

Moltbot runs natively on Windows using Node.js and the Windows Task Scheduler for daemon management. The CLI and Gateway work on Windows 10/11 with full feature parity to macOS and Linux.

**Note**: For advanced users comfortable with Linux, WSL2 (Ubuntu recommended) is also supported as an alternative runtime environment.

Native Windows companion apps are planned.

## Install (Native Windows)

### Prerequisites
- **Node.js ≥22** - Download from [nodejs.org](https://nodejs.org/)
- **PowerShell** or **Command Prompt**
- **npm**, **pnpm**, or **bun** package manager

### Installation

Open PowerShell or Command Prompt:

```powershell
npm install -g moltbot@latest
# or: pnpm add -g moltbot@latest

moltbot onboard --install-daemon
```

Full guide: [Getting Started](/start/getting-started)

## Gateway Service

The gateway daemon on Windows uses the **Task Scheduler** to run automatically at login.

### Install Gateway Service

```powershell
moltbot gateway install
```

Or use the interactive wizard:

```powershell
moltbot configure
```

Select **Gateway service** when prompted.

### Manage Gateway Service

```powershell
# Check status
moltbot gateway status

# Restart gateway
moltbot gateway restart

# Stop gateway
moltbot gateway stop

# Uninstall gateway service
moltbot gateway uninstall
```

### Repair/Migrate

If you encounter issues:

```powershell
moltbot doctor
```

## Configuration

- [Gateway configuration](/gateway/configuration)
- [Gateway runbook](/gateway)

## Paths

Windows uses standard AppData locations:

- **Config**: `%USERPROFILE%\.clawdbot\config.yaml`
- **State**: `%USERPROFILE%\.clawdbot\`
- **Sessions**: `%USERPROFILE%\.clawdbot\sessions\`
- **Logs**: Check Task Scheduler logs or stdout redirection in task script

## Shell Execution & Automation

Moltbot uses **PowerShell** for command execution on Windows, providing full automation capabilities similar to macOS/Linux.

### How It Works

The agent's `bash` tool automatically uses PowerShell when running on Windows:
- **Shell**: PowerShell (via `powershell.exe`)
- **Arguments**: `-NoProfile -NonInteractive -Command`
- **Process Control**: `taskkill /F /T /PID` for process tree termination

Example agent command execution:
```typescript
// Cross-platform shell execution
const { shell, args } = getShellConfig();
// On Windows: { shell: "C:\\Windows\\System32\\powershell.exe", args: ["-NoProfile", "-NonInteractive", "-Command"] }
// On Unix:    { shell: "/bin/sh", args: ["-c"] }
```

### Windows Commands Available

The agent can run any Windows command, utility, or script:

**System Information**:
```powershell
Get-ComputerInfo
systeminfo
ipconfig /all
```

**File Operations**:
```powershell
Get-ChildItem -Recurse
Copy-Item -Path "source" -Destination "dest"
Remove-Item -Path "file.txt" -Force
```

**Process Management**:
```powershell
Get-Process
Stop-Process -Name "notepad"
Start-Process "notepad.exe"
```

**Network Operations**:
```powershell
Test-Connection google.com
Get-NetAdapter
New-NetFirewallRule -DisplayName "Allow Port 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

**Automation Examples**:
```powershell
# Schedule tasks
schtasks /Create /TN "MyTask" /TR "notepad.exe" /SC DAILY /ST 09:00

# Registry operations
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion"

# Service management
Get-Service
Start-Service -Name "wuauserv"
```

### Command Chains

PowerShell supports command chaining with `;` or `&`:
```powershell
cd C:\Projects; npm install; npm test
```

Unlike bash's `&&`, PowerShell uses different operators:
- `;` - Run commands sequentially (ignore failures)
- `&&` - Run next command only if previous succeeded (PowerShell 7+)
- `||` - Run next command only if previous failed (PowerShell 7+)

### Troubleshooting Shell Execution

**PowerShell Not Found**:
- Moltbot looks for PowerShell at `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`
- Falls back to `powershell.exe` in PATH

**Execution Policy Issues**:
```powershell
# Check current policy
Get-ExecutionPolicy

# Allow scripts (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Command Output Issues**:
- Some Windows utilities write directly to console via WriteConsole API
- PowerShell properly captures and redirects this output (unlike cmd.exe with piped stdio)
- If output is missing, try running the command directly in PowerShell to verify

## Troubleshooting

### Permission Issues

If you see "Access is denied" when installing the gateway service:

1. Run PowerShell as **Administrator**
2. Or install without the daemon: `moltbot onboard --no-daemon`

### Task Scheduler

View your installed task:

```powershell
schtasks /Query /TN "Moltbot Gateway" /V /FO LIST
```

The task script is located at: `%USERPROFILE%\.clawdbot\gateway.cmd`

### Port Conflicts

Check if gateway port is in use:

```powershell
netstat -ano | findstr :18789
```

### Firewall

If connecting from another machine on your network, ensure Windows Firewall allows the gateway port (default: 18789).

## WSL2 Alternative (Advanced)

For users who prefer a Linux environment, WSL2 is supported as an alternative to native Windows:

### Install WSL2 + Ubuntu

Open PowerShell (Admin):

```powershell
wsl --install
# Or pick a distro explicitly:
wsl --list --online
wsl --install -d Ubuntu-24.04
```

Reboot if Windows asks.

### Enable systemd (required for gateway install)

In your WSL terminal:

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

Then from PowerShell:

```powershell
wsl --shutdown
```

Re-open Ubuntu, then verify:

```bash
systemctl --user status
```

### Install Moltbot (inside WSL)

Follow the Linux Getting Started flow inside WSL - see [Getting Started](/start/getting-started) for details.

### Expose WSL services over LAN (portproxy)

WSL has its own virtual network. If another machine needs to reach a service running **inside WSL**, you must forward a Windows port to the current WSL IP. The WSL IP changes after restarts, so you may need to refresh the forwarding rule.

Example (PowerShell **as Administrator**):

```powershell
$Distro = "Ubuntu-24.04"
$ListenPort = 2222
$TargetPort = 22

$WslIp = (wsl -d $Distro -- hostname -I).Trim().Split(" ")[0]
if (-not $WslIp) { throw "WSL IP not found." }

netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=$ListenPort `
  connectaddress=$WslIp connectport=$TargetPort
```

Allow the port through Windows Firewall (one-time):

```powershell
New-NetFirewallRule -DisplayName "WSL SSH $ListenPort" -Direction Inbound `
  -Protocol TCP -LocalPort $ListenPort -Action Allow
```

Refresh the portproxy after WSL restarts:

```powershell
netsh interface portproxy delete v4tov4 listenport=$ListenPort listenaddress=0.0.0.0 | Out-Null
netsh interface portproxy add v4tov4 listenport=$ListenPort listenaddress=0.0.0.0 `
  connectaddress=$WslIp connectport=$TargetPort | Out-Null
```

## Windows Companion App

We do not have a Windows companion app yet. Contributions are welcome if you want to help make it happen.
