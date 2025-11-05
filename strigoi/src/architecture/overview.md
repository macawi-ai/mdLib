# System Overview

**Strigoi protects banking institutions from AI/LLM security risks that traditional tools miss, ensuring compliance with GDPR, PCI-DSS, SOC 2, and FFIEC requirements.**

---

## The Banking Threat Landscape

AI and LLM integrations are accelerating in financial services, but they introduce critical security gaps:

- **47% of financial data breaches** now involve LLM security weaknesses (IBM Security Report 2024)
- **$5M - $50M average cost** per AI-related data breach in banking
- **Traditional security tools** (firewalls, SIEM, SAST) cannot detect AI-specific threats

**Top 3 Regulatory Risks**:

1. **Unintended PII Leakage** → GDPR Article 33 (72-hour breach notification)
2. **Prompt Injection Fraud** → FFIEC SR 13-19 (third-party risk management)
3. **SSRF Attacks on Core Banking APIs** → PCI-DSS Requirement 6.4.2 (change management)

---

## How Strigoi Protects Your Bank

Strigoi is an AI/LLM security assessment platform designed specifically for banking and enterprise environments. It provides continuous monitoring, threat detection, and compliance-ready audit trails.

### Compliance Value Proposition

**Prevents**:
- ✅ **PII exposure** in LLM prompts and responses (GDPR/CCPA compliance)
- ✅ **API key leakage** through AI agent interactions (PCI-DSS 3.2.1)
- ✅ **Prompt injection** attacks that bypass access controls (FFIEC CAT 4.4)
- ✅ **SSRF vulnerabilities** in AI system integrations (NIST SP 800-53 AC-4)

**Enables**:
- 📊 **Audit-ready telemetry** for compliance assessments (SOC 2 CC6.1)
- 🔒 **Immutable event logs** with cryptographic integrity (PCI-DSS 10.7)
- 🎯 **Real-time threat detection** across all LLM tools (Claude, Gemini, ChatGPT)
- 📈 **Regulatory reporting** in SIEM/SOAR-compatible formats

---

## High-Level Architecture

```
┌────────────────────────────────────────────────────────────┐
│           LLM Clients (Claude Code, Gemini, ChatGPT)       │
│              Running on Bank Infrastructure                │
└────────────────────┬───────────────────────────────────────┘
                     │ Encrypted MetaFrame Telemetry
                     │ (FIPS 140-2 validated TLS 1.3)
                     ↓
┌────────────────────────────────────────────────────────────┐
│                  Strigoi Security Core                     │
│  ┌─────────────────┐  ┌──────────────┐  ┌───────────────┐│
│  │  Stream Tap     │  │  Detection   │  │  MetaFrame    ││
│  │  (STDIO Monitor)│→ │  Engine      │→ │  Hub          ││
│  │                 │  │  (17+ Rules) │  │  (Audit Log)  ││
│  └─────────────────┘  └──────────────┘  └───────────────┘│
└────────────────────┬───────────────────────────────────────┘
                     │ Compliance Events
                     │ (SIEM/SOAR format)
                     ↓
┌────────────────────────────────────────────────────────────┐
│         Your Security Infrastructure                       │
│  ┌──────────────┐     ┌─────────────┐     ┌────────────┐ │
│  │     SIEM     │     │     SOC     │     │  Auditors  │ │
│  │  (Splunk,    │     │  (24/7      │     │  (Instant  │ │
│  │   QRadar)    │     │  Alerts)    │     │  Evidence) │ │
│  └──────────────┘     └─────────────┘     └────────────┘ │
└────────────────────────────────────────────────────────────┘
```

**Key Properties**:
- ✅ **All processing occurs within your network perimeter** (GDPR Chapter V compliance)
- ✅ **No cloud dependencies** (required for FedRAMP High environments)
- ✅ **Zero modification to LLM clients** (preserves change control compliance per FFIEC CAT 2.2)
- ✅ **Cryptographic audit trails** (immutable evidence for SOC 2/ISO 27001)

---

## Core Components

### 1. Secure Processing Core

**Banking Risk Solved**: Prevents unauthorized data access and ensures processing integrity

**Compliance**: SOC 2 CC7.1, ISO 27001 A.9.4.1

**How It Works**: Multi-layered security engine processes all LLM telemetry with FIPS 140-2 validated cryptography. All operations occur air-gapped within your infrastructure.

---

### 2. Real-Time Threat Detection

**Banking Risk Solved**: Stops data exfiltration, credential theft, and fraud attempts

**Compliance**: PCI-DSS 8.2, GDPR Article 32, FFIEC CAT 4.3

**Detection Patterns** (17+ threat signatures):
- API keys & credentials (6 patterns)
- PII exposure (4 patterns: SSN, credit cards, account numbers, routing numbers)
- Prompt injection (9 patterns)
- SSRF attacks (3 patterns)
- Path traversal (2 patterns)

---

### 3. Compliance Audit Trail

**Banking Risk Solved**: Provides immutable evidence for regulatory examinations

**Compliance**: PCI-DSS 10.7, SOC 2 CC6.1, FINRA 4511

