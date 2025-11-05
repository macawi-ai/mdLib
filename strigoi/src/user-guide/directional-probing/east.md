# East: Data Flows

**Scan how data moves through your AI systems - from inputs to outputs, logging to storage.**

---

## What East Probing Detects

**EAST** direction focuses on **data flow security** - how information moves, transforms, and persists in your AI systems:

- 🔑 **Hardcoded Secrets** - API keys, passwords, tokens in code
- 💾 **Data Leakage** - PII, credentials logged or stored insecurely
- 🔄 **Unsafe Serialization** - Pickle, YAML, XML vulnerabilities
- 📝 **Logging Sensitive Data** - Secrets written to logs
- 🌊 **Unencrypted Data Flows** - Credentials in plaintext channels

**The tracking question**: Where does sensitive data go, and is it protected?

---

## Why East Probing Matters

### The Data Flow Problem

**Banking scenario**: Regional bank implements AI loan approval system.

**Without East probing**:
- Customer SSNs logged to application logs (plaintext)
- OpenAI API key hardcoded in source code
- Credit scores stored unencrypted in Redis cache
- Loan decisions transmitted via unencrypted HTTP
- **Result**: Data breach, $10M regulatory fines (GLBA, GDPR violations)

**With East probing**:
- Strigoi discovers PII logging immediately
- Hardcoded API key flagged as CRITICAL
- Unencrypted cache storage detected
- HTTP transmission identified
- **Result**: All vulnerabilities fixed pre-production, compliance maintained

---

## How East Probing Works

### Command Syntax

```bash
# Scan data flows in current directory
strigoi probe east .

# Scan specific MCP server
strigoi probe east ~/.strigoi/mcps/mcp-http-api/

# Include configuration files
strigoi probe east . --include-config

# Output to JSON
strigoi probe east . --format json > east-findings.json
```

### What Strigoi Analyzes

**1. Secret Detection**:
- API keys (OpenAI, AWS, Google, Stripe, etc.)
- Database passwords
- SSH private keys
- OAuth tokens
- JWT secrets

**2. PII Exposure**:
- Social Security Numbers (SSN)
- Credit card numbers
- Email addresses
- Phone numbers
- Physical addresses

**3. Data Storage**:
- Unencrypted databases
- Insecure cache storage
- Plaintext log files
- Temporary file risks

**4. Data Transmission**:
- Unencrypted HTTP connections
- Credentials in URL parameters
- Sensitive data in query strings
- Missing TLS encryption

---

## Detection Patterns

### Pattern 1: Hardcoded API Keys

**What Strigoi finds**:
```python
# server.py
OPENAI_API_KEY = "sk-proj-abc123def456789..."  # ❌ CRITICAL
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"         # ❌ CRITICAL
STRIPE_SECRET = "sk_live_51HqE..."              # ❌ CRITICAL

def call_openai(prompt):
    headers = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    response = requests.post("https://api.openai.com/v1/chat/completions",
                            headers=headers, json={"prompt": prompt})
    return response.json()
```

**Why this matters**:
- Source code review exposes all keys
- Git history contains keys forever
- Shared repositories leak credentials
- Automated scanners find exposed keys

**Banking impact**:
- OpenAI key → $10K+ fraudulent API usage
- AWS key → S3 bucket exfiltration, EC2 abuse
- Stripe key → payment fraud, $1M+ losses

**MITRE ATLAS**: AML.T0043 (Supply Chain Compromise)

**Remediation**:
```python
import os

# ✅ Use environment variables
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
AWS_ACCESS_KEY = os.environ.get("AWS_ACCESS_KEY")
STRIPE_SECRET = os.environ.get("STRIPE_SECRET")

# ✅ Or use AWS Secrets Manager
import boto3

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

OPENAI_API_KEY = get_secret("prod/openai/api_key")
```

---

### Pattern 2: PII Logging

