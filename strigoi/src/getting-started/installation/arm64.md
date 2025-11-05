# ARM64 Installation

**Complete guide for ARM-based systems including Raspberry Pi, NanoPi, Orange Pi, and ARM servers.**

---

## Supported Devices

### **Tested & Recommended** ✅

| Device | RAM | CPU | Performance |
|--------|-----|-----|-------------|
| **Raspberry Pi 5** | 8GB | Quad-core ARM | Excellent |
| **Raspberry Pi 4** | 4GB/8GB | Quad-core ARM | Good |
| **NanoPi R6S** | 8GB | RK3588S | Excellent |
| **Orange Pi 5** | 16GB | RK3588S | Outstanding |
| **Apple Silicon** | 8GB+ | M1/M2/M3 | Outstanding |

### **Minimum Requirements**

- **CPU**: ARM64 (aarch64) quad-core or better
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 16GB minimum, 32GB recommended
- **OS**: Ubuntu 22.04/24.04 ARM64, Raspberry Pi OS 64-bit, Debian 12 ARM64

---

## Quick Start: Pre-compiled Binary (Fastest)

**No Go compiler needed!**

```bash
# Download ARM64 binary
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-arm64

# Verify checksum
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-arm64.sha256
sha256sum -c strigoi-linux-arm64.sha256

# Install
chmod +x strigoi-linux-arm64
sudo mv strigoi-linux-arm64 /usr/local/bin/strigoi

# Verify
strigoi --version
```

**Done!** CLI ready. Now deploy platform services (see below).

---

## Full Installation: Build from Source

### 1. Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y git golang-1.22 podman podman-compose curl

# Verify Go installation
go version  # Should show go1.22 or higher
```

### 2. Clone Repository

```bash
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi
```

### 3. Run Installer (Auto-Detects ARM64!)

```bash
# Full installation (CLI + Platform)
./install.sh --yes

# OR CLI only
./install.sh --mode cli --yes
```

**The installer automatically detects ARM64 and builds optimized binaries!** 🦊✨

---

## ARM64-Specific Resource Configuration

ARM devices have limited RAM compared to servers. Configure resource limits **before** starting platform services:

### **Raspberry Pi 4 (4GB RAM)**

```bash
# Create resource limits file
cat > ~/Strigoi/strigoi-platform/.env << EOF
# ARM64 Resource Limits for Raspberry Pi 4 (4GB)
FLEET_MANAGER_MEM_LIMIT=256m
FLEET_MANAGER_CPU_SHARES=512

TIMESCALEDB_MEM_LIMIT=512m
TIMESCALEDB_CPU_SHARES=1024

STRIGOI_HOME=$HOME/Strigoi
EOF
```

### **Raspberry Pi 5 / NanoPi R6S (8GB RAM)**

```bash
cat > ~/Strigoi/strigoi-platform/.env << EOF
# ARM64 Resource Limits for High-Memory Devices
FLEET_MANAGER_MEM_LIMIT=512m
FLEET_MANAGER_CPU_SHARES=1024

TIMESCALEDB_MEM_LIMIT=1g
TIMESCALEDB_CPU_SHARES=2048

STRIGOI_HOME=$HOME/Strigoi
EOF
```

### **Orange Pi 5 (16GB RAM - Full Performance)**

```bash
cat > ~/Strigoi/strigoi-platform/.env << EOF
# No resource limits needed - use defaults!
STRIGOI_HOME=$HOME/Strigoi
EOF
```

---

## Starting Platform Services

```bash
cd ~/Strigoi/strigoi-platform

# Start all services
podman-compose up -d

# Check service health
podman-compose ps

# View logs
podman-compose logs -f
```

### **Expected Startup Time**

| Device | Container Startup | Full Health Check |
|--------|-------------------|-------------------|
| **Raspberry Pi 4 (4GB)** | ~45-60 seconds | ~90 seconds |
| **Raspberry Pi 5 (8GB)** | ~30-45 seconds | ~60 seconds |
| **NanoPi R6S (8GB)** | ~25-35 seconds | ~50 seconds |
| **Orange Pi 5 (16GB)** | ~20-30 seconds | ~45 seconds |

---

## Verification

```bash
# Test CLI connectivity
strigoi platform health

# Check NATS
curl -s http://localhost:8222/varz | jq '.now'

# Check Fleet Manager / EventDB
curl -s http://localhost:8082/health

