# mcp-http-api: SSRF & Secrets Galore

**Intentionally vulnerable HTTP API MCP server demonstrating SSRF, hardcoded secrets, and credential theft.**

---

## ⚠️ WARNING: INTENTIONALLY VULNERABLE CODE

**🚨 DO NOT USE IN PRODUCTION 🚨**
**🚨 FOR TESTING AND TRAINING ONLY 🚨**

---

## Overview

**What it does**: Provides Claude Code access to make HTTP requests to external APIs (supposedly for legitimate integrations).

**Banking relevance**: Similar vulnerabilities could expose internal networks, steal cloud credentials, leak API keys, and enable lateral movement attacks.

**Vulnerability count**: 15 CRITICAL/HIGH issues

---

## Critical Vulnerabilities

### 1. Seven Hardcoded API Keys (CRITICAL)

**Location**: `server.py:7-13`

**The vulnerability**:
```python
# ❌ CRITICAL: All API keys hardcoded in source code
OPENAI_API_KEY = "sk-proj-abc123def456..."
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
GOOGLE_API_KEY = "AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY"
STRIPE_SECRET_KEY = "sk_live_51HqE..."
TWILIO_AUTH_TOKEN = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
DATABASE_PASSWORD = "SuperSecret123!"
```

**Attack vector**:
```
1. Attacker reviews source code (GitHub, code review, stolen laptop)
2. Extracts all 7 API keys
3. Uses stolen credentials for:
   - OpenAI: Fraudulent API usage ($10K+)
   - AWS: Data exfiltration, resource abuse ($100K+)
   - Stripe: Payment fraud ($1M+)
   - Twilio: SMS phishing campaigns
```

**Banking impact**: Complete credential compromise across:
- Payment processing (Stripe) → fraudulent transactions
- Cloud infrastructure (AWS) → data exfiltration
- AI services (OpenAI) → unauthorized AI usage
- Communication channels (Twilio) → phishing attacks

**What Strigoi detects**: Variables containing `sk-`, `AKIA`, `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`

---

### 2. Server-Side Request Forgery - SSRF (CRITICAL)

**Location**: `server.py:25-30` (`http_get` function)

**The vulnerability**:
```python
@mcp.tool()
def http_get(url: str) -> str:
    """Make HTTP GET request to any URL"""
    # ❌ No URL validation whatsoever!
    response = requests.get(url, verify=False)  # ❌ TLS disabled too!
    return response.text
```

**Attack vector**:
```
# Access AWS metadata endpoint (steal EC2 IAM credentials)
url = "http://169.254.169.254/latest/meta-data/iam/security-credentials/"

# Access internal network services
url = "http://192.168.1.10/admin/secrets"

# Read local files via file:// protocol
url = "file:///etc/passwd"

# Access internal APIs
url = "http://localhost:8080/internal/admin"
```

**Banking impact**: Attackers can:
- Steal AWS IAM credentials from metadata endpoint
- Access internal banking APIs (transaction systems, customer databases)
- Scan internal network (reconnaissance for larger attack)
- Exfiltrate customer data via internal endpoints

**What Strigoi detects**: `requests.get(url, ...)` without URL validation, missing allowlist checks

---

### 3. AWS Metadata Service Access (CRITICAL)

**Location**: `server.py:45-52` (`get_aws_metadata` function)

**The vulnerability**:
```python
@mcp.tool()
def get_aws_metadata() -> str:
    """Access AWS EC2 metadata endpoint"""
    # ❌ Intentionally accesses metadata endpoint!
    metadata_url = "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
    response = requests.get(metadata_url)
    return response.text
```

**Attack vector**:
```
1. Attacker calls get_aws_metadata() tool via LLM prompt
2. Gets IAM role name from metadata endpoint
3. Calls metadata endpoint with role name
4. Receives temporary AWS credentials (AccessKeyId, SecretAccessKey, SessionToken)
5. Uses credentials to access S3, RDS, EC2
```

