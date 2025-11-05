# Demo Flow

**Comprehensive demonstration guide for showcasing Strigoi's AI/LLM security capabilities to customers.**

---

## Overview

This guide provides structured demonstration flows for different audiences and time constraints. Each flow is designed to showcase Strigoi's value proposition while maintaining engagement and demonstrating measurable ROI.

**Target Audiences**:
- Banking executives (5-10 minutes)
- Security teams (20-30 minutes)
- Developers (45-60 minutes)
- Compliance officers (15-20 minutes)

---

## Executive Demo (5-10 Minutes)

**Goal**: Demonstrate business value, ROI, and regulatory compliance impact.

### Prerequisites

```bash
# Ensure Strigoi is installed
strigoi --version

# Ensure vulnerable MCPs are available
ls -la examples/insecure-mcps/
```

### Demo Script

**1. The Problem (2 minutes)**

"AI and LLM integrations are accelerating in banking, but they introduce new security risks that traditional tools miss. Let me show you a real example."

```bash
# Show a typical AI integration
cat examples/insecure-mcps/mcp-http-api/server.py | head -20
```

**Talking Points**:
- AI agents need access to internal systems
- Traditional security tools don't understand AI-specific vulnerabilities
- Regulatory bodies (OCC, FDIC) now require AI security assessments

---

**2. The Discovery (3 minutes)**

"Let's run Strigoi to scan this AI integration for vulnerabilities."

```bash
# Run comprehensive scan
strigoi probe all examples/insecure-mcps/mcp-http-api/
```

**Expected Output**:
```
🚨 CRITICAL FINDINGS (8)

[CRITICAL] Hardcoded API Keys
  File: server.py:12-18
  Risk: Credential theft via source code review
  Impact: Unauthorized API access, $10K+ fraudulent charges

[CRITICAL] SSRF Vulnerability
  File: server.py:45
  Risk: Access to internal AWS metadata endpoint
  Impact: IAM credential theft, infrastructure compromise

[CRITICAL] SQL Injection in Database Query Tool
  File: server.py:78
  Risk: Database compromise via malicious queries
  Impact: Customer data breach, $5M+ regulatory fines

[HIGH] Missing Authentication on Admin Endpoints
  File: server.py:34
  Risk: Unauthorized administrative access
  Impact: Complete system compromise
```

**Talking Points**:
- **8 CRITICAL vulnerabilities** found in seconds
- Each vulnerability mapped to financial impact
- Regulatory compliance violations (GLBA, GDPR)
- **Cost to fix**: $4K (8 hours developer time)
- **Cost if exploited**: $5M - $50M+ (breach + fines)

---

**3. The ROI (2 minutes)**

**Value Calculation**:

| Metric | Value |
|--------|-------|
| Time to discover | 30 seconds |
| Vulnerabilities found | 8 CRITICAL |
| Developer time to fix | 8 hours ($4K) |
| Potential breach cost avoided | $10M - $50M |
| ROI | 2,500x - 12,500x |

**Regulatory Compliance**:
- OCC expects AI security assessments within 30 days of deployment
- Strigoi provides audit-ready reports (SARIF format)
- Automated scanning in CI/CD prevents vulnerabilities from reaching production

---

**4. The Close (1 minute)**

"Strigoi provides continuous AI security monitoring across your entire organization. Let's discuss how we can integrate this into your development pipeline and compliance program."

**Call to Action**:
- Schedule technical deep-dive with security team
- Pilot deployment on internal AI projects
- Compliance assessment consultation

---

## Security Team Demo (20-30 Minutes)

**Goal**: Demonstrate technical capabilities, detection patterns, and integration options.

### Demo Script

**1. Directional Probing Framework (5 minutes)**

Explain the North/South/East/West methodology:

```bash
# North: External attack surface
strigoi probe north examples/insecure-mcps/mcp-http-api/

# South: Supply chain dependencies
strigoi probe south examples/insecure-mcps/mcp-http-api/

# East: Data flow security
strigoi probe east examples/insecure-mcps/mcp-http-api/

# West: Authentication & authorization
strigoi probe west examples/insecure-mcps/mcp-http-api/
```

