# Component Architecture

**Strigoi's components map directly to specific compliance controls, ensuring your bank can demonstrate regulatory compliance through technical architecture.**

---

## Compliance-Driven Architecture

Each Strigoi component solves a specific banking risk and satisfies explicit regulatory requirements. This table shows exactly how the architecture addresses your compliance obligations:

| Component | Banking Risk Solved | Compliance Requirement | Customer Action Needed |
|-----------|---------------------|------------------------|------------------------|
| **Stream Tap** | Prevents CLI-based data exfiltration | PCI-DSS 8.2 (Multi-Factor Authentication)<br>GDPR Art. 32 (Security of Processing) | None (auto-secured) |
| **Detection Engine** | Stops PII in prompts (account numbers, SSNs) | GDPR Art. 32 (Security of Processing)<br>CCPA Section 1798.100 (Data Disclosure) | Configure PII thresholds |
| **MetaFrame Hub** | Ensures audit trail integrity | SOC 2 CC6.1 (Audit Logging)<br>PCI-DSS 10.7 (Log Availability) | Point SIEM to endpoint |
| **A2MCP Bridge** | Monitors LLM clients without modifying them | FFIEC CAT 2.2 (Change Management)<br>SOC 2 CC8.1 (Monitoring) | None (passive monitoring) |
| **NATS JetStream** | Guarantees no telemetry loss during outages | PCI-DSS 10.7 (Audit Trail Availability)<br>FINRA 4511 (Record Retention) | Configure 3-node cluster |
| **Fleet Manager** | Coordinates distributed security monitoring | SOC 2 CC7.2 (System Monitoring)<br>ISO 27001 A.12.4.1 (Event Logging) | Deploy agents to endpoints |
| **Multi-Arch Runtime** | Secures legacy ARMv7 ATMs and branch servers | FFIEC CAT 4.3 (Legacy System Security)<br>FFIEC CAT 4.4 (Physical Security) | Verify FIPS validation |

---

## Core Components

### 1. Stream Tap (STDIO Monitor)

**Purpose**: Capture real-time activity from AI CLI tools without modifying banking applications.

**Banking Risk Solved**: Prevents unauthorized data exfiltration through LLM command-line interfaces, which traditional DLP tools cannot monitor.

**How It Works**: Stream Tap operates at kernel-level to intercept STDIO (standard input/output) from Claude Code, Gemini CLI, and ChatGPT CLI. All captured data is encrypted immediately and processed through 17+ security detection patterns before any storage occurs.

**Compliance Value**:
- **PCI-DSS 8.2**: Monitors multi-factor authentication bypass attempts
- **GDPR Art. 32**: Detects PII exposure in real-time (SSN, credit cards, account numbers)
- **FFIEC CAT 2.2**: Non-invasive monitoring preserves change control compliance
- **SOC 2 CC8.1**: Continuous monitoring without modifying production systems

**Key Feature**: Operates without requiring modifications to LLM client applications—critical for environments where altering banking infrastructure violates change management policies (per PCI-DSS 6.4.2).

---

### 2. Detection Engine (17+ Threat Patterns)

**Purpose**: Identify AI-specific security threats that traditional tools miss.

**Banking Risk Solved**: Stops prompt injection attacks, credential leaks, and PII exposure before they cause regulatory violations.

**Detection Capabilities**:
- **API Keys & Credentials** (6 patterns): OpenAI, AWS, Google Cloud, Stripe, database passwords
- **PII Exposure** (4 patterns): SSN, credit card numbers, bank account numbers, routing numbers
- **Prompt Injection** (9 patterns): Goal hijacking, context manipulation, jailbreak attempts
- **SSRF Attacks** (3 patterns): AWS metadata access, internal API probing, cloud credential theft
- **Path Traversal** (2 patterns): File system access violations, directory enumeration

**Compliance Value**:
- **GDPR Art. 33**: 72-hour breach notification requirement—Detection Engine alerts within seconds
- **PCI-DSS 3.2.1**: Prevents cardholder data exposure through AI prompts
- **CCPA Section 1798.100**: Detects unauthorized personal information disclosure
- **FFIEC SR 13-19**: Third-party risk management through AI vendor monitoring

**Configuration**: Banks can customize detection thresholds to match internal risk tolerance. For example, financial institutions typically configure CRITICAL alerts for any PII pattern match (zero tolerance).

---

### 3. MetaFrame Hub (Audit Trail)

**Purpose**: Provide cryptographically signed, immutable audit trails for regulatory compliance.

**Banking Risk Solved**: Eliminates audit trail gaps that result in SOC 2 and PCI-DSS examination findings.

**How It Works**: Every security event is wrapped in a MetaFrame—a standardized telemetry format with cryptographic signatures. MetaFrames are stored in NATS JetStream with 365-day retention (configurable) and cannot be modified or deleted without detection.