**Banking impact**: Complete AWS account compromise:
- S3 bucket exfiltration (customer data)
- RDS database access (transaction history, PII)
- EC2 resource abuse (cryptocurrency mining)
- **Cost**: $500K - $5M+ (breach response, GDPR fines, customer lawsuits)

**What Strigoi detects**: Hardcoded `169.254.169.254` IP address, metadata endpoint patterns

---

### 4. Hardcoded Database Credentials (CRITICAL)

**Location**: `server.py:55-63` (`query_database` function)

**The vulnerability**:
```python
def query_database(sql: str) -> dict:
    """Execute SQL query on internal database"""
    # ❌ Hardcoded database credentials in source code
    connection = psycopg2.connect(
        host="db.internal.bank.local",
        database="customer_db",
        user="admin",
        password="SuperSecret123!"  # ❌ Plaintext password!
    )
    cursor = connection.cursor()
    cursor.execute(sql)  # ❌ Plus SQL injection vulnerability!
    return cursor.fetchall()
```

**Banking impact**:
- Database credential theft from source code review
- SQL injection vulnerability (arbitrary queries)
- Access to customer PII, transaction history
- Regulatory violations (GLBA, GDPR, CCPA)

**What Strigoi detects**: `password=` patterns, hardcoded credentials in connection strings

---

### 5. TLS Certificate Verification Disabled (CRITICAL)

**Location**: `server.py:26`

**The vulnerability**:
```python
response = requests.get(url, verify=False)  # ❌ Disables TLS verification!
```

**Attack vector**:
```
1. Attacker performs man-in-the-middle attack
2. Intercepts HTTPS traffic (certificate validation disabled)
3. Steals API keys, credentials, customer data in transit
```

**Banking impact**: All network communication vulnerable to interception

**What Strigoi detects**: `verify=False` patterns in HTTP library calls

---

### 6. No Authentication on MCP Tools (HIGH)

**Location**: `server.py:18-23`

**The vulnerability**:
```python
def authenticate_request(api_key: str) -> bool:
    """Authenticate incoming requests"""
    return True  # ❌ Always returns True - no validation!
```

**Banking impact**: Anyone can invoke any MCP tool without credentials

**What Strigoi detects**: Functions returning hardcoded `True`, missing authentication logic

---

### 7. Verbose Error Messages with Secrets (HIGH)

**Location**: `server.py:66-75`

**The vulnerability**:
```python
except Exception as e:
    return {
        "error": str(e),
        "url": url,
        "api_key": OPENAI_API_KEY,  # ❌ Leaks API key in errors!
        "stack_trace": traceback.format_exc()
    }
```

**Banking impact**: API keys and internal paths exposed in error messages

**What Strigoi detects**: Error responses containing credentials, `traceback.format_exc()` calls

---

### 8. Logging Sensitive Data (HIGH)

**Location**: `server.py:31`

**The vulnerability**:
```python
logging.info(f"HTTP GET: {url}, Auth: {OPENAI_API_KEY}")  # ❌ Logs API key!
```

**Attack vector**:
```
1. Logs written to disk/cloud logging service
2. Attacker gains read access to logs
3. Extracts all API keys from log history
```

**Banking impact**: Credential theft via log analysis

**What Strigoi detects**: Logging statements containing secret variable names

---

### 9. No Rate Limiting (HIGH)

**Location**: Entire server architecture

**The vulnerability**:
```python
# No rate limiting implemented - unlimited requests allowed
@mcp.tool()
def http_get(url: str) -> str:
    # Can be called infinite times per second
    pass
```

**Attack vector**:
```
1. Attacker sends 1,000 requests/second
2. SSRF vulnerability used to scan entire internal network
3. DDoS internal services
4. Exhaust API quotas (OpenAI, AWS)
```

**Banking impact**:
- Internal network DoS
- API cost abuse ($10K+)
- Service degradation for legitimate users