**Show Results**:
- North finds exposed endpoints without authentication
- South finds vulnerable dependencies (e.g., old axios version)
- East finds hardcoded secrets and PII logging
- West finds missing authentication checks

---

**2. Vulnerable MCP Walkthrough (10 minutes)**

**Example 1: SQL Injection in mcp-sqlite**

```bash
# Show the vulnerable code
cat examples/insecure-mcps/mcp-sqlite/server.py | grep -A 10 "def query_database"

# Run Strigoi detection
strigoi probe all examples/insecure-mcps/mcp-sqlite/
```

**Expected Finding**:
```python
# ❌ CRITICAL: SQL Injection vulnerability
def query_database(sql):
    # No validation, sanitization, or parameterization
    cursor.execute(sql)  # Attacker can inject: DROP TABLE users; --
```

**Exploitation Demo** (if appropriate):
```bash
# Show how an attacker could exploit this
echo "SELECT * FROM users WHERE id = 1 OR 1=1; --" | strigoi probe east examples/insecure-mcps/mcp-sqlite/
```

**Remediation**:
```python
# ✅ Secure: Use parameterized queries
def query_database(table, conditions):
    cursor.execute("SELECT * FROM ? WHERE ?", (table, conditions))
```

---

**Example 2: Path Traversal in mcp-filesystem**

```bash
# Show vulnerability
cat examples/insecure-mcps/mcp-filesystem/server.py | grep -A 10 "def read_file"

# Run Strigoi detection
strigoi probe north examples/insecure-mcps/mcp-filesystem/
```

**Expected Finding**:
```python
# ❌ CRITICAL: Path traversal allows reading /etc/passwd
def read_file(path):
    # No path validation!
    with open(path, 'r') as f:
        return f.read()
```

**Exploitation Demo**:
```bash
# Attacker can read sensitive files
strigoi test-exploit examples/insecure-mcps/mcp-filesystem/ --path ../../../etc/passwd
```

---

**Example 3: SSRF in mcp-http-api**

```bash
# Show vulnerability
cat examples/insecure-mcps/mcp-http-api/server.py | grep -A 15 "def http_get"

# Run Strigoi detection
strigoi probe all examples/insecure-mcps/mcp-http-api/
```

**Expected Finding**:
```python
# ❌ CRITICAL: SSRF allows access to AWS metadata endpoint
def http_get(url):
    # No URL validation!
    return requests.get(url)  # Attacker: http://169.254.169.254/latest/meta-data
```

**Attack Scenario**:
```bash
# Attacker steals AWS IAM credentials
curl http://mcp-server/api/http_get?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

**3. MITRE ATLAS Mapping (3 minutes)**

Show how Strigoi maps vulnerabilities to MITRE ATLAS framework:

```bash
strigoi probe all examples/insecure-mcps/mcp-http-api/ --format json | jq '.findings[] | {severity, atlas_id, tactic}'
```

**Expected Output**:
```json
{
  "severity": "CRITICAL",
  "atlas_id": "AML.T0043",
  "tactic": "Supply Chain Compromise"
}
{
  "severity": "CRITICAL",
  "atlas_id": "AML.T0024",
  "tactic": "Exfiltration via LLM"
}
```

**Talking Points**:
- Strigoi uses MITRE ATLAS (Adversarial Threat Landscape for AI)
- Maps findings to attack tactics and techniques
- Provides context for prioritization and remediation

---

**4. CI/CD Integration (5 minutes)**

Show how to integrate Strigoi into GitHub Actions:

```yaml
# .github/workflows/strigoi-security-scan.yml
name: Strigoi AI Security Scan

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Strigoi Scan
        run: |
          strigoi probe all . --format sarif > strigoi-results.sarif

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: strigoi-results.sarif

      - name: Fail on Critical Findings
        run: |
          strigoi probe all . --severity CRITICAL --format json > findings.json
          if [ $(jq '.findings | length' findings.json) -gt 0 ]; then
            echo "❌ CRITICAL vulnerabilities found"
            exit 1
          fi