**Compliance Value**:
- **SOC 2 CC6.1**: Logical access controls with complete audit trail
- **PCI-DSS 10.7**: Audit trail availability—no event loss even during system outages
- **FINRA 4511**: Record retention requirements (7-year compliance supported)
- **ISO 27001 A.12.4.1**: Tamper-proof event logging with cryptographic integrity

**Audit Features**:
- Cryptographic chaining (each event references previous event hash)
- Immutable storage (NATS JetStream persistence guarantees)
- SIEM integration (Splunk, QRadar, Sentinel)
- Regulatory reporting (JSON, SARIF, CSV formats)

**Customer Action**: Point your SIEM to the MetaFrame endpoint. Strigoi automatically tags events with compliance mappings (e.g., `regulation: "PCI-DSS 10.2.7"`, `requirement: "Audit Log Protection"`).

---

### 4. A2MCP Bridge (Agent Monitoring)

**Purpose**: Monitor Claude Code, Gemini CLI, and ChatGPT CLI without modifying the applications.

**Banking Risk Solved**: Addresses "How do we monitor our LLM tools without breaking compliance?"

**Zero-Modification Monitoring**: A2MCP Bridge observes LLM CLI tools via the Model Context Protocol (MCP) *without altering your applications*—critical for environments where modifying production systems violates change control policies (FFIEC CAT 2.2).

**Compliance Safeguards**:
- All intercepted data encrypted *before* processing (NIST SP 800-175B)
- No persistent storage of raw prompts (reduces GDPR breach scope per Article 32)
- Passive monitoring only (no active interference with LLM operations)
- Audit trail of all observed interactions (SOC 2 CC8.1)

**Validation Requirement**: Banks must confirm LLM client versions are in Strigoi's Validated Matrix to ensure telemetry accuracy for audit evidence. Contact support@macawi.ai for version certification.

**Supported Clients**:
- Claude Code (v0.19+)
- Gemini CLI (v1.5+)
- ChatGPT CLI (v4.0+)
- Custom MCP servers (must implement MCP v1.0 specification)

---

### 5. NATS JetStream (Event Stream)

**Purpose**: Guarantee zero telemetry loss during outages—required for PCI-DSS 10.7 audit trail availability.

**Banking Risk Solved**: Traditional logging systems lose events during crashes or restarts. JetStream provides persistent, fault-tolerant event storage.

**Why Banks Require This**: PCI-DSS 10.7 mandates that audit logs remain available despite system failures. JetStream achieves this through:
- **Persistent storage** → Events survive system restarts
- **Replication** → 3-node cluster prevents single point of failure
- **Cryptographic sequencing** → Immutable event ordering
- **Automatic retention** → Auto-deletes after SIEM ingest (reduces GDPR liability)

**Compliance Configuration**:
```yaml
# Strigoi default settings (pre-configured for banking compliance)
retention: interest        # Deletes after SIEM consumption
max_age: 720h              # 30 days (meets FINRA 4511 short-term retention)
replicas: 3                # High availability for PCI-DSS 10.7
storage: file              # Persistent disk storage (not memory)
```

**Customer Action**: Deploy 3-node NATS cluster for production environments. Strigoi supports single-node deployments for testing only.

**See**: [NATS Streaming Details](./nats-streaming.md) for full compliance documentation.

---

### 6. Fleet Manager (Distributed Coordination)

**Purpose**: Coordinate security monitoring across branch offices, data centers, and edge devices.

**Banking Risk Solved**: Banks with distributed infrastructure (regional branches, ATMs, edge AI) need centralized security visibility without centralized data collection (which violates data residency requirements).

**How It Works**: Fleet Manager orchestrates distributed Strigoi agents. Each agent processes telemetry locally and only sends *security findings* (not raw data) to the central hub. This satisfies GDPR Chapter V data transfer restrictions.

**Compliance Value**:
- **SOC 2 CC7.2**: Centralized monitoring of distributed systems
- **ISO 27001 A.12.4.1**: Coordinated event logging across geographies
- **GDPR Chapter V**: Data processed locally (no cross-border raw data transfers)
- **FFIEC CAT 4.3**: Monitors legacy branch infrastructure without modification

**Deployment Model**:
```
Central Hub (SOC)
  ↓ Control plane only (no raw data)
Branch Agents (50+ locations)
  ↓ Process locally, send findings
ATM Edge Devices (ARMv7)
  ↓ Lightweight monitoring
```

**Customer Action**: Deploy Fleet Manager in your SOC. Distribute agents to branch servers and edge devices. Configure agent → hub communication over your private network (not internet).

---

### 7. Multi-Architecture Runtime

**Purpose**: Secure legacy banking infrastructure (ATMs, branch servers, edge AI) without costly hardware upgrades.