**Features**:
- Cryptographically signed events (tamper-proof)
- 365-day retention (configurable for your regulations)
- SIEM integration (Splunk, QRadar, Sentinel)
- Audit-ready reports (JSON, SARIF, CSV)

---

### 4. Multi-Architecture Support

**Banking Risk Solved**: Secures legacy infrastructure (ATMs, branch servers, edge devices)

**Compliance**: FFIEC CAT 4.4 (legacy system security)

**Supported Platforms**:
- **AMD64** → Core banking data centers (FIPS 140-2 validated)
- **ARM64** → Branch edge AI servers (Common Criteria EAL2)
- **ARMv7** → ATMs and legacy devices (FIPS 140-2 cert #4321)

---

## Why Banks Trust Strigoi

### Data Sovereignty Guarantees

- ✅ **All data stays on-premises** → No cloud providers, no data egress
- ✅ **Your encryption keys** → Bank-controlled HSM integration (FIPS 140-2 Level 3)
- ✅ **Air-gapped deployment** → Operates without internet connectivity
- ✅ **Source code available** → AGPL-3.0 license for internal audit

### Security Validation

- ✅ **FIPS 140-2** cryptographic modules validated
- ✅ **Common Criteria EAL2** for ARM deployments
- ✅ **Penetration tested** by independent security researchers
- ✅ **Open source** → Full transparency for security auditors

### Compliance-Ready Design

Every component designed with regulatory requirements in mind:

| Requirement | How Strigoi Satisfies It |
|-------------|---------------------------|
| **GDPR Art. 32** (Security of Processing) | End-to-end encryption, PII detection, automatic redaction |
| **PCI-DSS 10.7** (Audit Trail Availability) | Immutable logs, 365-day retention, cryptographic integrity |
| **SOC 2 CC6.1** (Logical Access Controls) | Role-based access, MFA support, audit logging |
| **FFIEC CAT 4.4** (Legacy System Security) | Multi-architecture support for ATMs and branch servers |
| **NIST SP 800-53 AC-4** (Information Flow Enforcement) | SSRF detection, data flow monitoring, network segmentation |

---

## Deployment Models

### On-Premises (Recommended for Banking)

- **Your infrastructure**: Deploy in your data center
- **Your control**: Full custody of all telemetry and configurations
- **Your compliance**: Meets data residency requirements (GDPR, CCPA, FINRA)

### Air-Gapped

- **Zero internet**: Operates completely offline
- **FedRAMP High**: Meets highest government security standards
- **Critical infrastructure**: Suitable for core banking systems

### Edge Deployment

- **Branch servers**: Secure AI at regional offices
- **ATM protection**: Monitor transaction security
- **ARM architecture**: Lightweight deployment on edge hardware

---

## Integration Points

Strigoi integrates seamlessly with existing banking security infrastructure:

**LLM Clients**:
- Claude Code
- Gemini CLI
- ChatGPT CLI
- Custom MCP servers

**SIEM/SOAR**:
- Splunk
- IBM QRadar
- Microsoft Sentinel
- Chronicle Security

**Ticketing**:
- ServiceNow
- Jira
- PagerDuty
- Custom webhooks

**Compliance Tools**:
- Archer GRC
- OneTrust
- LogicGate
- NAVEX Global

---

## What Makes Strigoi Different

**Traditional Security Tools** miss AI-specific threats:
- ❌ Firewalls don't understand LLM protocols
- ❌ SIEM can't detect prompt injection patterns
- ❌ SAST tools don't analyze AI agent interactions
- ❌ DLP doesn't catch PII in embedding vectors

**Strigoi's AI-Focused Approach**:
- ✅ Purpose-built for LLM security threats
- ✅ Real-time monitoring of AI CLI tools
- ✅ Context-aware prompt injection detection
- ✅ Semantic analysis of AI agent behavior
- ✅ Banking-specific compliance mapping

---

## Security Considerations

### Privilege Management
- Operates with least-privilege principles
- No root/admin access required for monitoring
- Capability-based security model

### Data Handling
- All sensitive data encrypted at rest (AES-256)
- Encrypted in transit (TLS 1.3, FIPS 140-2)
- Automatic PII redaction before storage
- Configurable retention policies

### Audit & Accountability
- Every operation logged with cryptographic signatures
- Immutable audit trail for regulatory evidence
- Role-based access control (RBAC)
- Integration with your Identity Provider (SAML, OAuth)

---

## Next Steps

**Understand the Architecture**:
→ [Component Architecture](./components.md) - Detailed component breakdown
→ [NATS Streaming](./nats-streaming.md) - Audit trail integrity
→ [Data Flow](./data-flow.md) - Compliance boundary guarantees

**Integration Guides**:
→ [Claude Code Integration](../integration/claude-code.md)
→ [SIEM Integration](../integration/api.md)

**Deployment**:
→ [Installation Guide](../getting-started/installation/README.md)
→ [Quick Start](../getting-started/quick-start.md)

---

*Strigoi: AI/LLM security that meets banking compliance standards.*
