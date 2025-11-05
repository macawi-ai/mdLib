# North: External Interfaces

**Scan external attack surfaces visible to adversaries - APIs, endpoints, and public-facing services.**

---

## What North Probing Detects

**NORTH** direction focuses on **external attack surfaces** - everything an attacker sees from outside your organization:

- 🌐 **API Endpoints** - REST, GraphQL, gRPC interfaces
- 🔌 **Exposed Services** - Web servers, databases, message queues
- 🔗 **Third-Party Integrations** - External APIs, webhooks, callbacks
- 📡 **Network Interfaces** - Public IPs, ports, protocols
- 🔍 **Information Disclosure** - Error messages, version info, metadata

**The attacker's perspective**: What can I reach from the internet?

---

## Why North Probing Matters

### The External Attack Surface Problem

**Banking scenario**: Community bank deploys AI-powered loan application chatbot.

**Without North probing**:
- GraphQL endpoint exposed without rate limiting
- API documentation publicly accessible (information disclosure)
- Verbose error messages reveal internal architecture
- WebSocket connections lack authentication
- **Result**: Attacker maps entire API surface, plans targeted attack

**With North probing**:
- Strigoi discovers exposed endpoints immediately
- Rate limiting gaps identified pre-deployment
- Error message verbosity flagged as CRITICAL
- Authentication weaknesses documented
- **Result**: Vulnerabilities fixed before launch, no external attack surface

---

## How North Probing Works

### Command Syntax

```bash
# Scan external interfaces in current directory
strigoi probe north .

# Scan specific MCP server
strigoi probe north ~/.strigoi/mcps/mcp-http-api/

# Scan with specific severity filter
strigoi probe north /path/to/project --severity CRITICAL,HIGH

# Output to JSON for CI/CD integration
strigoi probe north . --format json > north-findings.json
```

### What Strigoi Analyzes

**1. API Endpoint Discovery**:
- REST routes and methods
- GraphQL schemas and resolvers
- gRPC service definitions
- WebSocket endpoints

**2. Access Control Analysis**:
- Authentication requirements
- Authorization checks
- API key validation
- Rate limiting presence

**3. Information Disclosure**:
- Error message verbosity
- Stack traces in responses
- Version information leakage
- Debug endpoints exposed

**4. Network Security**:
- TLS/SSL configuration
- Protocol versions
- Certificate validation
- Insecure redirects

---

## Detection Patterns

### Pattern 1: Exposed GraphQL Introspection

**What Strigoi finds**:
```python
# GraphQL introspection enabled in production
schema = buildSchema("""
  type Query {
    users: [User]
    transactions: [Transaction]
  }
""")

# ❌ No authentication on GraphQL endpoint
app.add_url_rule('/graphql', view_func=GraphQLView.as_view('graphql', schema=schema))
```

**Why this matters**:
- Attackers can map entire API schema
- Discover hidden fields and relationships
- Plan targeted attacks based on data model

**MITRE ATLAS**: AML.T0024 (Exfiltration via LLM)

**Remediation**:
```python
# ✅ Disable introspection in production
schema = buildSchema(..., introspection=False)

# ✅ Require authentication
@auth_required
def graphql():
    return GraphQLView.as_view('graphql', schema=schema)
```

---

### Pattern 2: Verbose Error Messages

**What Strigoi finds**:
```python
@app.errorhandler(Exception)
def handle_error(e):
    return {
        "error": str(e),
        "traceback": traceback.format_exc(),  # ❌ Exposes internal paths
        "database_host": DB_HOST,              # ❌ Reveals infrastructure
        "api_key": INTERNAL_KEY                # ❌ Leaks credentials
    }, 500
```

**Banking impact**:
- Reveals internal architecture (reconnaissance for attackers)
- Exposes database hosts (targets for SQL injection)
- Leaks API keys (credential theft)

**Remediation**:
```python
@app.errorhandler(Exception)
def handle_error(e):
    # ✅ Log detailed error internally
    logging.error(f"Error: {e}", exc_info=True)

    # ✅ Return generic message to client
    return {"error": "Internal server error"}, 500
```

---

### Pattern 3: Missing Rate Limiting

**What Strigoi finds**:
```python
@app.route('/api/transfer', methods=['POST'])
def transfer_funds():
    # ❌ No rate limiting - unlimited requests allowed
    amount = request.json['amount']
    transfer(amount)
```

**Attack vector**:
```
1. Attacker sends 10,000 requests/second
2. Bypasses manual fraud detection
3. Transfers funds before system responds
```

**MITRE ATLAS**: AML.T0015 (Model Inversion)

**Remediation**:
```python
from flask_limiter import Limiter

limiter = Limiter(app, key_func=get_remote_address)

@app.route('/api/transfer', methods=['POST'])
@limiter.limit("10 per minute")  # ✅ Rate limited
def transfer_funds():
    amount = request.json['amount']
    transfer(amount)
```

---

### Pattern 4: Exposed Internal Endpoints

**What Strigoi finds**:
```python
# ❌ Internal admin API accessible from internet
@app.route('/internal/admin/users')
def list_all_users():
    return User.query.all()

# ❌ Debug endpoint in production
@app.route('/debug/config')
def show_config():
    return jsonify(app.config)
```

**Banking impact**:
- Customer PII exposure
- Configuration secrets leaked
- Admin functions accessible to attackers

**Remediation**:
```python
# ✅ Restrict to internal network only
@app.route('/internal/admin/users')
@require_internal_network
@require_admin_auth
def list_all_users():
    return User.query.all()

# ✅ Remove debug endpoints in production
if not app.config['DEBUG']:
    app.config['PROPAGATE_EXCEPTIONS'] = False
```

