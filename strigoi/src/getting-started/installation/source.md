# Building from Source

**For developers, contributors, and users who need the latest features.**

---

## When to Build from Source

**Build from source when you need**:
- ✅ Latest unreleased features from `main` branch
- ✅ Custom modifications or patches
- ✅ Development environment for contributing
- ✅ Platform not covered by pre-compiled binaries
- ✅ Maximum security (verify and build yourself)

**Use pre-compiled binaries when**:
- ❌ You just want to use Strigoi (not develop it)
- ❌ You're deploying to production quickly
- ❌ You don't have Go installed

👉 **For most users**: [Pre-compiled Binaries](./binaries.md) are faster and easier.

---

## Prerequisites

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Go** | 1.21+ | 1.22+ |
| **Git** | 2.30+ | Latest |
| **Make** | 4.3+ | Latest (optional) |
| **Container Runtime** | Podman or Docker | Podman |

### Install Prerequisites

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install -y git golang-1.22 make podman podman-compose
```

**macOS**:
```bash
brew install go git make podman podman-compose
```

**Verify Installation**:
```bash
go version       # Should show go1.21 or higher
git --version
make --version   # Optional but helpful
```

---

## Quick Build

### 1. Clone Repository

```bash
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi
```

### 2. Build CLI Binary

```bash
# Build with version info
VERSION=$(git describe --tags --always --dirty || echo "dev")
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

go build -ldflags "-X main.version=$VERSION -X main.build=$BUILD_TIME" \
  -o strigoi ./cmd/strigoi
```

### 3. Verify Build

```bash
./strigoi --version

# Expected output:
# Strigoi v1.0.0-rc1-5-gABCDEF (build: 2025-01-15T12:34:56Z)
```

### 4. Install to PATH

```bash
# Install to user bin
mkdir -p ~/.local/bin
cp strigoi ~/.local/bin/
chmod +x ~/.local/bin/strigoi

# Add to PATH (if not already)
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

---

## Development Workflow

### Running Tests

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific package tests
go test ./internal/probe
```

### Running Linters

```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run linters
golangci-lint run
```

### Building for Different Architectures

```bash
# AMD64 Linux
GOOS=linux GOARCH=amd64 go build -o strigoi-linux-amd64 ./cmd/strigoi

# ARM64 Linux
GOOS=linux GOARCH=arm64 go build -o strigoi-linux-arm64 ./cmd/strigoi

# macOS Universal (requires macOS build machine)
GOOS=darwin GOARCH=amd64 go build -o strigoi-darwin-amd64 ./cmd/strigoi
GOOS=darwin GOARCH=arm64 go build -o strigoi-darwin-arm64 ./cmd/strigoi
lipo -create -output strigoi-darwin-universal strigoi-darwin-amd64 strigoi-darwin-arm64
```

---

## Building Platform Services

### Option 1: Using Provided Scripts

```bash
# Build all platform containers
cd strigoi-platform
make build

# Or manually with podman-compose
podman-compose build
```

### Option 2: Manual Container Builds

```bash
# Intel Analyzer
cd strigoi-platform/intel-analyzer
podman build -t strigoi-intel-analyzer:latest .

# Vuln Classifier
cd ../vuln-classifier
podman build -t strigoi-vuln-classifier:latest .

# EventDB
cd ../eventdb
podman build -t strigoi-eventdb:latest .
```

---

## Development Tips

### Hot Reload During Development

```bash
# Install air for hot reload
go install github.com/cosmtrek/air@latest

# Run with hot reload
air
```

### Enable Debug Logging

```bash
# Set log level via environment
LOG_LEVEL=debug ./strigoi probe east /path/to/target
```

### Running Locally Built Platform

```bash
# Use local images in compose.yml
# Edit compose.yml and change image: to use locally built tags

cd strigoi-platform
podman-compose up -d
```

---

## Contributing

### Before Submitting Pull Requests

1. **Run tests**: `go test ./...`
2. **Run linters**: `golangci-lint run`
3. **Format code**: `go fmt ./...`
4. **Update documentation**: Modify relevant .md files
5. **Sign commits**: `git commit -s` (Developer Certificate of Origin)

### Branching Strategy

- **main**: Stable development branch
- **release/vX.Y.Z**: Release branches
- **feature/your-feature**: Feature development
- **fix/bug-description**: Bug fixes

---

## Troubleshooting

### "go: cannot find module"

```bash
# Initialize module cache
go mod download
go mod tidy
```

### Build Fails with "undefined: X"

```bash
# Ensure you're on a supported Go version
go version  # Must be 1.21+

# Clean build cache
go clean -cache
go build ./cmd/strigoi
```

### Cross-compilation Fails

```bash
# Install cross-compilation tools
go get -u golang.org/x/sys/...

# Ensure CGO is disabled for static binaries
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/strigoi
```

---

## Next Steps

After building from source:

1. **Run Your First Scan**: [Quick Start Guide](../quick-start.md)
2. **Explore Development**: [Architecture Overview](../../architecture/overview.md)
3. **Contribute**: [Contributing Guide](../../appendix/contributing.md)

---

*Building from source gives you maximum flexibility and control.*
*Perfect for development, customization, and staying on the cutting edge.*
