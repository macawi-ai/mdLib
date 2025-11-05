# AMD64 Installation

**Complete installation guide for x86_64 systems (Intel/AMD processors).**

---

## Prerequisites

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 4GB | 8GB+ |
| **Storage** | 10GB free | 20GB+ free |
| **OS** | Ubuntu 22.04, Debian 12 | Ubuntu 24.04 |
| **Go** | 1.21+ | 1.22+ |
| **Container Runtime** | Podman or Docker | Podman |

---

## Quick Start: Full Installation

The fastest path to a working Strigoi deployment:

```bash
# 1. Clone repository
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi

# 2. Run automated installer
./install.sh --yes

# 3. Verify installation
strigoi --version
strigoi platform health
```

**What this installs**:
- ✅ Strigoi CLI binary (`~/strigoi/bin/strigoi`)
- ✅ Platform services (NATS, TimescaleDB, Intel Analyzer, Vuln Classifier, EventDB)
- ✅ Systemd user service for auto-start
- ✅ PATH configuration for CLI access

**Installation time**: ~3-5 minutes

---

## Installation Modes

Strigoi supports three installation modes:

### Mode 1: Full Installation (Recommended)

**Use when**: You want both CLI and platform on the same machine

```bash
./install.sh --yes
```

### Mode 2: CLI Only

**Use when**: Connecting to remote Strigoi platform

```bash
./install.sh --mode cli --yes
```

### Mode 3: Platform Only

**Use when**: Deploying centralized platform, CLIs elsewhere

```bash
./install.sh --mode platform --yes
```

---

## Manual Installation Steps

If you prefer manual control over the installation process:

### 1. Install Dependencies

```bash
# Update package lists
sudo apt update

# Install Go 1.22
sudo apt install -y golang-1.22

# Install Podman & Compose
sudo apt install -y podman podman-compose

# Verify installations
go version       # Should show go1.22 or higher
podman --version
podman-compose --version
```

### 2. Build CLI Binary

```bash
# Clone repository
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi

# Build binary
VERSION=$(git describe --tags --always --dirty || echo "1.0.0-rc1")
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
go build -ldflags "-X main.version=$VERSION -X main.build=$BUILD_TIME" \
  -o strigoi ./cmd/strigoi

# Install to user bin
mkdir -p ~/.local/bin
cp strigoi ~/.local/bin/
chmod +x ~/.local/bin/strigoi

# Add to PATH
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Deploy Platform Services

```bash
# Navigate to platform directory
cd strigoi-platform

# Start all services
podman-compose up -d

# Check service status
podman-compose ps
```

### 4. Create Systemd Service (Optional)

```bash
# Create systemd user service
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/strigoi-platform.service << 'EOF'
[Unit]
Description=Strigoi Platform Services
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=%h/Strigoi/strigoi-platform
ExecStart=/usr/bin/podman-compose up -d
ExecStop=/usr/bin/podman-compose down
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Enable and start service
systemctl --user daemon-reload
systemctl --user enable strigoi-platform.service
systemctl --user start strigoi-platform.service
```

---

## Verification

### Verify CLI Installation

```bash
# Check version
strigoi --version

# Expected output:
# Strigoi v1.0.0-rc1 (build: 2025-01-15T12:34:56Z)
```

### Verify Platform Health

```bash
# Check platform health
strigoi platform health

# Expected output:
# ✅ Platform Status: healthy
# ✅ Database: connected
# ✅ NATS: connected
```

### Verify Individual Services

```bash
# NATS JetStream
curl -s http://localhost:8222/varz | jq '.now'

# Fleet Manager / EventDB
curl -s http://localhost:8082/health

# TimescaleDB
podman exec strigoi-timescaledb psql -U strigoi -d strigoi_events -c "SELECT version();"
```

---

## Configuration

### Platform Service Endpoints

| Service | Endpoint | Purpose |
|---------|----------|---------|
| **EventDB REST API** | http://localhost:8082 | Event storage & retrieval |
| **NATS JetStream** | nats://localhost:4222 | Event streaming |
| **NATS Monitoring** | http://localhost:8222 | NATS statistics |
| **TimescaleDB** | postgresql://localhost:5433 | Time-series storage |

### Environment Variables

Configure platform behavior via environment file:

```bash
# Create .env file
cat > ~/Strigoi/strigoi-platform/.env << EOF
# NATS Configuration
NATS_URL=nats://localhost:4222

# Database Configuration
DB_HOST=localhost
DB_PORT=5433
DB_USER=strigoi
DB_PASSWORD=strigoi_secure_password
DB_NAME=strigoi_events

# Logging
LOG_LEVEL=info

# Intel Aggregation
WINDOW_SIZE=60
EOF
```

### Connecting to Remote Platform

Edit CLI configuration:

```bash
vi ~/strigoi/config/strigoi.yaml
```

Update platform URLs:

```yaml
platform:
  rest_url: http://remote-host:8082
  nats_url: nats://remote-host:4222
```

---

## Troubleshooting

### "strigoi: command not found"

```bash
# Check PATH includes CLI binary
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Platform Services Won't Start

```bash
# Check container logs
podman-compose logs

# Restart services
systemctl --user restart strigoi-platform
```

### NATS Connection Refused

```bash
# Check NATS container
podman ps | grep nats

# View NATS logs
podman logs strigoi-nats

# Test connectivity
nc -zv localhost 4222
```

### Database Connection Failed

```bash
# Check TimescaleDB container
podman ps | grep timescale

# View database logs
podman logs strigoi-timescaledb

# Test connectivity
nc -zv localhost 5433
```

---

## Uninstallation

```bash
# Using uninstaller
~/strigoi/uninstall.sh

# Manual uninstallation
systemctl --user stop strigoi-platform
systemctl --user disable strigoi-platform
cd ~/Strigoi/strigoi-platform
podman-compose down
rm -rf ~/Strigoi
# Remove PATH entries from ~/.bashrc
```

---

## Next Steps

After successful installation:

1. **Run Your First Scan**: [Quick Start Guide](../quick-start.md)
2. **Explore Demos**: [5-Minute Demo](../../quick-demo.md)
3. **Test with Vulnerable MCPs**: [Vulnerable MCP Examples](../../testing/vulnerable-mcps/README.md)

---

*AMD64 is the most common architecture for servers and workstations.*
*Tested on Ubuntu 22.04/24.04, Debian 12, and compatible Linux distributions.*
