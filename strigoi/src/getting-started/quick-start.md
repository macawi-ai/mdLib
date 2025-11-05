# Quick Start Guide

**Run your first security scan in 5 minutes.**

---

## Prerequisites

**Before starting**, ensure you have:
- ✅ Strigoi CLI installed ([Installation Guide](./installation/README.md))
- ✅ Platform services running (optional for local scans)
- ✅ A target to scan (we'll use vulnerable MCP examples)

**Verify installation**:
```bash
strigoi --version
```

---

## Your First Scan: Finding Real Vulnerabilities

We'll scan an intentionally vulnerable MCP server to see Strigoi in action.

### Step 1: Get Vulnerable Test Server

```bash
# Clone Strigoi repository (contains vulnerable MCP examples)
git clone https://github.com/macawi-ai/Strigoi.git
cd Strigoi/examples/insecure-mcps/mcp-http-api
```

**What's in this MCP?**
- ❌ 7 hardcoded API keys (AWS, OpenAI, Google, Stripe, etc.)
- ❌ SSRF vulnerability (no URL validation)
- ❌ Hardcoded database credentials
- ❌ Missing rate limiting
- ❌ Unencrypted logging

**This is what banks unknowingly deploy when adding AI features.** Strigoi finds these issues.

---

### Step 2: Run Directional Scan

```bash
# Scan data flows and integrations (EAST direction)
strigoi probe east .

# This analyzes:
# - Source code for secrets
# - Configuration files
# - API integration patterns
# - Data flow vulnerabilities
```

**What happens**:
- Strigoi scans files in current directory
- Detects 17+ vulnerability patterns
- Maps findings to MITRE ATLAS
- Assigns severity levels (CRITICAL/HIGH/MEDIUM/LOW)

---

### Step 3: Review Results

**Sample Output**:
```
🔍 Strigoi v1.0.0 - AI/LLM Security Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Target: ./
🧭 Direction: EAST (Data flows & integrations)
⏱️  Scan duration: 2.3 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 CRITICAL FINDINGS (7)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CRITICAL] Hardcoded OpenAI API Key
  File: server.py:7
  Pattern: OPENAI_API_KEY = "sk-proj-abc123def456..."
  MITRE: AML.T0043 (Supply Chain Compromise)
  Risk: API key theft → fraudulent AI API usage
  Fix: Use environment variables or secret management

[CRITICAL] Hardcoded AWS Secret Key
  File: server.py:8
  Pattern: AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/..."
  MITRE: AML.T0043 (Supply Chain Compromise)
  Risk: AWS account compromise → data exfiltration
  Fix: Use IAM roles with temporary credentials

[CRITICAL] SSRF Vulnerability (No URL Validation)
  File: server.py:15
  Pattern: requests.get(url, ...)
  MITRE: AML.T0024 (Adversarial Prompt Injection)
  Risk: Internal network access → credential theft
  Fix: Implement URL allowlist, validate domains

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total findings: 11
  CRITICAL: 7
  HIGH: 3
  MEDIUM: 1

Remediation priority: Fix all CRITICAL findings before deployment
```

**Banking impact**: If deployed to production, these vulnerabilities could cause:
- 💰 **$10K-$100K+** in fraudulent API usage
- 🔓 **$5M-$50M+** in data breach costs (GDPR/CCPA fines)
- 📉 Customer churn and reputational damage

---

## Understanding Directional Probing

Strigoi uses a compass-based security framework:

| Direction | Focus | What It Finds |
|-----------|-------|---------------|
| **NORTH** | External interfaces | Public APIs, exposed endpoints, attack surface |
| **SOUTH** | Dependencies | Vulnerable libraries, supply chain risks |
| **EAST** | Data flows | Secrets, PII, integration vulnerabilities |
| **WEST** | Authentication | Auth bypasses, weak credentials, access control |
| **ALL** | Comprehensive | Complete security assessment (all directions) |

**Example commands**:
```bash
# Scan external attack surface
strigoi probe north /path/to/project

# Check for vulnerable dependencies
strigoi probe south /path/to/project

# Analyze authentication
strigoi probe west /path/to/project

# Comprehensive scan (all directions)
strigoi probe all /path/to/project
```

👉 **Learn more**: [Directional Probing Guide](../user-guide/directional-probing/README.md)

---

## Connecting to Platform Services

If you have Strigoi platform deployed, connect for real-time monitoring:

### Check Platform Health

```bash
strigoi platform health

# Expected output:
# ✅ Platform Status: healthy
# ✅ Database: connected
# ✅ NATS: connected
```

### Stream Live Events

```bash
# Watch security events in real-time
strigoi events tail --follow

# Filter by severity
strigoi events tail --severity CRITICAL

# Stream vulnerability classifications
strigoi intel tail north
```

---

## Next Steps

### **For Security Teams**:
1. **Scan Your AI Systems**: Run `strigoi probe all /path/to/ai/system`
2. **Review Findings**: Prioritize CRITICAL/HIGH vulnerabilities
3. **Remediate**: Follow fix recommendations in scan output
4. **Document**: Generate MITRE ATLAS report for compliance

### **For Developers**:
1. **Pre-Commit Scanning**: Add Strigoi to CI/CD pipeline
2. **Test with Vulnerable MCPs**: [Install Vulnerable Examples](../testing/vulnerable-mcps/installation.md)
3. **Explore Directional Probing**: [North](../user-guide/directional-probing/north.md) | [South](../user-guide/directional-probing/south.md) | [East](../user-guide/directional-probing/east.md) | [West](../user-guide/directional-probing/west.md)

### **For Executives**:
1. **See the Value**: [5-Minute Demo](../quick-demo.md) - Real vulnerability discovery
2. **Understand Use Cases**: [10 Banking Scenarios](./use-cases.md) - Regulatory compliance

---

## Common First-Time Questions

### **Q: How long does a scan take?**

A: **Seconds to minutes** depending on codebase size:
- Small MCP server (500 lines): **~2 seconds**
- Medium project (10K lines): **~30 seconds**
- Large codebase (100K+ lines): **~5 minutes**

### **Q: Can I scan production systems?**

A: **Yes!** Strigoi is read-only and non-invasive:
- ✅ No code execution
- ✅ No network requests
- ✅ Static analysis only
- ✅ Safe for production environments

### **Q: What if I get too many findings?**

A: **Focus on CRITICAL first**:
```bash
# Filter by severity
strigoi probe all . --severity CRITICAL,HIGH

# Export to JSON for processing
strigoi probe all . --format json > findings.json
```

### **Q: How do I fix vulnerabilities?**

A: Strigoi provides **specific remediation guidance** for each finding. Look for the "Fix:" line in scan output.

---

## Troubleshooting

### Scan produces no results

```bash
# Enable debug logging
LOG_LEVEL=debug strigoi probe east .

# Check file permissions
ls -la /path/to/target
```

### "Platform connection refused"

```bash
# Check if platform services are running
podman-compose ps

# Or start platform
systemctl --user start strigoi-platform
```

### Want to see more examples?

```bash
# Install all 3 vulnerable MCP examples
cd Strigoi/examples/insecure-mcps
./install-all.sh

# Scan each one
strigoi probe east mcp-sqlite/        # SQL injection
strigoi probe east mcp-filesystem/    # Path traversal
strigoi probe east mcp-http-api/      # SSRF & secrets
```

---

## You're Ready!

**You've completed your first Strigoi scan and discovered real vulnerabilities.** 🎉

**What's next?**

1. **Scan your real AI systems**: `strigoi probe all /path/to/ai/code`
2. **Set up continuous monitoring**: [Operations Guide](../operations/deployment/README.md)
3. **Integrate with CI/CD**: [GitHub Actions](../integration/api.md)
4. **Prepare for audits**: [Regulatory Compliance](./use-cases.md#3-regulatory-examination-preparation)

---

*You're now equipped to discover AI/LLM vulnerabilities before they become breaches.*
*From quick scans to comprehensive security assessments - Strigoi has you covered.*