**What Strigoi finds**:
```python
@app.route('/apply-loan', methods=['POST'])
def apply_loan():
    ssn = request.json['ssn']
    credit_score = request.json['credit_score']
    income = request.json['income']

    # ❌ CRITICAL: Logs contain PII
    logging.info(f"Loan application: SSN={ssn}, credit_score={credit_score}, income={income}")

    # ❌ CRITICAL: Error logs contain PII
    try:
        result = process_loan(ssn, credit_score)
    except Exception as e:
        logging.error(f"Failed for SSN {ssn}: {e}")

    return result
```

**Regulatory violations**:
- **GLBA** - Financial privacy requirements violated
- **GDPR** - Personal data logged without consent
- **CCPA** - California consumer privacy violated
- **PCI-DSS** - Credit data improperly stored

**Financial impact**: $10M+ fines per violation

**Remediation**:
```python
import hashlib

def redact_pii(value):
    """Hash PII for logging"""
    return hashlib.sha256(value.encode()).hexdigest()[:8]

@app.route('/apply-loan', methods=['POST'])
def apply_loan():
    ssn = request.json['ssn']
    credit_score = request.json['credit_score']

    # ✅ Log redacted identifiers only
    logging.info(f"Loan application: ID={redact_pii(ssn)}, credit_score={credit_score}")

    try:
        result = process_loan(ssn, credit_score)
    except Exception as e:
        # ✅ No PII in error logs
        logging.error(f"Loan processing failed: {e.__class__.__name__}")

    return result
```

---

### Pattern 3: Unencrypted Data Storage

**What Strigoi finds**:
```python
import redis

redis_client = redis.Redis(host='localhost', port=6379)

def cache_customer_data(customer_id, data):
    # ❌ CRITICAL: Stores PII unencrypted in Redis
    redis_client.set(f"customer:{customer_id}", json.dumps({
        "ssn": data['ssn'],
        "credit_card": data['credit_card'],
        "account_balance": data['balance']
    }))
```

**Attack vector**:
```bash
# Attacker gains Redis access
redis-cli KEYS "customer:*"
redis-cli GET "customer:12345"
# Result: All PII exposed in plaintext
```

**Banking impact**:
- Customer data breach
- Regulatory violations (GLBA, GDPR)
- Class-action lawsuits
- **Cost**: $5M - $50M+

**Remediation**:
```python
from cryptography.fernet import Fernet
import os

# ✅ Use encryption
encryption_key = os.environ.get("ENCRYPTION_KEY").encode()
cipher = Fernet(encryption_key)

def cache_customer_data(customer_id, data):
    # ✅ Encrypt before storing
    sensitive_data = json.dumps({
        "ssn": data['ssn'],
        "credit_card": data['credit_card'],
        "account_balance": data['balance']
    })

    encrypted = cipher.encrypt(sensitive_data.encode())
    redis_client.set(f"customer:{customer_id}", encrypted)

def get_customer_data(customer_id):
    # ✅ Decrypt when retrieving
    encrypted = redis_client.get(f"customer:{customer_id}")
    decrypted = cipher.decrypt(encrypted)
    return json.loads(decrypted)
```

---

### Pattern 4: Credentials in URLs

**What Strigoi finds**:
```python
# ❌ CRITICAL: API key in URL
api_url = f"https://api.example.com/data?key={API_KEY}&customer_id={customer_id}"
response = requests.get(api_url)

# ❌ HIGH: Credentials logged in web server access logs
# GET /data?key=sk-abc123&customer_id=12345 HTTP/1.1
```

**Why this matters**:
- Web server logs contain credentials
- Proxy logs expose API keys
- CDN caches may store URLs
- Browser history leaks secrets

**Remediation**:
```python
# ✅ Use Authorization header
headers = {"Authorization": f"Bearer {API_KEY}"}
api_url = f"https://api.example.com/data"
response = requests.get(api_url, headers=headers, params={"customer_id": customer_id})
```

---

## Real-World Examples

### Example 1: Banking Chatbot PII Leakage

**Scenario**: Community bank launches AI customer service chatbot.