```

**Talking Points**:
- Automated scanning on every commit/PR
- Prevents vulnerabilities from reaching production
- GitHub Security integration (SARIF format)
- Customizable severity thresholds

---

**5. Reporting & Compliance (3 minutes)**

Show audit-ready reports:

```bash
# Generate comprehensive report
strigoi probe all examples/insecure-mcps/ --format json > security-assessment.json

# Generate SARIF for GitHub Security
strigoi probe all examples/insecure-mcps/ --format sarif > security-assessment.sarif

# Generate CSV for spreadsheet analysis
strigoi probe all examples/insecure-mcps/ --format csv > security-assessment.csv
```

**Show Report Contents**:
```bash
jq '.summary' security-assessment.json
```

**Expected Output**:
```json
{
  "total_findings": 24,
  "critical": 12,
  "high": 8,
  "medium": 3,
  "low": 1,
  "scan_duration_ms": 1847,
  "files_scanned": 15,
  "mitre_atlas_mappings": 12
}
```

---

## Developer Demo (45-60 Minutes)

**Goal**: Deep technical dive into detection patterns, remediation guidance, and custom integration.

### Demo Script

**1. Installation & Setup (5 minutes)**

```bash
# Download and install Strigoi
curl -sSL https://strigoi.macawi.ai/install.sh | bash

# Verify installation
strigoi --version
strigoi check

# Clone vulnerable examples
git clone https://github.com/macawi-ai/strigoi-examples.git
cd strigoi-examples/insecure-mcps/
```

---

**2. Interactive Shell (10 minutes)**

Demonstrate the interactive shell mode:

```bash
strigoi shell
```

**In the shell**:
```
strigoi> load mcp-http-api/
Loaded: mcp-http-api (Python MCP server, 250 LOC)

strigoi> probe north
Running North probe (external interfaces)...
Found 4 CRITICAL vulnerabilities

strigoi> show findings --severity CRITICAL
[CRITICAL] Hardcoded OpenAI API Key
  File: server.py:12
  Pattern: OPENAI_API_KEY = "sk-proj-..."
  MITRE: AML.T0043 (Supply Chain Compromise)

strigoi> explain AML.T0043
MITRE ATLAS: AML.T0043 - Supply Chain Compromise
...

strigoi> remediate server.py:12
Suggested remediation:
  - Remove hardcoded key from source code
  - Use environment variable: os.environ.get("OPENAI_API_KEY")
  - Or use secret manager: AWS Secrets Manager, HashiCorp Vault

strigoi> exit
```

---

**3. Detection Pattern Deep Dive (15 minutes)**

**Pattern 1: API Key Detection**

```bash
# Show detection regex
cat ~/.strigoi/patterns/secrets.yaml

# Run focused scan
strigoi probe east mcp-http-api/ --pattern api_key
```

**Pattern 2: PII Detection**

```bash
# Show PII patterns (SSN, credit cards, etc.)
cat ~/.strigoi/patterns/pii.yaml

# Scan for PII logging
strigoi probe east mcp-http-api/ --pattern pii --check-logs
```

**Pattern 3: SQL Injection**

```bash
# Show SQL injection patterns
cat ~/.strigoi/patterns/sql-injection.yaml

# Scan database interactions
strigoi probe west mcp-sqlite/ --pattern sql_injection
```

---

**4. Custom Pattern Development (10 minutes)**

Show how to create custom detection patterns:

```yaml
# ~/.strigoi/patterns/custom-banking.yaml
patterns:
  - id: BANK_ROUTING_NUMBER
    name: Bank Routing Number Exposure
    severity: HIGH
    regex: '\b\d{9}\b'
    context: 'Banking routing numbers should not be logged or transmitted insecurely'
    mitre_atlas: AML.T0024

  - id: SWIFT_CODE_EXPOSURE
    name: SWIFT Code in Logs
    severity: CRITICAL
    regex: '[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?'
    context: 'SWIFT codes in logs indicate potential transaction data leakage'
    mitre_atlas: AML.T0024
