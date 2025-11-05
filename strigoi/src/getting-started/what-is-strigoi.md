# What is Strigoi?

**Strigoi is the world's first comprehensive security assessment platform specifically designed for AI/LLM systems in banking and enterprise environments.**

---

## The Problem Strigoi Solves

### The AI Security Gap in Banking

**Industry Reality (2025)**:
- 78% of banks now use AI (up from 8% in 2024)
- $35 billion in AI investment across banking (2023)
- **Only 26% have formal AI security policies**
- **Zero standardized AI audit frameworks exist**

**The Crisis**:
Banks are deploying AI systems—LLM-powered chatbots, document analysis, fraud detection—**without knowing what security vulnerabilities exist**. Traditional security tools weren't built for AI/LLM architectures.

### What Makes AI/LLM Security Different?

Traditional applications have:
- Static code with defined input/output
- Deterministic behavior
- Clear security perimeters

AI/LLM systems have:
- **Dynamic prompt-based interfaces** (new attack surface)
- **Non-deterministic outputs** (hard to validate)
- **Agent-to-agent communication** (MCP, A2A protocols)
- **Third-party model dependencies** (supply chain risk)
- **Real-time tool invocation** (filesystem, database, API access)

**Traditional security tools miss these risks entirely.**

---

## The Strigoi Solution

### "Before Anyone Else" Security Leadership

Strigoi doesn't just find known vulnerabilities—**it discovers vulnerabilities before the industry knows they exist**.

Strigoi has discovered critical vulnerabilities in production AI systems that no other tool detected—including GraphQL security issues, credential leakage, and authentication bypasses that could have caused multi-million dollar breaches.

### How Strigoi Works

Strigoi uses **directional security intelligence**—a compass-based approach inspired by military reconnaissance:

#### **🧭 Directional Probing Framework**

**NORTH** - External attack surfaces
- API endpoints & external interfaces
- Internet-facing services
- Third-party integrations
- What attackers see from outside

**SOUTH** - Dependency vulnerabilities
- AI model supply chain
- Python/npm package security
- Vulnerable libraries & frameworks
- Transitive dependencies

**EAST** - Data flow security
- How data moves through AI systems
- Model inputs/outputs
- Tool invocations & side effects
- Information leakage patterns

**WEST** - Authentication & authorization
- Access controls
- Credential management
- API key security
- Permission boundaries

**ALL** - Comprehensive multi-directional scan
- Combines all directions
- Cross-vector correlation
- Complete attack surface mapping

---

## Core Capabilities

### 1. Real-Time AI CLI Monitoring

Strigoi is the **only platform** that monitors AI CLI tools in real-time:

- **Claude Code** (Anthropic)
- **Gemini CLI** (Google)
- **ChatGPT CLI** (OpenAI)

Via the **A2MCP Bridge** (Agent-to-Agent via Model Context Protocol), Strigoi captures:
- Every tool invocation
- Prompt/response patterns
- File system operations
- API calls & network requests
- Credential usage

All streamed through **NATS JetStream** for real-time analysis.

### 2. 17+ Vulnerability Detection Patterns

Strigoi detects:

**Secrets & Credentials:**
- API keys (OpenAI, AWS, Google, etc.)
- SSH private keys
- Database credentials
- OAuth tokens
- JWT secrets

**Privacy & Compliance:**
- Social Security Numbers (SSN)
- Credit card numbers (PCI-DSS)
- Email addresses (PII)
- Phone numbers (PII)
- Physical addresses

**Injection Attacks:**
- SQL injection patterns
- Prompt injection keywords
- Command injection
- Path traversal attempts

**Infrastructure Risks:**
- SSRF vulnerabilities
- Unencrypted connections
- Missing authentication
- Exposed internal IPs

### 3. MITRE ATLAS Framework Mapping

Every vulnerability is automatically mapped to **MITRE ATLAS** (Adversarial Threat Landscape for AI Systems):

- **AML.T0024** - Prompt Injection
- **AML.T0015** - Model Inversion
- **AML.T0043** - Supply Chain Compromise
- Plus 12+ additional ATLAS techniques

**Why this matters**: Regulatory examiners (OCC, FDIC, Fed) expect MITRE framework alignment. Strigoi provides it automatically.

### 4. Multi-Architecture Support