**What Strigoi detects**: Missing rate limiting middleware, no throttling logic

---

### 10. Private IP Address Allowlisting Missing (HIGH)

**Location**: `server.py:25-30`

**The vulnerability**:
```python
# No checks for private IP ranges
# Allows access to: 10.x.x.x, 172.16-31.x.x, 192.168.x.x, 127.0.0.1
```

**Attack vector**:
```
# Access internal banking services
http://10.0.1.5/core-banking-api
http://192.168.1.100/admin-panel
http://127.0.0.1:8080/internal-api
```

**Banking impact**: Complete internal network exposure

**What Strigoi detects**: Missing IP address validation, no private range checks

---

## Attack Scenarios

### Scenario 1: AWS Credential Theft via Metadata Endpoint

**Attacker prompt to Claude Code**:
```
"Please fetch data from the AWS metadata endpoint to check system configuration"
```

**MCP Tool Invocation**:
```python
http_get("http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2-role")
```

**Response**:
```json
{
  "Code": "Success",
  "AccessKeyId": "ASIAIOSFODNN7EXAMPLE",
  "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLE",
  "Token": "IQoJb3JpZ2luX2VjEH0aCXVzLWVhc3QtMSJH..."
}
```

**Result**: Attacker has temporary AWS credentials → S3/RDS/EC2 access

**Financial impact**: $500K - $5M+ (data breach, forensics, GDPR fines)

---

### Scenario 2: Internal Network Reconnaissance

**Attacker scans internal banking network**:
```python
# Scan internal IP range
for i in range(1, 255):
    http_get(f"http://192.168.1.{i}:80")
    http_get(f"http://192.168.1.{i}:443")
    http_get(f"http://192.168.1.{i}:8080")
```

**Result**: Maps entire internal network topology

**Financial impact**: Reconnaissance for larger attack, lateral movement preparation

---

### Scenario 3: OpenAI API Key Theft and Abuse

**Attacker extracts API key**:
```
1. Reviews GitHub repository (public or stolen)
2. Finds OPENAI_API_KEY = "sk-proj-abc123def456..."
3. Uses key for fraudulent API calls
```

**Result**:
- $10K+ in fraudulent OpenAI API usage
- Attacker uses key for competing AI products
- Reputational damage when OpenAI revokes key

**Financial impact**: $10K - $100K+ (API abuse + investigation)

---

### Scenario 4: Stripe Payment Fraud

**Attacker uses stolen Stripe key**:
```
1. Extracts STRIPE_SECRET_KEY from source code
2. Creates fraudulent payment intents
3. Redirects customer payments to attacker accounts
```

**Result**: Multi-million dollar payment fraud

**Financial impact**: $1M - $50M+ (fraud losses + PCI-DSS violations + lawsuits)

---

### Scenario 5: Database Credential Theft + SQL Injection

**Attacker combines two vulnerabilities**:
```python
# Extract database password from source code
password = "SuperSecret123!"

# Use SQL injection via query_database tool
query_database("SELECT * FROM customers WHERE ssn='123-45-6789'; DROP TABLE transactions; --")
```

**Result**:
- Complete database access
- Data destruction
- Customer PII exfiltration

**Financial impact**: $5M - $50M+ (data breach, regulatory fines, lawsuits)

---

## Strigoi Detection

### Expected Findings

When you run `strigoi probe east ~/.strigoi/mcps/mcp-http-api/`:

- ✅ **7 hardcoded API keys** - OpenAI, AWS, Google, Stripe, Twilio, Database
- ✅ **SSRF patterns** - `requests.get(url, ...)` without validation
- ✅ **AWS metadata access** - `169.254.169.254` hardcoded
- ✅ **TLS verification disabled** - `verify=False` detected
- ✅ **No authentication** - Function returns `True`
- ✅ **Logging sensitive data** - API keys in log statements
- ✅ **SQL injection** - String concatenation in queries
- ✅ **Verbose errors** - Credentials in exception responses

