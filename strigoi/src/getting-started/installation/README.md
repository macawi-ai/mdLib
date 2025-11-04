# Installation

**Get Strigoi running on your system in minutes.**

---

## Choose Your Installation Path

Strigoi supports multiple installation options to fit your deployment needs:

### 🚀 [Pre-compiled Binaries](./binaries.md) (Fastest!)
Download and run immediately—no compilation needed.
- ✅ **AMD64**: Linux, macOS (Intel), Windows
- ✅ **ARM64**: Linux, macOS (Apple Silicon), Raspberry Pi 4/5
- ✅ **ARMv7**: Raspberry Pi 3

**Best for**: Quick evaluation, production deployment, systems without Go installed.

---

### 🔨 [Build from Source](./source.md)
Compile Strigoi yourself for maximum flexibility.
- Requires Go 1.21+
- Full control over build flags
- Latest development features

**Best for**: Developers, contributors, customization needs.

---

### 💻 [AMD64 Installation](./amd64.md)
Detailed guide for x86_64 systems (standard servers, cloud VMs).

**Best for**: Enterprise deployments, data centers, cloud infrastructure.

---

### 🍓 [ARM64 Installation](./arm64.md)
Comprehensive guide for ARM-based devices.
- Raspberry Pi 4/5 (tested)
- NanoPi R6S (tested)
- Orange Pi 5 (tested)
- Other ARM64 systems

**Best for**: Edge deployments, branch offices, low-power setups.

---

## Installation Modes

Strigoi has three deployment modes:

| Mode | Components | Use Case |
|------|------------|----------|
| **full** | CLI + Platform services | Complete local installation (default) |
| **cli** | Thin client only | Connect to remote platform |
| **platform** | Platform services only | Centralized platform deployment |

### Full Installation (Recommended)

Complete installation with all components:

```bash
git clone https://github.com/macawi-ai/strigoi.git
cd strigoi
./install.sh --yes
```

**Installs**:
- Strigoi CLI binary (`~/strigoi/bin/strigoi`)
- NATS JetStream (event streaming)
- TimescaleDB (event storage)
- Fleet Manager (web dashboard)
- Intel Analyzer (directional aggregation)
- Vuln Classifier (MITRE ATLAS rules)
- EventDB (REST + NATS API)

**Access**:
- CLI: `strigoi`
- Web Dashboard: http://localhost:8081
- API: http://localhost:8081/api/v1

### CLI Only Installation

Just the thin client (connects to remote platform):

```bash
git clone https://github.com/macawi-ai/strigoi.git
cd strigoi
./install.sh --mode cli --yes
```

**Use case**: Multiple analysts connecting to centralized platform.

### Platform Only Installation

Just the platform services (no CLI):

```bash
git clone https://github.com/macawi-ai/strigoi.git
cd strigoi
./install.sh --mode platform --yes
```

**Use case**: Central server that multiple CLI clients connect to.

---

## System Requirements

### Minimum Requirements

**For CLI Only**:
- **CPU**: Any x86_64 or ARM64
- **RAM**: 128MB
- **Storage**: 50MB
- **OS**: Linux, macOS, Windows

**For Full Platform**:
- **CPU**: 4 cores (2 minimum)
- **RAM**: 8GB (4GB minimum)
- **Storage**: 20GB (for logs + database)
- **OS**: Linux (Ubuntu 22.04+, Debian 12+, RHEL 8+)

### Recommended Specifications

**Production Deployment**:
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Storage**: 100GB+ SSD
- **Network**: 1Gbps+

---

## Quick Start

### Option 1: Pre-compiled Binary (5 minutes)

```bash
# Download latest release
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64

# Make executable
chmod +x strigoi-linux-amd64

# Run
./strigoi-linux-amd64
```

### Option 2: Build from Source (10 minutes)

```bash
# Clone repository
git clone https://github.com/macawi-ai/strigoi.git
cd strigoi

# Full installation
./install.sh --yes

# Start using Strigoi
strigoi
```

---

## Platform Architecture

When you install the full platform, you get:

```
┌────────────────────────────────────────────────────────┐
│                   Strigoi Platform                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │  NATS        │  │ TimescaleDB  │  │ Prometheus  │ │
│  │  JetStream   │  │ (Events)     │  │ (Metrics)   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                  │                  │        │
│  ┌──────▼──────────────────▼──────────────────▼────┐  │
│  │          Fleet Manager (Web UI + API)           │  │
│  │          http://localhost:8081                   │  │
│  └──────────────────────────────────────────────────┘  │
│         ▲                                               │
│  ┌──────┴──────┐  ┌──────────────┐  ┌─────────────┐  │
│  │   Intel     │  │    Vuln      │  │   EventDB   │  │
│  │  Analyzer   │  │  Classifier  │  │   (API)     │  │
│  └─────────────┘  └──────────────┘  └─────────────┘  │
│                                                         │
└────────────────────────────────────────────────────────┘
         ▲
         │
    ┌────┴─────┐
    │ Strigoi  │
    │   CLI    │
    └──────────┘
```

---

## Next Steps

**Choose your installation method**:
- 🚀 [Pre-compiled Binaries](./binaries.md) - Fastest path
- 🔨 [Build from Source](./source.md) - Full control
- 💻 [AMD64 Guide](./amd64.md) - Standard servers
- 🍓 [ARM64 Guide](./arm64.md) - Raspberry Pi & ARM devices

**After installation**:
- 📖 [Quick Start Guide](../quick-start.md) - Run your first scan
- 🎯 [First Security Scan](../first-scan.md) - Step-by-step walkthrough
- 🧪 [Vulnerable MCP Examples](../../testing/vulnerable-mcps/README.md) - Test with intentionally vulnerable code

---

**Questions? Issues?**
- Check [Troubleshooting Guide](../../reference/troubleshooting.md)
- Visit [GitHub Issues](https://github.com/macawi-ai/Strigoi/issues)
- Contact [security@macawi.ai](mailto:security@macawi.ai)

---

*Get scanning in minutes, not hours.*