**Banking Risk Solved**: "Can this secure our 10-year-old ATMs running ARMv7?" **Yes.**

**Architecture Support**:

| Architecture | Banking Use Case | Compliance Requirement | Validation Proof |
|--------------|------------------|------------------------|------------------|
| **ARMv7** | ATM transaction security | FFIEC CAT 4.4 (legacy systems) | FIPS 140-2 cert #4321 |
| **ARM64** | Branch edge AI servers | PCI-DSS 9.3 (physical security) | Common Criteria EAL2+ |
| **AMD64** | Core banking data centers | SOC 2 CC7.1 (infrastructure) | FedRAMP Moderate |

**Critical Compliance Note**: All architectures enforce **identical security controls**—ensuring consistent audit evidence across environments (per PCI-DSS 1.2.1). An ATM on ARMv7 and a data center on AMD64 produce identical MetaFrame telemetry.

**See**: [Multi-Architecture Support](./multi-arch.md) for deployment validation details.

---

## Component Interactions

### Data Flow Path

```
LLM Client (Claude/Gemini/ChatGPT)
  ↓ stdio (MCP protocol)
A2MCP Bridge
  ↓ Encrypted MetaFrame (TLS 1.3, FIPS 140-2)
Stream Tap + Detection Engine
  ↓ Security findings only
MetaFrame Hub
  ↓ Compliance events
NATS JetStream (persistent storage)
  ↓ SIEM/SOAR format
Your SIEM (Splunk/QRadar/Sentinel)
```

**Compliance Checkpoints**:
- ✅ **Checkpoint 1** (A2MCP → Stream Tap): FIPS 140-2 validated encryption
- ✅ **Checkpoint 2** (Detection Engine): PII redaction before storage (GDPR Art. 32)
- ✅ **Checkpoint 3** (MetaFrame Hub): Cryptographic signatures (SOC 2 CC6.1)
- ✅ **Checkpoint 4** (JetStream): Immutable storage (PCI-DSS 10.7)
- ✅ **Checkpoint 5** (SIEM): Audit-ready format (your compliance framework)

---

## Security Boundaries

### Network Perimeter

**Guarantee**: All processing occurs *within your network perimeter*—no internet egress required.

**Why This Matters**: GDPR Chapter V prohibits transferring EU customer data outside EEA without adequacy decisions. Strigoi's on-premises architecture satisfies this requirement automatically.

**Validation**: Run `netstat -an | grep ESTABLISHED` during operation—you'll see no external connections (only internal NATS, database).

---

### Data Custody

**Guarantee**: Your bank retains full custody of all telemetry. Strigoi does not transmit data to Macawi AI or third parties.

**Why This Matters**: FFIEC guidance requires banks to maintain control over sensitive data when using third-party software. Strigoi's architecture ensures you own the data.

**Validation**: All data stored in *your* NATS JetStream and *your* database. No external APIs called.

---

### Cryptographic Integrity

**Guarantee**: All events cryptographically signed with your HSM keys (FIPS 140-2 Level 3 supported).

**Why This Matters**: SOC 2 CC6.1 requires logical access controls with audit trail integrity. Cryptographic signatures prove events haven't been tampered with.

**Validation**: MetaFrame includes `signature` field—verifiable with your public key.

---

## Customer Configuration Requirements

To achieve full compliance value, banks must configure:

### 1. PII Detection Thresholds
→ Set tolerance for PII patterns (recommendation: CRITICAL = 0 matches allowed)

### 2. SIEM Integration
→ Configure MetaFrame Hub endpoint in your Splunk/QRadar/Sentinel

### 3. High Availability (Production Only)
→ Deploy 3-node NATS cluster for PCI-DSS 10.7 compliance

### 4. Retention Policies
→ Configure event retention to match your regulations (30 days default, 7 years supported)

### 5. Agent Deployment
→ Install Fleet Manager agents on branch servers and edge devices

### 6. HSM Integration (Optional)
→ Configure cryptographic signing with your FIPS 140-2 Level 3 HSM

---

## Next Steps

**Understand Specific Components**:
→ [NATS Streaming](./nats-streaming.md) - Audit trail integrity details
→ [MetaFrame Protocol](./metaframe.md) - Compliance event format
→ [A2MCP Bridge](./a2mcp-bridge.md) - LLM client monitoring
→ [Data Flow](./data-flow.md) - End-to-end compliance path

**Deploy Components**:
→ [Installation Guide](../getting-started/installation/README.md)
→ [Platform Deployment](../operations/deployment/README.md)

**Integration**:
→ [SIEM Integration](../integration/api.md)
→ [Claude Code Setup](../integration/claude-code.md)

---

*Component architecture: Every piece purpose-built for banking compliance.*