**East Probe Findings**:
```
🚨 CRITICAL FINDINGS (5)

[CRITICAL] SSN Logged to Application Logs
  File: chatbot.py:45
  Pattern: logging.info(f"Customer SSN: {ssn}")
  Risk: PII exposure via log analysis
  Impact: GLBA violation, $10M fine

[CRITICAL] Hardcoded OpenAI API Key
  File: ai_service.py:12
  Pattern: OPENAI_KEY = "sk-proj-..."
  Risk: API key theft, fraudulent usage
  Impact: $10K+ unauthorized charges

[CRITICAL] Credit Scores in Redis (Unencrypted)
  File: cache.py:28
  Pattern: redis.set("score", credit_score)
  Risk: Customer financial data exposure
  Impact: Regulatory violations

[HIGH] Customer Emails in Error Messages
  File: error_handler.py:19
  Pattern: return f"Error for {email}: {error}"
  Risk: PII disclosure via error responses
  Impact: Privacy violation

[HIGH] Database Password in Git Repository
  File: config.py:7
  Pattern: DB_PASSWORD = "SuperSecret123!"
  Risk: Credential theft via source code
  Impact: Database compromise
```

**Remediation time**: 8 hours
**Cost to fix**: $4K (developer time)
**Cost if exploited**: $10M+ (GLBA fines + breach costs)

---

### Example 2: Payment Processor Credential Leakage

**Scenario**: Fintech startup processes payments via Stripe.

**East Probe Findings**:
```
🚨 CRITICAL FINDINGS (3)

[CRITICAL] Stripe Secret Key in Client-Side Code
  File: payment.js:15
  Pattern: const STRIPE_KEY = "sk_live_51HqE..."
  Risk: Secret key exposed to browsers
  Impact: Unlimited payment fraud

[CRITICAL] Customer Credit Cards in Logs
  File: payment_processor.py:34
  Pattern: logging.info(f"Charged card {card_number}")
  Risk: PCI-DSS violation
  Impact: Loss of payment processing ability

[HIGH] Transaction Data via HTTP (not HTTPS)
  File: api_client.py:22
  Pattern: requests.post("http://internal-api...")
  Risk: Man-in-the-middle attacks
  Impact: Payment interception
```

**Actual incident**:
- Stripe key discovered by researcher
- $500K fraudulent charges attempted
- Stripe blocked account (business interruption)
- Emergency key rotation required
- **Total cost**: $50K (incident response + lost revenue)

---

## Banking-Specific Risks

### Risk 1: Core Banking System Integration

**Vulnerability**: Customer data flows between AI and core banking without encryption.

**Detection**:
```bash
strigoi probe east /path/to/banking-integration/
```

**Common findings**:
- Account numbers in plaintext logs
- SWIFT messages logged unencrypted
- Wire transfer details in temporary files
- Customer PII in error messages

**Regulatory impact**: Automatic OCC/FDIC examination finding

---

### Risk 2: Mobile Banking Data Flows

**Vulnerability**: AI features in mobile apps leak customer data.

**East probe findings**:
- Session tokens in URL parameters
- Account balances cached unencrypted
- Biometric data logged to analytics
- Customer locations transmitted insecurely

**Financial impact**: $500K - $5M+ per breach

---

## Command Options

### Basic Commands

```bash
# Scan current directory
strigoi probe east .

# Scan specific path
strigoi probe east /path/to/project

# Scan MCP server
strigoi probe east ~/.strigoi/mcps/
```

### Advanced Options

```bash
# Include configuration files
strigoi probe east . --include-config

# Filter by secret type
strigoi probe east . --secret-type api_key,password

# Check specific patterns
strigoi probe east . --pattern "sk-" --pattern "AKIA"

# Output formats
strigoi probe east . --format json
strigoi probe east . --format sarif
strigoi probe east . --format csv
```

---

## Integration with CI/CD

### Pre-Commit Hook Example

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running Strigoi East probe for secrets..."

strigoi probe east . --severity CRITICAL --format json > secrets.json

