# Use Cases

**How banks and enterprises use Strigoi to secure AI deployments.**

---

## Banking & Financial Services

### 1. Pre-Deployment AI Security Validation

**Scenario**: Community bank deploying AI-powered document analysis for loan applications.

**Challenge**:
- No existing framework for AI security assessment
- Regulatory examination approaching (OCC, FDIC, or Fed)
- Need to demonstrate due diligence
- Limited security team expertise in AI/LLM

**Strigoi Solution**:
1. Scan AI system with directional probing (`strigoi probe all`)
2. Identify vulnerabilities before production deployment
3. Generate MITRE ATLAS-mapped report for examiners
4. Fix critical issues, document acceptance of lower-risk findings
5. Pass examination with evidence of thorough assessment

**Outcome**: Bank deploys AI confidently, examination passes, no regulatory findings.

---

### 2. Third-Party AI Vendor Risk Assessment

**Scenario**: Mid-size bank ($2B assets) evaluating AI chatbot vendor.

**Challenge**:
- Vendor claims "enterprise-grade security"
- No way to verify without access to source code
- Contractual liability if vendor has breach
- Need objective security assessment

**Strigoi Solution**:
1. Request vendor deploy Strigoi-compatible MCP server
2. Run comprehensive security scan via A2MCP bridge
3. Discover:
   - 7 hardcoded API keys in configuration
   - SQL injection vulnerability in customer query
   - Missing rate limiting (DoS risk)
   - PII logging to plaintext files

4. Present findings to vendor, negotiate:
   - Remediation timeline (30 days)
   - Contractual liability caps
   - Ongoing Strigoi monitoring requirement

**Outcome**: Vendor fixes issues, bank has ongoing visibility, risk managed.

---

### 3. Regulatory Examination Preparation

**Scenario**: Large community bank ($5B assets) with multiple AI use cases, OCC IT examination scheduled.

**Challenge**:
- 8 different AI implementations across departments
- No centralized AI inventory or security assessment
- Examiners expect MITRE framework alignment
- 45 days until examination

**Strigoi Solution**:

**Week 1-2: Discovery**
- Deploy Strigoi across all AI systems
- Run comprehensive scans (all directions)
- Build AI inventory automatically from scan results

**Week 3: Analysis**
- Review findings with security team
- Prioritize CRITICAL/HIGH vulnerabilities
- Map to MITRE ATLAS techniques (automatic)

**Week 4: Remediation**
- Fix CRITICAL issues (hardcoded secrets, SQL injection)
- Document HIGH issues with acceptance rationale
- Create remediation roadmap for MEDIUM/LOW

**Week 5: Documentation**
- Generate examination-ready reports
- Prepare evidence binders (scan results, remediation proof)
- Brief executive team

**Week 6: Examination**
- Present Strigoi methodology to examiners
- Demonstrate comprehensive assessment approach
- Show MITRE ATLAS alignment (regulatory expectation)

**Outcome**: Zero IT examination findings related to AI security. Examiner commends bank's proactive approach.

---

### 4. Continuous AI Security Monitoring

**Scenario**: Regional bank ($15B assets) with production AI systems.

**Challenge**:
- AI systems evolve constantly (new models, features)
- Security posture drifts over time
- Need real-time threat detection
- SIEM integration required

**Strigoi Solution**:

**Architecture**:
```
AI Production Systems
    ↓ (A2MCP bridge)
NATS JetStream (Strigoi)
    ↓ (real-time streaming)
Fleet Manager (alerts)
    ↓ (webhook integration)
Bank SIEM (Splunk/QRadar)
```

**Monitoring**:
- Real-time capture of AI CLI activity
- Automatic vulnerability classification
- Alerts on CRITICAL/HIGH findings
- Weekly security posture reports

**Example Alert**:
```
[CRITICAL] AWS API Key Detected in Prompt
- System: Loan Processing AI
- Tool: Claude Code MCP
- Pattern: AWS_SECRET_ACCESS_KEY
- MITRE: AML.T0043 (Supply Chain Compromise)
- Action: Key rotated, prompt sanitized
```

**Outcome**: Bank detects and remediates AI security issues within minutes, not months.

---

## Enterprise Use Cases

### 5. AI Development Team Security Testing

**Scenario**: SaaS company building AI-powered features.

