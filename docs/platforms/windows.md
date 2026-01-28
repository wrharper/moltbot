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