```

**Test custom patterns**:
```bash
strigoi probe east . --pattern-file ~/.strigoi/patterns/custom-banking.yaml
```

---

**5. Remediation Workflow (10 minutes)**

Show full vulnerability → remediation → validation workflow:

**Step 1: Detect**
```bash
strigoi probe all mcp-http-api/ > initial-scan.json
```

**Step 2: Prioritize**
```bash
# Filter CRITICAL findings
jq '.findings[] | select(.severity == "CRITICAL")' initial-scan.json
```

**Step 3: Fix**
```python
# Before (server.py:12)
OPENAI_API_KEY = "sk-proj-abc123..."

# After (server.py:12)
import os
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
```

**Step 4: Validate**
```bash
# Re-scan to confirm fix
strigoi probe east mcp-http-api/ --severity CRITICAL
```

**Expected Output**:
```
✅ No CRITICAL findings detected
Previous scan: 8 CRITICAL
Current scan: 0 CRITICAL
Improvement: 100%
```

---

**6. Advanced: Stream Tapping (5 minutes)**

Show real-time MCP communication monitoring:

```bash
# Start MCP server
python3 mcp-http-api/server.py &

# Start stream tapping
strigoi tap --mcp-server localhost:3000 --output tap-results.jsonl
```

**In another terminal, trigger MCP requests**:
```bash
# Simulate AI agent requests
curl -X POST http://localhost:3000/mcp/call \
  -H "Content-Type: application/json" \
  -d '{"tool": "http_get", "params": {"url": "http://169.254.169.254/latest/meta-data"}}'
```

**Show captured results**:
```bash
cat tap-results.jsonl | jq
```

**Expected Output**:
```json
{
  "timestamp": "2025-01-15T10:30:45Z",
  "finding": {
    "severity": "CRITICAL",
    "type": "SSRF_ATTEMPT",
    "url": "http://169.254.169.254/latest/meta-data",
    "risk": "AWS metadata endpoint access attempt"
  }
}
```

---

## Compliance Officer Demo (15-20 Minutes)

**Goal**: Demonstrate regulatory compliance capabilities, audit readiness, and risk documentation.

### Demo Script

**1. Regulatory Context (3 minutes)**

**Talking Points**:
- OCC, FDIC, Fed require AI risk management frameworks
- GLBA requires safeguarding customer financial data
- GDPR/CCPA mandate data protection assessments
- PCI-DSS for payment card data security

"Strigoi provides audit-ready documentation for all these regulatory requirements."

---

**2. Compliance Scan (5 minutes)**

```bash
# Run comprehensive compliance scan
strigoi probe all . --compliance glba,gdpr,pci-dss --format json > compliance-report.json
```

**Show compliance mapping**:
```bash
jq '.findings[] | {severity, regulation, requirement, finding}' compliance-report.json
```

**Expected Output**:
```json
{
  "severity": "CRITICAL",
  "regulation": "GLBA",
  "requirement": "Section 501(b) - Safeguards Rule",
  "finding": "Customer SSN logged to application logs without encryption"
}
{
  "severity": "CRITICAL",
  "regulation": "GDPR",
  "requirement": "Article 32 - Security of Processing",
  "finding": "Personal data stored unencrypted in Redis cache"
}
{
  "severity": "HIGH",
  "regulation": "PCI-DSS",
  "requirement": "Requirement 6.5.1 - Injection Flaws",
  "finding": "SQL injection vulnerability in payment processing endpoint"
}
```

---

**3. Risk Quantification (5 minutes)**

```bash
# Generate risk assessment report
strigoi assess-risk . --format json > risk-assessment.json
```

**Show risk scoring**:
```bash
jq '.risk_summary' risk-assessment.json
```

**Expected Output**:
```json
{
  "overall_risk_score": 8.7,
  "risk_level": "HIGH",
  "critical_vulnerabilities": 8,
  "estimated_breach_cost": "$10M - $50M",
  "regulatory_fines_exposure": "$5M - $20M",
  "remediation_cost_estimate": "$4,000 - $8,000",
  "roi_from_remediation": "1,250x - 12,500x"
}
```

---

**4. Audit Trail Documentation (3 minutes)**

```bash
# Generate audit-ready report with evidence
strigoi report --format pdf \
  --include-evidence \
  --include-screenshots \
  --compliance glba,gdpr,pci-dss \
  --output AI-Security-Assessment-2025-01-15.pdf