**Challenge**:
- Development team lacks AI security expertise
- Need to catch vulnerabilities before code review
- Want shift-left security approach
- CI/CD integration required

**Strigoi Solution**:

**Pre-Commit Hook**:
```bash
#!/bin/bash
# .git/hooks/pre-commit
strigoi probe east . --format json --severity CRITICAL,HIGH
if [ $? -ne 0 ]; then
  echo "❌ CRITICAL/HIGH vulnerabilities detected"
  echo "Run 'strigoi probe east .' for details"
  exit 1
fi
```

**GitHub Actions**:
```yaml
- name: Strigoi Security Scan
  run: |
    strigoi probe all . --format sarif > strigoi-results.sarif

- name: Upload to GitHub Security
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: strigoi-results.sarif
```

**Outcome**: Vulnerabilities caught in development, never reach production.

---

### 6. AI Penetration Testing

**Scenario**: Healthcare company deploying HIPAA-compliant AI for patient records.

**Challenge**:
- Annual penetration testing required (HIPAA)
- Traditional pentest firms lack AI/LLM expertise
- Need specialized AI security assessment
- Compliance audit approaching

**Strigoi Solution**:

**Engagement Scope**:
1. **Reconnaissance** (`probe north`) - Map external attack surface
2. **Vulnerability Discovery** (`probe all`) - Comprehensive scan
3. **Exploitation Simulation** - Use Strigoi vulnerable MCPs as training
4. **Risk Assessment** - MITRE ATLAS mapping + severity scoring
5. **Remediation Guidance** - Specific fix recommendations

**Deliverable**: Full penetration test report with:
- Executive summary
- Technical findings with PoC
- MITRE ATLAS technique mapping
- Remediation roadmap
- Compliance attestation

**Outcome**: HIPAA audit passes, AI system certified secure.

---

### 7. AI Vendor Security Certification

**Scenario**: AI infrastructure platform (like Prismatic.io) wants to demonstrate security to customers.

**Challenge**:
- Customers demand security evidence
- Traditional certifications (SOC 2) insufficient for AI
- Need AI-specific security validation
- Competitive differentiation opportunity

**Strigoi Solution**:

**Self-Assessment Process**:
1. Deploy Strigoi against own platform
2. Discover vulnerabilities proactively
3. Fix CRITICAL/HIGH issues
4. Document security posture

**Customer-Facing Certification**:
- **"Strigoi-Certified AI Platform"** badge
- Public security assessment summary
- MITRE ATLAS coverage report
- Ongoing monitoring attestation

**Marketing Value**:
*"Our platform is Strigoi-certified—we found and fixed critical vulnerabilities before you even knew they existed."*

**Outcome**: Competitive advantage, customer trust, enterprise sales wins.

---

#### **Real-World Success: Prismatic.io** ⭐

