# Vulnerable MCP Examples

**Learn AI/LLM security by testing against intentionally vulnerable systems.**

---

## ⚠️ WARNING: INTENTIONALLY VULNERABLE CODE

These MCP servers contain **deliberate security vulnerabilities** for testing and demonstration purposes.

**🚨 DO NOT USE IN PRODUCTION 🚨**
**🚨 DO NOT EXPOSE TO NETWORKS 🚨**
**🚨 FOR LOCAL TESTING ONLY 🚨**

---

## Purpose

These examples demonstrate common vulnerabilities in MCP (Model Context Protocol) servers that connect to LLMs like Claude, ChatGPT, and Gemini. They serve as:

1. **Test targets** for Strigoi's directional probing
2. **Training material** for understanding AI/LLM security risks
3. **Demo assets** for showcasing Strigoi's capabilities to customers
4. **Educational examples** for security teams learning AI vulnerabilities

**Real-world relevance**: These vulnerabilities exist in production AI systems today. Banks and enterprises unknowingly deploy similar code when adding AI features.

---

## The Three Insecure MCPs

### 1. 🗄️ mcp-sqlite - SQL Injection Paradise

**What it does**: Provides Claude Code access to a SQLite database of US states and capitals.

**Intentional vulnerabilities**:
- ❌ SQL injection via string concatenation
- ❌ Arbitrary SQL execution allowed
- ❌ No authentication or access controls
- ❌ Verbose error messages exposing database paths
- ❌ Hardcoded API keys in source
- ❌ Plaintext passwords in database

**Banking impact**: Similar vulnerabilities in production could expose:
- Customer PII (names, SSNs, account numbers)
- Transaction history
- Internal credentials

👉 **[SQL Injection Deep Dive](./mcp-sqlite.md)**

---

### 2. 📁 mcp-filesystem - Directory Traversal Bonanza

**What it does**: Provides Claude Code access to read/write files on the filesystem.

**Intentional vulnerabilities**:
- ❌ Path traversal attacks (`../../../etc/passwd`)
- ❌ No path sanitization or validation
- ❌ Arbitrary file read/write access
- ❌ Symlink following enabled
- ❌ No access control lists

**Banking impact**: Similar vulnerabilities could allow:
- Reading SSH keys, database credentials
- Writing to system configuration files
- Accessing customer data files

👉 **[Path Traversal Deep Dive](./mcp-filesystem.md)**

---

### 3. 🌐 mcp-http-api - SSRF & Secrets Galore

**What it does**: Provides Claude Code ability to make HTTP requests to external APIs.

**Intentional vulnerabilities**:
- ❌ **7 hardcoded API keys** (AWS, OpenAI, Google, Stripe, etc.)
- ❌ SSRF to internal networks (192.168.x.x, localhost)
- ❌ No URL validation or allowlisting
- ❌ Logs sensitive data (API keys, tokens)
- ❌ No rate limiting

**Banking impact**: Similar vulnerabilities could expose:
- Core banking API credentials
- Payment processor keys ($10K-$100K+ fraud)
- Internal network topology (reconnaissance for attacks)

👉 **[SSRF & Secrets Deep Dive](./mcp-http-api.md)**

---

## Quick Start

### Install All Three MCPs (Recommended)

```bash
# Clone Strigoi repository
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi/examples/insecure-mcps

# Install all vulnerable MCPs
./install-all.sh
```

**This will**:
1. Create Python virtual environments for each MCP
2. Install required dependencies
3. Set up test databases and files
4. Configure Claude Code integration
5. Run validation tests

**Installation time**: ~2 minutes

---

## Verify Installation

```bash
# Check MCP servers are configured
strigoi check mcp

# Expected output:
# ✓ MCP: insecure-sqlite
# ✓ MCP: insecure-filesystem
# ✓ MCP: insecure-http-api
```

---

## Test with Strigoi

### Scan All MCPs (Comprehensive)