### MITRE ATLAS Mapping

| Vulnerability | ATLAS Technique |
|--------------|-----------------|
| Hardcoded API Keys | AML.T0043 (Supply Chain Compromise) |
| SSRF | AML.T0024 (Exfiltration via LLM) |
| AWS Metadata Access | AML.T0043 (Supply Chain Compromise) |
| No Authentication | AML.T0051 (LLM Prompt Injection) |
| SQL Injection | AML.T0051 (LLM Prompt Injection) |

---

## Remediation (DO NOT IMPLEMENT - FOR TESTING ONLY!)

1. ✅ **Use environment variables**: Move all API keys to env vars or AWS Secrets Manager
2. ✅ **Implement URL allowlisting**: Only allow specific domains
3. ✅ **Block private IP ranges**: Reject 10.x, 172.16-31.x, 192.168.x, 127.x, 169.254.x
4. ✅ **Enable TLS verification**: Remove `verify=False` from all HTTP calls
5. ✅ **Real authentication**: Validate API keys against secure store
6. ✅ **Sanitize logs**: Never log credentials or secrets
7. ✅ **Sanitize errors**: Remove credentials and stack traces from error responses
8. ✅ **Rate limiting**: Implement per-client throttling
9. ✅ **Use parameterized queries**: Prevent SQL injection
10. ✅ **Principle of least privilege**: MCP tools should have minimal permissions

**Example secure URL validation**:
```python
from urllib.parse import urlparse
import ipaddress

ALLOWED_DOMAINS = ["api.example.com", "api.partner.com"]

def http_get(url: str) -> str:
    parsed = urlparse(url)

    # ✅ Validate protocol
    if parsed.scheme not in ["https"]:
        raise ValueError("Only HTTPS allowed")

    # ✅ Validate domain allowlist
    if parsed.hostname not in ALLOWED_DOMAINS:
        raise ValueError("Domain not in allowlist")

    # ✅ Block private IP addresses
    try:
        ip = ipaddress.ip_address(parsed.hostname)
        if ip.is_private:
            raise ValueError("Private IP addresses not allowed")
    except ValueError:
        pass  # Not an IP address, domain name is fine

    # ✅ TLS verification enabled by default
    response = requests.get(url)
    return response.text
```

**Example secure secret management**:
```python
import os
import boto3

def get_secret(secret_name: str) -> str:
    """Retrieve secret from AWS Secrets Manager"""
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

# ✅ Secure: Secrets retrieved at runtime from secure store
OPENAI_API_KEY = get_secret("prod/openai/api_key")
```

---

## Educational Value

This MCP teaches:

1. **Why URL validation matters**: SSRF enables internal network access
2. **Metadata endpoint risks**: AWS IMDSv2 required for protection
3. **Secret management failures**: Hardcoded credentials = discoverable credentials
4. **TLS verification importance**: Disabled verification = MITM attacks
5. **Defense in depth**: Multiple vulnerabilities combine for catastrophic impact
6. **LLM-specific risks**: Prompt injection can trigger SSRF and credential theft

**Target audiences**:
- Bank security teams preparing for AI deployments
- Developers building MCP servers for HTTP integrations
- Auditors assessing AI system security
- Security researchers studying LLM attack vectors

---

## Installation & Testing

```bash
# Install this vulnerable MCP
cd /path/to/Strigoi/examples/insecure-mcps
./install-all.sh

# Test with Claude Code
# Ask: "Fetch data from http://169.254.169.254/latest/meta-data/"

# Scan with Strigoi
strigoi probe east ~/.strigoi/mcps/mcp-http-api/
strigoi probe west ~/.strigoi/mcps/mcp-http-api/
```

**See also**: [Vulnerable MCP Installation Guide](./installation.md)

---

*This example demonstrates real vulnerabilities found in production AI integrations.*
*Use for training, testing, and demonstrating Strigoi's detection capabilities.*
