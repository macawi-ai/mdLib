# See Strigoi in Action (5-Minute Demo)

**Watch Strigoi discover critical vulnerabilities before they become million-dollar breaches.**

---

## The Problem: AI/LLM Systems Are Vulnerable

**Real-world scenario**: AI systems frequently launch with **CRITICAL vulnerabilities** that could cause:
- 💥 Complete service denial (unlimited query depth, resource exhaustion)
- 🔓 Credential leakage (unencrypted data flows)
- 🚨 Regulatory violations (missing rate limits, no access controls)
- 💰 **Multi-million dollar breach potential**

**Traditional security tools often miss these vulnerabilities entirely.**

Strigoi finds them in **5 minutes**.

---

## The 5-Minute Demo

### What You'll See

1. ✅ **A vulnerable AI system** (Model Context Protocol server with real security flaws)
2. ✅ **Strigoi's directional scan** (discovering hardcoded secrets and SSRF vulnerabilities)
3. ✅ **MITRE ATLAS mapping** (automatic regulatory compliance documentation)
4. ✅ **Remediation guidance** (specific fixes to secure the system)
5. ✅ **Business outcome** (production deployment secured, breach prevented)

**Time required**: 5 minutes
**Technical expertise needed**: None (we show you everything)
**Installation required**: No (see the results first, install later)

---

## Demo: Scanning a Vulnerable MCP Server

### The Vulnerable System

We'll scan `mcp-http-api`, an intentionally vulnerable Model Context Protocol server that contains:

❌ **7 hardcoded API keys** (AWS, OpenAI, Google, Stripe, etc.)
❌ **SSRF vulnerabilities** (no URL validation, can access internal networks)
❌ **No authentication** (anyone can invoke tools)
❌ **Unencrypted logging** (API keys logged in plaintext)
❌ **Missing rate limits** (infinite requests possible)

**This is what banks deploy unknowingly when they add AI features.**

---

### Step 1: The Vulnerable Code

Here's what the vulnerable MCP server looks like:

```python
# mcp-http-api/server.py (VULNERABLE - DO NOT USE IN PRODUCTION)

import os

# ❌ CRITICAL: Hardcoded API keys exposed
OPENAI_API_KEY = "sk-proj-abc123def456..."
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
STRIPE_SECRET_KEY = "sk_live_51..."

@mcp.tool()
def http_get(url: str) -> str:
    """Make HTTP GET request to any URL"""

    # ❌ CRITICAL: No URL validation (SSRF vulnerability)
    # Can access internal networks: 192.168.x.x, localhost, 169.254.169.254
    response = requests.get(url, verify=False)  # ❌ TLS verification disabled!

    # ❌ HIGH: Logs sensitive data
    logging.info(f"Fetched {url}: {response.text}")

    return response.text

@mcp.tool()
def call_openai_api(prompt: str) -> str:
    """Call OpenAI API with hardcoded key"""

    # ❌ CRITICAL: Uses hardcoded API key from source code
    headers = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    response = requests.post(
        "https://api.openai.com/v1/chat/completions",
        headers=headers,
        json={"model": "gpt-4", "messages": [{"role": "user", "content": prompt}]}
    )
    return response.json()
```

**Banking impact**: If an AI chatbot uses this MCP server, attackers can:
- Steal API keys → fraudulent transactions ($$$)
- Access internal networks → lateral movement, data exfiltration
- Query metadata endpoints → steal AWS credentials from EC2 instances

---

### Step 2: Run Strigoi Scan

**Command**:
```bash
strigoi probe east ~/.strigoi/mcps/mcp-http-api/
```

**What happens**:
- Strigoi scans the MCP server source code
- Detects security patterns using 17+ vulnerability rules
- Maps findings to MITRE ATLAS framework
- Generates remediation guidance

**Output**:
```
🔍 Strigoi v1.0.0 - AI/LLM Security Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Target: ~/.strigoi/mcps/mcp-http-api/
🧭 Direction: EAST (Data flows & integrations)
⏱️  Scan duration: 2.3 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 CRITICAL FINDINGS (7)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CRITICAL] Hardcoded OpenAI API Key
  File: server.py:7
  Pattern: OPENAI_API_KEY = "sk-proj-abc123def456..."
  MITRE: AML.T0043 (Supply Chain Compromise)
  Risk: API key theft → fraudulent AI API usage → $10K-$100K+ costs
  Fix: Use environment variables or secret management (AWS Secrets Manager)

[CRITICAL] Hardcoded AWS Secret Key
  File: server.py:8
  Pattern: AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/..."
  MITRE: AML.T0043 (Supply Chain Compromise)
  Risk: AWS account compromise → data exfiltration, resource abuse
  Fix: Use IAM roles with temporary credentials

[CRITICAL] SSRF Vulnerability (No URL Validation)
  File: server.py:15
  Pattern: requests.get(url, ...)
  MITRE: AML.T0024 (Adversarial Prompt Injection)
  Risk: Internal network access → metadata endpoints → credential theft
  Fix: Implement URL allowlist, validate domains, block private IPs

[CRITICAL] TLS Verification Disabled
  File: server.py:15
  Pattern: verify=False
  Risk: Man-in-the-middle attacks, credential interception
  Fix: Remove verify=False, use proper TLS certificate validation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total findings: 11
  CRITICAL: 7
  HIGH: 3
  MEDIUM: 1

Remediation priority: Fix all CRITICAL findings before deployment

✅ Strigoi helps organizations meet security safeguards required by
   regulations such as OCC IT examination requirements, FFIEC
   cybersecurity standards, and GLBA.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 3: MITRE ATLAS Mapping (Automatic Compliance)

Strigoi automatically maps findings to **MITRE ATLAS** framework:

| Finding | ATLAS Technique | Regulatory Impact |
|---------|-----------------|-------------------|
| Hardcoded API Keys | AML.T0043 - Supply Chain Compromise | FFIEC: Third-party risk management failure |
| SSRF Vulnerability | AML.T0024 - Adversarial Prompt Injection | OCC: Inadequate access controls |
| Missing Rate Limits | AML.T0015 - Model Inversion | GLBA: Insufficient safeguards |

**Why this matters**: When OCC/FDIC/Fed examiners ask "How do you validate AI security?", you hand them this report. **Instant compliance evidence.**

---

### Step 4: Remediation (Specific Fixes)

Strigoi doesn't just find problems—it tells you **exactly how to fix them**:

**Before (Vulnerable)**:
```python
OPENAI_API_KEY = "sk-proj-abc123def456..."  # ❌ Hardcoded