```

**Report Contents**:
- Executive summary
- Vulnerability details with evidence
- MITRE ATLAS mapping
- Regulatory compliance mapping
- Remediation recommendations
- Risk quantification
- Timeline for fixes

---

**5. Continuous Monitoring (3 minutes)**

Show how to implement ongoing compliance monitoring:

```yaml
# .github/workflows/compliance-scan.yml
name: Monthly Compliance Scan

on:
  schedule:
    - cron: '0 0 1 * *'  # First day of each month

jobs:
  compliance-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Compliance Scan
        run: |
          strigoi probe all . --compliance glba,gdpr,pci-dss --format json > compliance-$(date +%Y-%m).json

      - name: Upload Compliance Report
        uses: actions/upload-artifact@v3
        with:
          name: compliance-reports
          path: compliance-*.json

      - name: Notify Compliance Team
        if: failure()
        run: |
          # Send email/Slack notification to compliance team
          echo "New compliance findings detected. Review required."
```

---

## Custom Demo Scenarios

### Scenario 1: Banking Chatbot Security

**Context**: Regional bank deploying AI customer service chatbot.

**Demo**:
```bash
# Scan chatbot integration
strigoi probe all banking-chatbot/ --focus pii,credentials,data-leakage
```

**Expected Findings**:
- Customer SSNs logged to application logs
- Chat history stored unencrypted in Redis
- OpenAI API key hardcoded in source code
- No rate limiting on chat endpoint

**Business Impact**:
- GLBA violation: $10M fine exposure
- Data breach cost: $5M - $50M
- Regulatory examination finding

---

### Scenario 2: Payment Processing API

**Context**: Fintech startup processing payments via Stripe.

**Demo**:
```bash
# Scan payment API
strigoi probe all payment-api/ --focus api-keys,pci-dss,encryption
```

**Expected Findings**:
- Stripe secret key in client-side code
- Credit card numbers logged to files
- Payment data transmitted via HTTP (not HTTPS)

**Business Impact**:
- PCI-DSS violation: Loss of payment processing ability
- Stripe account suspension
- Fraud exposure: $500K+

---

### Scenario 3: Core Banking Integration

**Context**: AI fraud detection integrating with core banking system.

**Demo**:
```bash
# Scan core banking integration
strigoi probe all fraud-detection/ --focus authentication,authorization,data-flows
```

**Expected Findings**:
- SWIFT message endpoints without authentication
- Account numbers in plaintext logs
- Missing encryption on wire transfer details

**Business Impact**:
- OCC/FDIC examination finding
- Wire fraud exposure: $10M+
- Regulatory sanctions

---

## Demo Best Practices

### Preparation Checklist

✅ Verify Strigoi installation and version
✅ Ensure vulnerable MCPs are available
✅ Test all commands before demo
✅ Prepare backup slides in case of technical issues
✅ Know your audience and tailor messaging
✅ Have customer-specific examples ready
✅ Prepare ROI calculations
✅ Have pricing and pilot proposal ready

---

### Timing Guidelines

**Executive Demo**:
- Problem: 20% (2 min)
- Discovery: 30% (3 min)
- ROI: 30% (2 min)
- Close: 20% (1 min)

**Technical Demo**:
- Introduction: 10% (2-3 min)
- Capabilities: 50% (10-15 min)
- Integration: 20% (4-6 min)
- Q&A: 20% (4-6 min)

**Compliance Demo**:
- Regulatory context: 20% (3 min)
- Compliance scan: 30% (5 min)
- Risk quantification: 25% (4 min)
- Audit trail: 15% (2 min)
- Q&A: 10% (2 min)

---

### Engagement Techniques

**Ask Questions**:
- "What AI/LLM integrations are you currently deploying?"
- "What's your biggest security concern with AI?"
- "Have you had a security assessment of your AI systems?"

**Relate to Pain Points**:
- "Other banks we've worked with had similar concerns about..."
- "This is exactly the scenario that resulted in a $10M fine for..."
- "Your compliance team will appreciate having audit-ready reports like this..."

**Demonstrate Value**:
- Always show before/after
- Quantify cost savings
- Relate to regulatory requirements
- Show integration ease

---

### Handling Objections

**"We already have security scanning tools"**
- Response: "Traditional tools don't understand AI-specific vulnerabilities like prompt injection, model extraction, or MCP security. Strigoi is purpose-built for AI/LLM security. Let me show you what traditional tools miss..."

**"This looks complicated"**
- Response: "The interface is actually quite simple. Let me show you - a single command scans your entire codebase. And we provide GitHub Actions templates for complete automation."

**"What's the pricing?"**
- Response: "We have flexible pricing based on number of developers and scan frequency. For a team your size, we typically see deployments in the $X-$Y range. But let's first confirm this solves your specific challenges. Can I show you a pilot deployment?"

**"How long does implementation take?"**
- Response: "Most customers are scanning code within the first day. Full CI/CD integration typically takes 2-3 days. We provide hands-on support during the pilot."

---

## Follow-Up Actions

### After Executive Demo

1. **Send summary email** with:
   - Demo recording (if permitted)
   - ROI calculation specific to their environment
   - Case study (similar industry/size)
   - Pilot proposal

2. **Schedule technical follow-up** with:
   - Security team
   - Development team
   - Compliance officer

3. **Provide resources**:
   - Link to documentation
   - Vulnerable MCP examples for testing
   - Free trial access

---

### After Technical Demo

1. **Provide sandbox access**:
   - Strigoi installation instructions
   - Vulnerable MCPs for testing
   - Sample GitHub Actions workflow

2. **Technical documentation**:
   - API specification
   - Custom pattern development guide
   - Integration examples

3. **Schedule pilot kickoff**:
   - Define scope (which projects to scan)
   - Integration timeline
   - Success metrics

---

### After Compliance Demo

1. **Provide compliance templates**:
   - Risk assessment template
   - Audit report template
   - Regulatory mapping guide

2. **Schedule compliance review**:
   - Review current AI deployments
   - Identify compliance gaps
   - Create remediation roadmap

3. **Quarterly compliance plan**:
   - Automated monthly scans
   - Quarterly compliance reports
   - Annual risk assessment

---

## Troubleshooting Demo Issues

### Issue: Strigoi not finding vulnerabilities

**Cause**: Scanning wrong directory or MCP not properly structured

**Fix**:
```bash
# Verify you're in the correct directory
pwd
ls -la

# Check MCP structure
cat mcp-http-api/server.py | head -20

# Run with verbose output
strigoi probe all . --verbose
```

---

### Issue: Output not displaying properly

**Cause**: Terminal encoding issues

**Fix**:
```bash
# Set UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Or use plain text output
strigoi probe all . --no-color --format text
```

---

### Issue: GitHub Actions integration failing

**Cause**: SARIF format compatibility

**Fix**:
```yaml
# Use GitHub-compatible SARIF version
- name: Run Strigoi Scan
  run: |
    strigoi probe all . --format sarif --sarif-version 2.1.0 > strigoi-results.sarif
```

---

## Next Steps

**Ready to demonstrate?**
→ [Vulnerable MCP Installation](./vulnerable-mcps/installation.md)

**Need test scenarios?**
→ [Test Scenarios](./test-scenarios.md)

**Want validation checklist?**
→ [Validation Checklist](./validation-checklist.md)

**Questions?**
→ [FAQ](../reference/faq.md)
→ [Troubleshooting](../reference/troubleshooting.md)

---

*Demo flow: Show value fast, demonstrate deeply, close confidently.*