```bash
# From Strigoi repository
cd ~/.strigoi/mcps

# Scan data flows (finds hardcoded secrets)
strigoi probe east .

# Scan authentication (finds missing auth)
strigoi probe west .

# Scan dependencies (finds vulnerable libraries)
strigoi probe south .

# Scan external interfaces (finds exposed tools)
strigoi probe north .
```

### Expected Findings

**mcp-sqlite**:
- SQL injection patterns
- Hardcoded API key
- Missing authentication
- Verbose error messages

**mcp-filesystem**:
- Unsafe file operations
- Missing path validation
- No access controls

**mcp-http-api**:
- 7 hardcoded API keys
- SSRF patterns
- No URL validation
- Missing rate limiting

---

## Demo Flow (for Sales/Training)

### Step 1: Show Clean State

```bash
strigoi check mcp  # No insecure MCPs
```

### Step 2: Install Examples

```bash
cd Strigoi/examples/insecure-mcps && ./install-all.sh
```

### Step 3: Test They Work

```bash
# Ask Claude Code: "What's the capital of Wisconsin?"
# Uses mcp-sqlite to query database
```

### Step 4: Scan with Strigoi

```bash
strigoi probe east ~/.strigoi/mcps/  # Find hardcoded secrets
```

### Step 5: Show Findings

- Point to specific vulnerabilities in output
- Explain MITRE ATLAS mapping
- Demonstrate severity scoring (CRITICAL/HIGH/MEDIUM/LOW)
- Show remediation guidance

### Step 6: Clean Up

```bash
./uninstall-all.sh  # Back to clean state
```

---

## Uninstallation

To remove all insecure MCPs:

```bash
cd Strigoi/examples/insecure-mcps
./uninstall-all.sh
```

**This will**:
1. Remove all Python virtual environments
2. Remove test data
3. Restore original `~/.claude.json` (from backup)
4. Clean up `~/.strigoi/mcps/` directory

---

## Educational Value

These examples teach:

1. **Why MCP security matters**: LLMs with insecure tools = compromised systems
2. **Common vulnerability patterns**: What developers get wrong when building AI features
3. **Detection techniques**: How Strigoi discovers issues before they become breaches
4. **Remediation strategies**: How to fix each vulnerability class

**Target audiences**:
- Bank security teams preparing for AI deployments
- Developers building MCP servers
- Auditors assessing AI systems
- Executives understanding AI/LLM risks

---

## Architecture

### Installation Layout

```
~/.strigoi/mcps/
├── mcp-sqlite/
│   ├── venv/              # Python virtual environment
│   ├── server.py          # Vulnerable MCP server
│   ├── states.db          # Test database
│   └── start.sh           # Startup script
├── mcp-filesystem/
│   ├── venv/
│   ├── server.py
│   ├── test-files/        # Test directory
│   └── start.sh
└── mcp-http-api/
    ├── venv/
    ├── server.py
    ├── secrets.json       # Intentionally committed secrets!
    └── start.sh
```

---

## Next Steps

### For Security Teams:
1. **Install Vulnerable MCPs**: Use as training targets
2. **Scan with Strigoi**: Learn directional probing framework
3. **Study Findings**: Understand MITRE ATLAS mapping
4. **Apply to Production**: Scan real AI systems for similar issues

### For Developers:
1. **Explore Source Code**: See what NOT to do
2. **Test Detection**: Verify Strigoi finds each vulnerability
3. **Learn Remediation**: Study how to fix each issue
4. **Build Securely**: Apply lessons to your MCP servers

### For Executives:
1. **Watch Demo**: See vulnerability discovery in action
2. **Understand Risks**: Learn banking impact of AI vulnerabilities
3. **Assess Production**: Ensure your AI systems are scanned before deployment

---

*These examples follow Sister Gemini's 2π-minimal regulatory variety principles.*
*Three fundamental vulnerability classes, one install script, clean uninstall, self-contained.*