---

## Real-World Examples

### Example 1: Banking Chatbot API Exposure

**Scenario**: Regional bank launches AI customer service chatbot.

**North Probe Findings**:
```
🚨 CRITICAL FINDINGS (4)

[CRITICAL] GraphQL Introspection Enabled
  Endpoint: /api/graphql
  Risk: Full API schema disclosure
  Impact: Attacker maps all queries/mutations

[CRITICAL] No Authentication on WebSocket
  Endpoint: /ws/chat
  Risk: Unauthorized access to chat history
  Impact: Customer conversation exfiltration

[HIGH] Verbose Error Messages
  All endpoints return stack traces
  Risk: Internal path disclosure
  Impact: Reconnaissance aid for attackers

[HIGH] Missing CORS Configuration
  All origins allowed: Access-Control-Allow-Origin: *
  Risk: Cross-origin attacks
  Impact: XSS and CSRF vulnerabilities
```

**Remediation time**: 4 hours
**Cost to fix**: $2K (developer time)
**Cost if exploited**: $5M+ (data breach, regulatory fines)

---

### Example 2: Payment API Rate Limiting Gap

**Scenario**: Fintech startup deploys payment processing API.

**North Probe Findings**:
```
🚨 CRITICAL FINDINGS (2)

[CRITICAL] No Rate Limiting on /api/pay
  Unlimited requests allowed
  Risk: Payment fraud via brute force
  Impact: Multi-million dollar losses

[HIGH] API Key in URL Parameters
  /api/pay?key=sk-123456
  Risk: Keys logged in web server logs
  Impact: Credential theft via log analysis
```

**Actual incident prevented**:
- Discovered pre-launch
- Rate limiting implemented (100 requests/hour)
- API key moved to Authorization header
- **Saved**: $10M+ potential fraud losses

---

## Banking-Specific Risks

### Risk 1: Core Banking API Exposure

**Vulnerability**: Internal core banking APIs accessible from internet

**Detection**:
```bash
strigoi probe north /path/to/core-banking-api
```

**Common findings**:
- SWIFT message endpoints without authentication
- ACH transfer APIs with weak rate limiting
- Customer lookup APIs leaking PII
- Transaction history endpoints without encryption

**Regulatory impact**: OCC, FDIC, Fed examination findings

---

### Risk 2: Mobile Banking API Security

**Vulnerability**: Mobile app APIs vulnerable to replay attacks

**Detection**: North probe finds:
- Missing request signing
- No timestamp validation
- Weak session management
- Certificate pinning disabled

**Financial impact**: $500K - $5M+ per breach

---

## Command Options

### Basic Commands

```bash
# Scan current directory
strigoi probe north .

# Scan specific path
strigoi probe north /path/to/project

# Scan MCP server
strigoi probe north ~/.strigoi/mcps/mcp-http-api/
```

### Advanced Options

```bash
# Filter by severity
strigoi probe north . --severity CRITICAL

# Output formats
strigoi probe north . --format json
strigoi probe north . --format sarif  # For GitHub Security
strigoi probe north . --format csv

# Combine with other directions
strigoi probe all .  # North + South + East + West
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Strigoi North Security Scan

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run North Probe
        run: |
          strigoi probe north . --format sarif > north-results.sarif

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: north-results.sarif

      - name: Fail on Critical Findings
        run: |
          strigoi probe north . --severity CRITICAL --format json > findings.json
          if [ $(jq '.findings | length' findings.json) -gt 0 ]; then
            echo "❌ CRITICAL vulnerabilities found"
            exit 1
          fi
```

---

## Interpreting Results

### Severity Levels

**CRITICAL** - Immediate remediation required:
- Exposed admin endpoints
- No authentication on sensitive APIs
- Hardcoded credentials in public-facing code
- GraphQL introspection enabled in production

**HIGH** - Fix before deployment:
- Verbose error messages
- Missing rate limiting
- Weak CORS configuration
- Information disclosure via headers

**MEDIUM** - Address in next sprint:
- Outdated TLS versions
- Insecure redirects
- Version information leakage

**LOW** - Monitor and document:
- Informational headers
- Non-critical metadata exposure

---

## Best Practices

### Pre-Deployment Checklist

✅ Run North probe before every production deployment
✅ Fail CI/CD pipeline on CRITICAL findings
✅ Document accepted risks (MEDIUM/LOW)
✅ Verify rate limiting on all external endpoints
✅ Disable debug endpoints in production
✅ Sanitize all error messages
✅ Implement API authentication everywhere
✅ Use TLS 1.3+ for all external communication

---

## Complementary Directions

**After North probing, scan**:

- **SOUTH** - Check if exposed APIs depend on vulnerable libraries
- **EAST** - Verify data flows through external endpoints are secure
- **WEST** - Confirm authentication mechanisms are properly implemented
- **ALL** - Comprehensive security assessment

---

## Next Steps

**Ready to scan?**
→ [Installation Guide](../../getting-started/installation/README.md)

**Learn other directions**:
→ [South: Dependencies](./south.md)
→ [East: Data Flows](./east.md)
→ [West: Authentication](./west.md)
→ [All: Comprehensive Scan](./all.md)

**Need help?**
→ [Troubleshooting Guide](../../operations/maintenance/troubleshooting.md)
→ [FAQ](../../reference/faq.md)

---

*North probing: See your attack surface before attackers do.*
