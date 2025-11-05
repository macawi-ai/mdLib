# Pre-compiled Binaries

**The fastest way to get started with Strigoi - no compilation required.**

---

## Why Use Pre-compiled Binaries?

✅ **No build dependencies** - No need for Go, Rust, or any compiler toolchain
✅ **Instant deployment** - Download, verify, install in 60 seconds
✅ **Official releases** - Signed binaries from Macawi AI GitHub releases
✅ **Multi-architecture** - AMD64 (x86_64) and ARM64 (Raspberry Pi, Apple Silicon) supported

**Perfect for**: Quick evaluation, air-gapped environments, production deployment

---

## Supported Platforms

| Architecture | Operating System | Binary Name |
|--------------|------------------|-------------|
| **AMD64** (x86_64) | Linux | `strigoi-linux-amd64` |
| **ARM64** (aarch64) | Linux (Raspberry Pi, etc.) | `strigoi-linux-arm64` |
| **macOS** | Intel & Apple Silicon | `strigoi-darwin-universal` |

---

## Quick Start: AMD64 (Most Common)

### 1. Download Latest Release

```bash
# Download binary
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64

# Download checksum for verification
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64.sha256
```

### 2. Verify Checksum (Recommended)

```bash
# Verify SHA256 checksum
sha256sum -c strigoi-linux-amd64.sha256

# Expected output:
# strigoi-linux-amd64: OK
```

**Why verify?** Ensures binary integrity and authenticity. Critical for production deployments.

### 3. Install Binary

```bash
# Make executable
chmod +x strigoi-linux-amd64

# Install to system path (requires sudo)
sudo mv strigoi-linux-amd64 /usr/local/bin/strigoi

# OR install to user bin (no sudo)
mkdir -p ~/.local/bin
mv strigoi-linux-amd64 ~/.local/bin/strigoi
export PATH="$PATH:$HOME/.local/bin"  # Add to ~/.bashrc for persistence
```

### 4. Verify Installation

```bash
# Check version
strigoi --version

# Expected output:
# Strigoi v1.0.0-rc1 (build: 2025-01-15T12:34:56Z)
```

**Done!** Strigoi CLI is ready. Proceed to [Quick Start Guide](../quick-start.md).

---

## ARM64 Installation (Raspberry Pi, ARM Servers)

### 1. Download ARM64 Binary

```bash
# Download binary
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-arm64

# Download checksum
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-arm64.sha256
```

### 2. Verify & Install

```bash
# Verify checksum
sha256sum -c strigoi-linux-arm64.sha256

# Make executable
chmod +x strigoi-linux-arm64

# Install to system path
sudo mv strigoi-linux-arm64 /usr/local/bin/strigoi

# Verify installation
strigoi --version
```

**See also**: [ARM64 Installation Guide](./arm64.md) for Raspberry Pi-specific resource configuration.

---

## macOS Installation (Intel & Apple Silicon)

### 1. Download Universal Binary

```bash
# Download binary
curl -L https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-darwin-universal \
  -o strigoi-darwin-universal

# Download checksum
curl -L https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-darwin-universal.sha256 \
  -o strigoi-darwin-universal.sha256
```

### 2. Verify & Install

```bash
# Verify checksum
shasum -a 256 -c strigoi-darwin-universal.sha256

# Make executable
chmod +x strigoi-darwin-universal

# Install to /usr/local/bin
sudo mv strigoi-darwin-universal /usr/local/bin/strigoi

# Verify installation
strigoi --version
```

**Note**: macOS may show "unidentified developer" warning. Allow in System Preferences → Security & Privacy.

---

## Air-Gapped / Offline Installation

For environments without internet access:

### 1. Download on Connected System

```bash
# Download all required files
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64.sha256
```

### 2. Transfer to Air-Gapped System

```bash
# Using USB drive
cp strigoi-linux-amd64* /media/usb-drive/

# Or using SCP
scp strigoi-linux-amd64* user@air-gapped-host:/tmp/
```

### 3. Install on Air-Gapped System

```bash
# Verify checksum
sha256sum -c strigoi-linux-amd64.sha256

# Install
chmod +x strigoi-linux-amd64
sudo mv strigoi-linux-amd64 /usr/local/bin/strigoi

# Verify
strigoi --version
```

---

## Version-Specific Downloads

To download a specific version instead of latest:

```bash
# Replace VERSION with desired version (e.g., v1.0.0-rc1)
VERSION=v1.0.0-rc1

# AMD64
wget https://github.com/macawi-ai/Strigoi/releases/download/$VERSION/strigoi-linux-amd64
wget https://github.com/macawi-ai/Strigoi/releases/download/$VERSION/strigoi-linux-amd64.sha256

# ARM64
wget https://github.com/macawi-ai/Strigoi/releases/download/$VERSION/strigoi-linux-arm64
wget https://github.com/macawi-ai/Strigoi/releases/download/$VERSION/strigoi-linux-arm64.sha256
```

---

## Upgrading to Newer Version

```bash
# Download new version
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64

# Verify checksum
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64.sha256
sha256sum -c strigoi-linux-amd64.sha256

# Replace existing binary
chmod +x strigoi-linux-amd64
sudo mv strigoi-linux-amd64 /usr/local/bin/strigoi

# Verify new version
strigoi --version
```

---

## Troubleshooting

### Binary Won't Execute

```bash
# Check file permissions
ls -l /usr/local/bin/strigoi

# Should show: -rwxr-xr-x (executable)
# If not:
chmod +x /usr/local/bin/strigoi
```

### "Command not found"

```bash
# Check if binary is in PATH
which strigoi

# If not found, add to PATH:
export PATH="$PATH:/usr/local/bin"

# Make permanent:
echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Checksum Verification Fails

```bash
# Re-download binary (may have corrupted during download)
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64

# Verify again
sha256sum -c strigoi-linux-amd64.sha256
```

**If still fails**: Report to [GitHub Issues](https://github.com/macawi-ai/Strigoi/issues) - possible release integrity issue.

---

## Next Steps

**After installing the CLI binary**:

1. **Connect to Platform**: [AMD64 Installation](./amd64.md) or [ARM64 Installation](./arm64.md) - Deploy backend services
2. **Run First Scan**: [Quick Start Guide](../quick-start.md) - Start scanning in 5 minutes
3. **Explore Demos**: [5-Minute Demo](../../quick-demo.md) - See Strigoi in action

---

## Release Notes

View full release notes and changelogs at:
👉 **[https://github.com/macawi-ai/Strigoi/releases](https://github.com/macawi-ai/Strigoi/releases)**

---

*Pre-compiled binaries are the fastest path from download to deployment.*
*Official releases signed by Macawi AI.*