# Check TimescaleDB
podman exec strigoi-timescaledb psql -U strigoi -d strigoi_events -c "SELECT version();"
```

---

## Performance Tuning for ARM

### 1. Enable Swap on Low-Memory Devices

```bash
# Add 2GB swap (Raspberry Pi 4GB)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. Use SSD Instead of microSD

**Problem**: microSD cards are slow, causing container startup delays

**Solution**: Boot from USB 3.0 SSD

- **Raspberry Pi 4**: Enable USB boot via `raspi-config`
- **Raspberry Pi 5**: Native NVMe support
- **Recommended**: Samsung T7 or similar USB 3.0 SSD

### 3. Reduce PostgreSQL Shared Buffers

```bash
# For 4GB RAM devices
podman exec -it strigoi-timescaledb psql -U strigoi -d strigoi_events -c \
  "ALTER SYSTEM SET shared_buffers = '128MB';"

# For 8GB+ RAM devices
podman exec -it strigoi-timescaledb psql -U strigoi -d strigoi_events -c \
  "ALTER SYSTEM SET shared_buffers = '256MB';"

# Restart TimescaleDB
podman restart strigoi-timescaledb
```

---

## Common ARM64 Issues & Solutions

### **Issue: "Out of Memory" Errors**

**Solution**: Reduce resource limits or enable swap

```bash
# Reduce limits even more
export FLEET_MANAGER_MEM_LIMIT=128m
export TIMESCALEDB_MEM_LIMIT=256m

podman-compose down
podman-compose up -d
```

### **Issue: Slow Container Startup**

**Solution**: SD card performance bottleneck

- Use **SSD via USB 3.0** instead of microSD
- Enable boot from SSD on Raspberry Pi 4/5
- Use high-quality microSD (A2-rated minimum)

### **Issue: Docker Buildx Not Available**

**Solution**: Podman supports multi-arch natively!

```bash
# Use Podman instead
podman manifest create strigoi-multiarch
podman build --platform linux/amd64,linux/arm64 -t strigoi-multiarch .
```

---

## Monitoring ARM64 Performance

### **Check CPU/Memory Usage**

```bash
# Container resource usage
podman stats

# System resource usage
htop  # or: sudo apt install htop

# Temperature monitoring (Raspberry Pi)
vcgencmd measure_temp
```

---

## Multi-Architecture Container Images

Strigoi uses **manifest lists** (fat manifests) published to `ghcr.io/macawi-ai/strigoi/*`:

```bash
# Pull images (automatically selects ARM64)
podman pull ghcr.io/macawi-ai/strigoi/intel-analyzer:main
podman pull ghcr.io/macawi-ai/strigoi/vuln-classifier:main
podman pull ghcr.io/macawi-ai/strigoi/eventdb:main

# Inspect architecture
podman inspect ghcr.io/macawi-ai/strigoi/intel-analyzer:main | jq '.[0].Architecture'
# Output: arm64
```

---

## Updating Strigoi on ARM64

```bash
cd ~/Strigoi
git pull

# Rebuild & reinstall
./install.sh --yes

# Restart platform
cd strigoi-platform
podman-compose down
podman-compose up -d
```

**Container images automatically pull ARM64 variants from GitHub Container Registry!**

---

## FAQ

### **Q: Can I run Strigoi on Raspberry Pi 3?**

A: Pi 3 uses ARMv7 (32-bit). While technically possible, we recommend upgrading to **Raspberry Pi 4/5** with ARM64 OS for best performance.

### **Q: Does Strigoi work on Apple Silicon (M1/M2/M3)?**

A: Yes! Apple Silicon is ARM64. Use macOS installation instructions, but ARM64 optimizations apply.

### **Q: What about RISC-V?**

A: Not currently supported. Go supports RISC-V experimentally - contributions welcome! 🦊

### **Q: Can I cross-compile from AMD64 to ARM64?**

A: Yes! Use Docker buildx:

```bash
docker buildx build --platform linux/arm64 \
  -f strigoi-platform/intel-analyzer/Dockerfile \
  -t strigoi-intel:arm64 ./strigoi-platform
```

---

## Next Steps

After successful ARM64 installation:

1. **Run Your First Scan**: [Quick Start Guide](../quick-start.md)
2. **Explore Demos**: [5-Minute Demo](../../quick-demo.md)
3. **Test with Vulnerable MCPs**: [Vulnerable MCP Examples](../../testing/vulnerable-mcps/README.md)

---

*ARM64 support brings Strigoi to tactical edge deployments.*
*From Raspberry Pi homelab to NanoPi clusters - native ARM64 speed, no emulation.*
