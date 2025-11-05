# Welcome to Strigoi

**The world's first AI/LLM security assessment platform designed for banking and enterprise deployments.**

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/macawi-ai/Strigoi/releases)
[![License](https://img.shields.io/badge/license-AGPL%203.0-orange)](https://github.com/macawi-ai/Strigoi/blob/main/LICENSE)
[![Multi-Architecture](https://img.shields.io/badge/arch-AMD64%20%7C%20ARM64-green)](./getting-started/installation/README.md)

---

## What Makes Strigoi Unique?

Strigoi is the **only security platform** that:

✅ **Discovers vulnerabilities before the industry knows they exist**
✅ **Monitors AI CLI tools in real-time** (Claude Code, Gemini CLI, ChatGPT CLI)
✅ **Maps to MITRE ATLAS** framework automatically
✅ **Deploys on ARM64** (Raspberry Pi, NanoPi, Orange Pi)
✅ **Provides directional security intelligence** (North/South/East/West compass)

---

## Built for Banking & Financial Services

**78% of banks now use AI** (up from 8% in 2024), but **only 26% have formal AI security policies**.

Strigoi fills this critical gap by providing:

- **Comprehensive vulnerability detection** across 17+ security patterns
- **Regulatory compliance documentation** for OCC, FDIC, and Fed examinations
- **Modular assessment framework** for banks of all asset sizes
- **Real-time threat monitoring** with JetStream event streaming
- **Intentionally vulnerable test cases** for staff training

---

## Quick Navigation

### 🚀 **Getting Started**
New to Strigoi? Start here:
- [What is Strigoi?](./getting-started/what-is-strigoi.md)
- [Installation Guide](./getting-started/installation/README.md)
- [Quick Start](./getting-started/quick-start.md)
- [First Security Scan](./getting-started/first-scan.md)

### 📚 **User Guide**
Learn how to use Strigoi effectively:
- [CLI Overview](./user-guide/cli-overview.md)
- [Directional Probing](./user-guide/directional-probing/README.md)
- [MCP Server Scanning](./user-guide/mcp-scanning.md)
- [Understanding Results](./user-guide/understanding-results.md)

### 🏗️ **Platform Operations**
Deploy and maintain Strigoi in production:
- [Deployment Guide](./operations/deployment/README.md)
- [Configuration](./operations/configuration/README.md)
- [Monitoring](./operations/monitoring/README.md)
- [Troubleshooting](./operations/maintenance/troubleshooting.md)

### 🧪 **Testing & Demo**
Test Strigoi with intentionally vulnerable examples:
- [Vulnerable MCP Examples](./testing/vulnerable-mcps/README.md)
- [Demo Flow](./testing/demo-flow.md)
- [Validation Checklist](./testing/validation-checklist.md)

### 🔒 **Security Deep Dives**
Master AI/LLM security assessment:
- [Vulnerability Detection](./security/vulnerability-detection.md)
- [MITRE ATLAS Mapping](./security/mitre-atlas.md)
- [Detection Patterns](./security/detection-patterns/README.md)
- [Remediation Guide](./security/remediation.md)

---

## Architecture Overview

Strigoi combines real-time monitoring with comprehensive security assessment:

```
┌─────────────────────────────────────────────────────────┐
│                    Strigoi Platform                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  AI CLI Tools (Claude Code, Gemini, ChatGPT)           │
│         ↓                                                │
│  A2MCP Bridge (Agent-to-Agent via MCP)                  │
│         ↓                                                │
│  NATS JetStream (Event Streaming)                       │
│         ↓                                                │
│  Security Analyzers:                                     │
│    • Intel Analyzer (Directional aggregation)           │
│    • Vuln Classifier (MITRE ATLAS rules)                │
│         ↓                                                │
│  TimescaleDB (Event storage & analytics)                │
│         ↓                                                │
│  Fleet Manager (Web Dashboard + API)                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

Learn more in the [Architecture section](./architecture/overview.md).

---

## Who Should Use Strigoi?

### **Bank Information Security Officers**
Validate AI implementations before deployment, prepare for regulatory examinations, demonstrate due diligence.

### **Enterprise Security Teams**
Monitor AI agent activity in real-time, detect vulnerabilities across LLM toolchains, integrate with existing SIEM.

### **AI Development Teams**
Test AI applications for security issues, validate MCP server implementations, catch vulnerabilities pre-production.

### **Third-Party Auditors**
Conduct comprehensive AI security assessments, generate regulatory compliance reports, map findings to MITRE ATLAS.

---

## Support & Community

- **Documentation**: You're reading it! Browse the navigation on the left.
- **GitHub**: [github.com/macawi-ai/Strigoi](https://github.com/macawi-ai/Strigoi)
- **Issues**: [Report bugs or request features](https://github.com/macawi-ai/Strigoi/issues)
- **Commercial Support**: Contact [security@macawi.ai](mailto:security@macawi.ai)

---

## Ready to Begin?

👉 **Start with [What is Strigoi?](./getting-started/what-is-strigoi.md)** to understand the platform.

👉 **Or jump to [Installation](./getting-started/installation/README.md)** if you're ready to deploy.

👉 **Try the [Quick Start Guide](./getting-started/quick-start.md)** to run your first scan in 5 minutes.

---

*Strigoi - Discovering AI vulnerabilities before anyone else.*
*Built by Macawi AI | Trusted by banking & enterprise*