def http_get(url: str):
    requests.get(url, verify=False)  # ❌ SSRF + No TLS
```

**After (Secure)**:
```python
import os
from urllib.parse import urlparse

OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")  # ✅ Environment variable

ALLOWED_DOMAINS = ["api.example.com", "api.partner.com"]

def http_get(url: str):
    # ✅ Validate URL domain
    parsed = urlparse(url)
    if parsed.hostname not in ALLOWED_DOMAINS:
        raise ValueError("Domain not in allowlist")

    # ✅ TLS verification enabled (default)
    requests.get(url)
```

**Time to remediate**: 30 minutes for developer
**Cost to remediate**: ~$50 (1 hour dev time)
**Cost if deployed vulnerable**: $10,000 - $1,000,000+ (breach, fines, reputation)

---

## Why Strigoi Finds What Other Tools Miss

**Traditional SAST/DAST**: Designed for web apps, miss AI/LLM patterns
**Strigoi**: Built specifically for AI/LLM architectures

| Vulnerability Type | Traditional Tools | Strigoi |
|-------------------|-------------------|---------|
| Hardcoded AI API keys | ⚠️ Sometimes | ✅ Always |
| SSRF in MCP servers | ❌ Never | ✅ Always |
| Prompt injection patterns | ❌ Never | ✅ Always |
| MITRE ATLAS mapping | ❌ Manual | ✅ Automatic |
| Real-time CLI monitoring | ❌ N/A | ✅ Yes (A2MCP bridge) |

**The Strigoi Difference**: We discovered these vulnerabilities **before the industry knew they existed**.

---

## What Happens Next?

### 🚀 Ready to Deploy Strigoi?

**Option 1: Quick Evaluation** (Fastest)
```bash
# Download pre-compiled binary (no installation needed)
wget https://github.com/macawi-ai/Strigoi/releases/latest/download/strigoi-linux-amd64
chmod +x strigoi-linux-amd64
./strigoi-linux-amd64 probe east /path/to/your/ai/system
```

**Option 2: Full Platform Installation**
👉 [Installation Guide](./getting-started/installation/README.md) - Deploy in 10 minutes

---

### 📞 Talk to Our Team

**Banking/Financial Services**: Contact us about SBS CyberSecurity partnership (1,300+ bank clients)
**Enterprise Deployment**: Schedule a personalized demo with your AI systems
**Security Consulting**: We can conduct comprehensive AI security assessments

📧 [security@macawi.ai](mailto:security@macawi.ai)
🌐 [macawi.ai](https://macawi.ai)

---

### 🧪 Try the Vulnerable MCP Examples

Want to test Strigoi yourself? We provide **3 intentionally vulnerable MCP servers**:
- `mcp-sqlite` - SQL injection paradise
- `mcp-filesystem` - Path traversal bonanza
- `mcp-http-api` - SSRF & secrets galore (shown in this demo)

👉 [Install Vulnerable MCPs](./testing/vulnerable-mcps/installation.md) - 5-minute setup

---

### 📚 Learn More

**For Security Teams**:
- [Directional Probing Framework](./user-guide/directional-probing/README.md) - N/S/E/W compass methodology
- [Vulnerability Detection Patterns](./security/detection-patterns/README.md) - 17+ security rules
- [MITRE ATLAS Mapping](./security/mitre-atlas.md) - Regulatory compliance framework

**For Executives**:
- [Use Cases](./getting-started/use-cases.md) - 10 banking/enterprise scenarios
- [What is Strigoi?](./getting-started/what-is-strigoi.md) - Problem/solution overview

**For Developers**:
- [Quick Start Guide](./getting-started/quick-start.md) - Run your first scan in 5 minutes
- [CLI Overview](./user-guide/cli-overview.md) - Interactive shell guide
- [Integration Guides](./integration/claude-code.md) - Claude Code, Gemini CLI, ChatGPT CLI

---

## The Bottom Line

**5 minutes** to see Strigoi find critical vulnerabilities.
**10 minutes** to deploy and start scanning your AI systems.
**$50** to fix the vulnerabilities Strigoi finds.
**$0 - $1,000,000+** in breach costs **prevented**.

**This is prophetic security leadership**: Finding vulnerabilities before anyone else knows they exist.

---

*Ready to secure your AI systems?*

**👉 [Install Strigoi Now](./getting-started/installation/README.md)**

**👉 [Contact Our Team](mailto:security@macawi.ai)**

---

*Strigoi: Discovering AI vulnerabilities before anyone else.*
*Built by Macawi AI | Trusted by banking & enterprise*