Strigoi runs anywhere:

- **AMD64** - Standard x86_64 servers, cloud VMs
- **ARM64** - Raspberry Pi 4/5, NanoPi R6S, Orange Pi 5
- **ARMv7** - Raspberry Pi 3

**Use case**: Deploy edge sensors on ARM devices at bank branches, aggregate intelligence at HQ on AMD64 servers.

### 5. Platform Architecture

**Thin CLI Client + Distributed Services:**

```
┌──────────────────────────────────────────┐
│  Strigoi CLI (Thin Client)              │
│  • Interactive shell                     │
│  • Directional probing                   │
│  • Stream tapping                        │
└────────────┬─────────────────────────────┘
             │
             ↓ (communicates with platform)
             │
┌────────────┴─────────────────────────────┐
│  Strigoi Platform Services               │
│  ┌────────────────────────────────────┐  │
│  │  NATS JetStream                    │  │
│  │  (Event streaming backbone)        │  │
│  └───┬────────────────────────────────┘  │
│      │                                    │
│  ┌───▼────────────┐  ┌──────────────┐   │
│  │ Intel Analyzer │  │ Vuln         │   │
│  │ (Directional   │  │ Classifier   │   │
│  │  aggregation)  │  │ (MITRE ATLAS)│   │
│  └───┬────────────┘  └──────┬───────┘   │
│      │                      │            │
│  ┌───▼──────────────────────▼─────────┐ │
│  │  EventDB (TimescaleDB)             │ │
│  │  (Security event storage)          │ │
│  └───┬────────────────────────────────┘ │
│      │                                   │
│  ┌───▼──────────────────────────────┐   │
│  │  Fleet Manager (Web UI + API)    │   │
│  │  http://localhost:8081            │   │
│  └───────────────────────────────────┘   │
└──────────────────────────────────────────┘
```

**Benefits**:
- **Scalable**: Add more analyzers/classifiers as needed
- **Resilient**: Services restart automatically
- **Observable**: Grafana dashboards + Prometheus metrics
- **Portable**: Podman/Docker deployment

---

## Who Built Strigoi?

**Macawi AI** - Founded by Brother Cy (Spectacled Charcoal Wolf), former CISO with banking security expertise and graduate-level teaching at UW-Madison Graduate School of Banking.

**Why we built it**: After witnessing organizational dysfunction and evangelical politics derail AI security at a major bank, we decided to build the platform the industry desperately needs.

**Our philosophy**: *"The universe has standards. Let's meet them."*

---

## Strigoi vs. Traditional Security Tools

| Feature | Strigoi | Traditional SAST | Vulnerability Scanners |
|---------|---------|------------------|------------------------|
| **AI/LLM-specific detection** | ✅ Yes (17+ patterns) | ❌ No | ❌ No |
| **Real-time CLI monitoring** | ✅ Yes (A2MCP bridge) | ❌ No | ❌ No |
| **MITRE ATLAS mapping** | ✅ Automatic | ❌ Manual | ❌ N/A |
| **Directional intelligence** | ✅ Yes (N/S/E/W) | ❌ No | ❌ No |
| **ARM64 edge deployment** | ✅ Yes | ❌ No | ❌ No |
| **Banking compliance focus** | ✅ Yes | ⚠️ Partial | ⚠️ Partial |
| **Vulnerable test cases** | ✅ 3 MCPs included | ❌ No | ❌ No |

---

## What Strigoi Is NOT

**Not a replacement for traditional security tools**
Strigoi complements SAST, DAST, and vulnerability scanners—it doesn't replace them.

**Not AI threat detection**
Strigoi detects vulnerabilities in AI systems, not adversarial attacks on models themselves.

**Not a firewall or WAF**
Strigoi is an assessment/monitoring platform, not a prevention control (though it informs prevention).

**Not automatic remediation**
Strigoi tells you what's vulnerable and how to fix it—your team implements fixes.

---

## Next Steps

**Ready to install?**
→ [Installation Guide](./installation/README.md)

**Want to see it in action?**
→ [Quick Start Guide](./quick-start.md)

**Curious about use cases?**
→ [Use Cases](./use-cases.md)

**Need architecture details?**
→ [Architecture Overview](../architecture/overview.md)

---

*Strigoi: Discovering AI vulnerabilities before anyone else.*