**Customer**: [Prismatic.io](https://prismatic.io) - AI infrastructure platform for SaaS integrations

**The Challenge**:
Prismatic was about to launch a major GraphQL API update with unknown security vulnerabilities. Traditional security tools (SAST, DAST, penetration testing) gave them a clean bill of health, but they lacked confidence:

*"How do we know our API is actually secure? What if there are vulnerabilities we don't even know to look for?"*

**Strigoi Assessment** (August 2025):
Single-day comprehensive security scan using directional probing framework (North/South/East/West).

**Findings** (4 CRITICAL vulnerabilities):
1. **GraphQL Depth Attack (DoS)** - No query depth limits → infinite nesting possible → complete service denial
2. **Unencrypted Credential Flow** - Customer API keys flowing through unencrypted STDIO channels
3. **Missing Query Complexity Analysis** - No pre-execution cost analysis → expensive queries exhaust resources
4. **No Rate Limiting** - Unlimited requests allowed from single source

**Business Impact if Exploited**:
- **DoS vulnerability**: $500K-$2M+ (platform outage, SLA violations, customer churn)
- **Credential exposure**: $5M-$50M+ (GDPR/CCPA fines, class-action lawsuits, brand destruction)
- **Combined risk**: Multi-million dollar breach potential

**Strigoi Outcome**:
- ✅ All 4 CRITICAL vulnerabilities patched within 48 hours
- ✅ Production launch proceeded securely and on schedule
- ✅ **Zero security incidents** post-launch (6+ months production)
- ✅ **Zero customer breaches** related to discovered vulnerabilities
- ✅ Enterprise contracts secured (security posture validated)

**Return on Investment**:
- **Assessment cost**: <$10K (engineering time + Strigoi)
- **Breach costs prevented**: $5M-$50M+
- **ROI**: **500x - 5,000x** return

**Customer Testimonial**:
> *"Strigoi found critical vulnerabilities we didn't know existed. Their directional probing framework discovered issues that traditional penetration testing and SAST tools completely missed. The assessment gave us confidence to launch our GraphQL API knowing we'd addressed the most critical security risks."*
>
> **— Buzz, Security Team, Prismatic.io**

**Competitive Advantage Gained**:
- **Marketing**: "Strigoi-certified platform" badge
- **Enterprise Sales**: Security validation in RFP responses
- **Customer Confidence**: Transparent security posture
- **Thought Leadership**: Case study demonstrates AI security maturity

👉 **[Read the full Prismatic case study](../case-studies/prismatic.md)** for detailed technical findings, remediation steps, and lessons for banking/financial services.

---

**Key Takeaway**: Prismatic deployed securely. Your organization can too.

---

### 8. AI Supply Chain Security

**Scenario**: Fortune 500 company using 20+ AI SaaS vendors.

**Challenge**:
- No visibility into vendor AI security
- Supply chain risk (third-party breach)
- Need unified security monitoring
- Board-level reporting required

**Strigoi Solution**:

**Centralized Monitoring Architecture**:
```
Vendor 1 AI → A2MCP → ┐
Vendor 2 AI → A2MCP → ├→ Central NATS → Strigoi Fleet Manager
Vendor 3 AI → A2MCP → ┘                        ↓
...                                     Executive Dashboard
```

**Monthly Board Report**:
- AI vendor security scorecard
- Vulnerability trends
- MITRE ATLAS heatmap
- Risk metrics (CRITICAL/HIGH count)

**Vendor Requirements**:
- Must support Strigoi monitoring
- Quarterly security scans mandatory
- Remediation SLAs enforced
- Audit rights in contract

**Outcome**: Board has AI supply chain visibility, vendor risk managed proactively.

---

## Education & Training

### 9. AI Security Training for Bank Staff

**Scenario**: SBS CyberSecurity Institute training program for community banks.

**Challenge**:
- Banks lack AI security expertise
- Need hands-on training (not just theory)
- Want realistic vulnerability examples
- Certificate program for CPE credits

**Strigoi Solution**:

**Course Module: "AI/LLM Security Fundamentals"**

**Lab 1: Install Vulnerable MCPs**
```bash
cd examples/insecure-mcps
./install-all.sh
```

**Lab 2: Exploit Vulnerabilities**
- SQL injection in mcp-sqlite
- Path traversal in mcp-filesystem
- SSRF in mcp-http-api

**Lab 3: Detect with Strigoi**
```bash
strigoi probe east ~/.strigoi/mcps/
strigoi probe west ~/.strigoi/mcps/
```

**Lab 4: Remediate**
- Parameterized SQL queries
- Path sanitization
- URL allowlisting

**Outcome**: Bank staff gain hands-on AI security expertise, CPE credits earned.

---

## Research & Academia

### 10. AI Security Research

**Scenario**: University research team studying LLM vulnerabilities.

**Challenge**:
- Need reproducible test environment
- Want to contribute to AI security field
- Require real-world vulnerability examples
- Academic publication goals

**Strigoi Solution**:

**Research Framework**:
1. Use Strigoi vulnerable MCPs as baseline
2. Develop new attack techniques
3. Test detection with Strigoi
4. Publish findings + PoC code
5. Contribute detection patterns back to Strigoi

**Academic Contributions**:
- Novel prompt injection patterns
- MITRE ATLAS technique extensions
- Defense mechanisms
- Benchmark datasets

**Outcome**: Strigoi becomes academic standard for AI security research.

---

## Next Steps

**Identify your use case above?**
→ [Installation Guide](./installation/README.md) - Get started

**Want to see it in action?**
→ [Quick Start Guide](./quick-start.md) - Run your first scan

**Need to demo to stakeholders?**
→ [Demo Flow](../testing/demo-flow.md) - Presentation-ready walkthrough

**Questions about deployment?**
→ [Operations Guide](../operations/deployment/README.md) - Production deployment

---

*Strigoi: From community banks to Fortune 500—AI security for everyone.*