if [ $(jq '.findings | length' secrets.json) -gt 0 ]; then
  echo "❌ CRITICAL: Secrets detected in commit!"
  jq '.findings[] | "\(.file):\(.line) - \(.pattern)"' secrets.json
  echo ""
  echo "Remove secrets before committing."
  exit 1
fi

echo "✅ No secrets detected"
exit 0
```

### GitHub Actions Example

```yaml
name: Strigoi East Data Flow Scan

on: [push, pull_request]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for secret detection

      - name: Run East Probe
        run: |
          strigoi probe east . --format sarif > east-results.sarif

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: east-results.sarif

      - name: Block on Secrets
        run: |
          strigoi probe east . --severity CRITICAL --format json > secrets.json
          if [ $(jq '.findings | length' secrets.json) -gt 0 ]; then
            echo "❌ Secrets detected in code!"
            exit 1
          fi
```

---

## Interpreting Results

### Severity Levels

**CRITICAL** - Immediate removal required:
- Hardcoded API keys (OpenAI, AWS, Stripe)
- Database passwords in code
- SSH private keys committed
- Customer PII logged to files

**HIGH** - Fix before deployment:
- Credentials in URL parameters
- Unencrypted data storage
- PII in error messages
- Weak encryption algorithms

**MEDIUM** - Address in next sprint:
- Debug logging enabled in production
- Temporary files not cleaned up
- Session tokens in logs

**LOW** - Monitor and document:
- Non-sensitive configuration in code
- Public API endpoints in code
- Informational logging

---

## Best Practices

### Data Flow Security Checklist

✅ Never hardcode secrets (use environment variables or secret managers)
✅ Encrypt all PII at rest and in transit
✅ Redact sensitive data in logs
✅ Use Authorization headers (never URL parameters for credentials)
✅ Implement data classification (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED)
✅ Audit all data flows quarterly
✅ Rotate secrets regularly (90 days)
✅ Use TLS 1.3+ for all data transmission

### Incident Response for Data Leakage

**When East probe finds exposed secrets**:

1. **Immediate action** (< 1 hour)
   - Rotate compromised credentials
   - Revoke exposed API keys
   - Block compromised accounts

2. **Investigation** (< 4 hours)
   - Check logs for unauthorized access
   - Determine exposure window
   - Assess damage

3. **Remediation** (< 24 hours)
   - Remove secrets from code
   - Implement proper secret management
   - Deploy fixes to production

4. **Post-mortem** (< 1 week)
   - Document incident
   - Update security procedures
   - Train development team

---

## Complementary Directions

**After East probing, scan**:

- **NORTH** - Check if data flows through external APIs securely
- **SOUTH** - Verify secret management libraries are up-to-date
- **WEST** - Confirm authentication protects data flows
- **ALL** - Comprehensive security assessment

---

## Tools Integration

### Git-Secrets Integration

```bash
# Install git-secrets
brew install git-secrets

# Configure patterns
git secrets --add 'sk-[a-zA-Z0-9]{32}'  # OpenAI keys
git secrets --add 'AKIA[A-Z0-9]{16}'    # AWS keys

# Scan repository
git secrets --scan

# Compare with Strigoi
strigoi probe east . --format json > strigoi-secrets.json
```

### TruffleHog Integration

```bash
# Scan git history for secrets
trufflehog git file://. --json > trufflehog.json

# Cross-reference with Strigoi
strigoi probe east . --compare trufflehog.json
```

---

## Next Steps

**Ready to scan?**
→ [Installation Guide](../../getting-started/installation/README.md)

**Learn other directions**:
→ [North: External Interfaces](./north.md)
→ [South: Dependencies](./south.md)
→ [West: Authentication](./west.md)
→ [All: Comprehensive Scan](./all.md)

**Need help?**
→ [Troubleshooting Guide](../../operations/maintenance/troubleshooting.md)
→ [FAQ](../../reference/faq.md)

---

*East probing: Follow the data, protect what matters.*
