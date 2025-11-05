# West: Authentication

**Scan authentication and authorization mechanisms - who can access what, and how is it verified?**

---

## What West Probing Detects

**WEST** direction focuses on **access control security** - how your AI systems verify identity and enforce permissions:

- 🔐 **Missing Authentication** - Endpoints accessible without credentials
- 🎫 **Weak Authentication** - Hardcoded passwords, weak tokens
- ⚖️ **Authorization Bypasses** - Privilege escalation vulnerabilities
- 🔑 **Session Management** - Insecure tokens, missing expiration
- 🚪 **Access Control** - Broken permission boundaries

**The gatekeeper question**: Who gets in, and can we trust that verification?

---

## Why West Probing Matters

### The Authentication Problem

**Banking scenario**: Regional bank deploys AI fraud detection API.

**Without West probing**:
- API accessible without any authentication
- Admin endpoints use hardcoded password `admin123`
- JWT tokens never expire (infinite session lifetime)
- No role-based access control (all users = admin)
- **Result**: Attacker accesses customer fraud alerts, steals transaction patterns

**With West probing**:
- Strigoi discovers missing authentication immediately
- Hardcoded admin password flagged as CRITICAL
- Infinite JWT lifetime identified
- Missing RBAC documented
- **Result**: All auth vulnerabilities fixed, secure access controls deployed

---

## How West Probing Works

### Command Syntax

```bash
# Scan authentication in current directory
strigoi probe west .

# Scan specific API project
strigoi probe west /path/to/api-project/

# Check MCP authentication
strigoi probe west ~/.strigoi/mcps/mcp-http-api/

# Output to JSON
strigoi probe west . --format json > west-findings.json
```

### What Strigoi Analyzes

**1. Authentication Mechanisms**:
- API key validation
- JWT token verification
- OAuth implementation
- Session management
- Password authentication

**2. Authorization Controls**:
- Role-Based Access Control (RBAC)
- Permission boundaries
- Privilege escalation checks
- Resource ownership validation

**3. Access Patterns**:
- Hardcoded credentials
- Weak password requirements
- Missing multi-factor authentication
- Insecure session storage

**4. Token Security**:
- JWT secret strength
- Token expiration
- Token rotation
- Revocation mechanisms

---

## Detection Patterns

### Pattern 1: No Authentication Required

**What Strigoi finds**:
```python
@app.route('/api/customers')
def list_customers():
    # ❌ CRITICAL: No authentication check!
    customers = Customer.query.all()
    return jsonify([c.to_dict() for c in customers])

@app.route('/api/transactions/<account_id>')
def get_transactions(account_id):
    # ❌ CRITICAL: Anyone can access any account
    transactions = Transaction.query.filter_by(account_id=account_id).all()
    return jsonify([t.to_dict() for t in transactions])

def authenticate_request(api_key):
    # ❌ CRITICAL: Always returns True!
    return True
```

**Banking impact**:
- Complete customer data exposure
- Transaction history accessible to anyone
- Regulatory violations (GLBA, GDPR)
- **Cost**: $5M - $50M+ (breach + fines)

**MITRE ATLAS**: AML.T0051 (LLM Prompt Injection)

**Remediation**:
```python
from functools import wraps
import jwt

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"error": "No token provided"}), 401

        try:
            decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            request.user = decoded
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401

        return f(*args, **kwargs)
    return decorated

@app.route('/api/customers')
@require_auth  # ✅ Authentication required
def list_customers():
    customers = Customer.query.all()
    return jsonify([c.to_dict() for c in customers])
```

---

### Pattern 2: Hardcoded Admin Credentials

**What Strigoi finds**:
```python
# config.py
ADMIN_USERNAME = "admin"           # ❌ CRITICAL
ADMIN_PASSWORD = "admin123"        # ❌ CRITICAL
ADMIN_API_KEY = "sk-admin-key"     # ❌ CRITICAL

@app.route('/admin/login', methods=['POST'])
def admin_login():
    username = request.json['username']
    password = request.json['password']

    # ❌ CRITICAL: Hardcoded credentials in source code
    if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        return jsonify({"token": generate_admin_token()})

    return jsonify({"error": "Invalid credentials"}), 401
```

**Attack vector**:
```
1. Attacker reviews source code (GitHub, stolen laptop)
2. Finds admin credentials
3. Logs in as admin
4. Full system access
```

**Banking impact**: Complete system compromise

**Remediation**:
```python
import os
import bcrypt

# ✅ Store hashed passwords in database
def create_admin_user():
    hashed = bcrypt.hashpw(os.environ['ADMIN_PASSWORD'].encode(), bcrypt.gensalt())
    admin = User(username='admin', password_hash=hashed, role='admin')
    db.session.add(admin)
    db.session.commit()

@app.route('/admin/login', methods=['POST'])
def admin_login():
    username = request.json['username']
    password = request.json['password']

    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401

    # ✅ Verify against hashed password
    if bcrypt.checkpw(password.encode(), user.password_hash):
        return jsonify({"token": generate_token(user)})

    return jsonify({"error": "Invalid credentials"}), 401
```

---

### Pattern 3: JWT Tokens Never Expire

**What Strigoi finds**:
```python
import jwt

def generate_token(user_id):
    # ❌ CRITICAL: No expiration!
    token = jwt.encode({"user_id": user_id}, SECRET_KEY, algorithm="HS256")
    return token

@app.route('/api/protected')
def protected_route():
    token = request.headers.get('Authorization')
    # ❌ HIGH: No expiration check
    decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    return jsonify({"user_id": decoded['user_id']})
```

**Attack vector**:
```
1. Attacker steals valid JWT token
2. Token remains valid forever
3. Attacker has permanent access
4. No way to revoke compromised token
```

**Banking impact**:
- Stolen tokens = permanent account access
- No logout mechanism
- Cannot revoke compromised sessions

**Remediation**:
```python
import jwt
from datetime import datetime, timedelta

def generate_token(user_id):
    # ✅ Set expiration (15 minutes)
    expiration = datetime.utcnow() + timedelta(minutes=15)

    token = jwt.encode({
        "user_id": user_id,
        "exp": expiration,
        "iat": datetime.utcnow()
    }, SECRET_KEY, algorithm="HS256")

    return token

@app.route('/api/protected')
def protected_route():
    token = request.headers.get('Authorization')

    try:
        # ✅ Automatically checks expiration
        decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return jsonify({"user_id": decoded['user_id']})
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 401
```

---

### Pattern 4: Missing Role-Based Access Control

**What Strigoi finds**:
```python
@app.route('/api/admin/users', methods=['DELETE'])
def delete_user():
    user_id = request.json['user_id']

    # ❌ CRITICAL: No role check!
    # Any authenticated user can delete any user
    User.query.filter_by(id=user_id).delete()
    db.session.commit()

    return jsonify({"message": "User deleted"})
```

**Attack vector**:
```
1. Regular user authenticates
2. Calls admin endpoint
3. Deletes other users (including admins)
4. Escalates privileges
```

**Banking impact**: Privilege escalation, data destruction

**Remediation**:
```python
from functools import wraps

def require_role(required_role):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            token = request.headers.get('Authorization')
            decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])

            user = User.query.get(decoded['user_id'])

            # ✅ Check user role
            if user.role != required_role:
                return jsonify({"error": "Insufficient permissions"}), 403

            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/api/admin/users', methods=['DELETE'])
@require_role('admin')  # ✅ Admin-only access
def delete_user():
    user_id = request.json['user_id']

    # Additional check: prevent self-deletion
    if user_id == request.user.id:
        return jsonify({"error": "Cannot delete yourself"}), 400

    User.query.filter_by(id=user_id).delete()
    db.session.commit()

    return jsonify({"message": "User deleted"})
```

---

## Real-World Examples

### Example 1: Banking API Without Authentication

**Scenario**: Community bank launches mobile banking API.

**West Probe Findings**:
```
🚨 CRITICAL FINDINGS (6)

[CRITICAL] No Authentication on /api/accounts
  File: api.py:45
  Risk: Anyone can list all customer accounts
  Impact: Complete data breach

[CRITICAL] No Authentication on /api/transfer
  File: api.py:78
  Risk: Unauthorized money transfers
  Impact: Multi-million dollar fraud

[CRITICAL] Hardcoded Admin Password
  File: config.py:12
  Pattern: ADMIN_PASSWORD = "BankAdmin2023!"
  Risk: Admin credential theft
  Impact: Full system compromise

[CRITICAL] JWT Tokens Never Expire
  File: auth.py:34
  Risk: Stolen tokens valid forever
  Impact: Permanent unauthorized access

[HIGH] Missing Rate Limiting on Login
  File: auth.py:45
  Risk: Brute force password attacks
  Impact: Account takeover

[HIGH] No Multi-Factor Authentication
  File: auth.py:50
  Risk: Weak single-factor auth
  Impact: Regulatory compliance violation
```

**Remediation time**: 16 hours
**Cost to fix**: $8K (developer time)
**Cost if exploited**: $50M+ (fraud + breach + fines)

---

### Example 2: AI Admin Panel Bypass

**Scenario**: Fintech startup's AI model management panel.

**West Probe Findings**:
```
🚨 CRITICAL FINDINGS (3)

[CRITICAL] Admin Endpoints Accessible Without Auth
  Files: admin.py (multiple routes)
  Risk: Anyone can manage AI models
  Impact: Model poisoning, data manipulation

[CRITICAL] Authorization Check Always Returns True
  File: middleware.py:15
  Pattern: def check_admin(): return True
  Risk: Auth bypass for all admin functions
  Impact: Complete access control failure

[HIGH] Session IDs in URL Parameters
  File: auth.py:56
  Pattern: /admin?session_id=abc123
  Risk: Session hijacking via URL sharing
  Impact: Account takeover
```

**Actual incident**:
- Researcher discovered unprotected admin panel
- Could modify AI models (inject bias)
- Could delete training data
- Could exfiltrate customer datasets
- **Total cost**: $100K (emergency audit + remediation)

---

## Banking-Specific Risks

### Risk 1: Core Banking API Authentication

**Vulnerability**: SWIFT/ACH transfer APIs with weak authentication.

**Detection**:
```bash
strigoi probe west /path/to/core-banking-api/
```

**Common findings**:
- Basic Auth with weak passwords
- API keys transmitted in URL
- No certificate-based authentication
- Missing transaction signing

**Regulatory impact**: Fed/OCC examination findings

---

### Risk 2: Mobile Banking Authentication

**Vulnerability**: Mobile app authentication bypass.

**West probe findings**:
- No device binding
- Biometric auth not enforced
- Session tokens stored insecurely
- No step-up authentication for high-value transactions

**Financial impact**: $500K - $5M+ per breach

---

## Command Options

### Basic Commands

```bash
# Scan current directory
strigoi probe west .

# Scan specific path
strigoi probe west /path/to/project

# Scan API authentication
strigoi probe west /path/to/api/
```

### Advanced Options

```bash
# Check specific authentication patterns
strigoi probe west . --check-auth api_key,jwt,oauth

# Filter by severity
strigoi probe west . --severity CRITICAL,HIGH

# Output formats
strigoi probe west . --format json
strigoi probe west . --format sarif
strigoi probe west . --format csv
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Strigoi West Authentication Scan

on: [push, pull_request]

jobs:
  auth-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run West Probe
        run: |
          strigoi probe west . --format sarif > west-results.sarif

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: west-results.sarif

      - name: Block on Auth Issues
        run: |
          strigoi probe west . --severity CRITICAL --format json > auth.json
          if [ $(jq '.findings | length' auth.json) -gt 0 ]; then
            echo "❌ CRITICAL authentication issues found!"
            jq '.findings[] | "\(.file):\(.line) - \(.description)"' auth.json
            exit 1
          fi
```

---

## Interpreting Results

### Severity Levels

**CRITICAL** - Fix immediately:
- No authentication on sensitive endpoints
- Hardcoded admin credentials
- Authentication bypass vulnerabilities
- JWT tokens without expiration

**HIGH** - Fix before deployment:
- Weak password requirements
- Missing rate limiting on login
- Insecure session management
- No role-based access control

**MEDIUM** - Address in next sprint:
- Missing multi-factor authentication
- Session tokens in URLs
- Weak JWT secrets

**LOW** - Monitor and document:
- Long session timeouts
- Informational security headers missing

---

## Best Practices

### Authentication Security Checklist

✅ Require authentication on all sensitive endpoints
✅ Never hardcode credentials (use secret management)
✅ Implement JWT expiration (15-60 minutes)
✅ Use role-based access control (RBAC)
✅ Require strong passwords (12+ characters, complexity)
✅ Implement rate limiting on login (5 attempts/15 minutes)
✅ Use HTTPS for all authentication requests
✅ Store passwords with bcrypt/argon2 (never plaintext)
✅ Implement multi-factor authentication (MFA)
✅ Log all authentication events

### Token Management Best Practices

```python
# ✅ Secure JWT implementation
import jwt
from datetime import datetime, timedelta
import secrets

# Strong secret (256 bits)
JWT_SECRET = os.environ.get('JWT_SECRET')  # Never hardcode!

def generate_secure_token(user_id, role):
    """Generate secure JWT with all best practices"""
    return jwt.encode({
        "user_id": user_id,
        "role": role,
        "exp": datetime.utcnow() + timedelta(minutes=15),  # Short expiration
        "iat": datetime.utcnow(),
        "jti": secrets.token_urlsafe(32)  # Unique token ID for revocation
    }, JWT_SECRET, algorithm="HS256")

def refresh_token(old_token):
    """Implement token refresh for better UX"""
    try:
        decoded = jwt.decode(old_token, JWT_SECRET, algorithms=["HS256"])

        # Check if token is close to expiration (last 5 minutes)
        exp = datetime.fromtimestamp(decoded['exp'])
        if datetime.utcnow() < exp - timedelta(minutes=5):
            return None  # Token still valid for a while

        # Generate new token
        return generate_secure_token(decoded['user_id'], decoded['role'])

    except jwt.ExpiredSignatureError:
        return None  # Token already expired, require re-auth
```

---

## Complementary Directions

**After West probing, scan**:

- **NORTH** - Verify authentication protects external APIs
- **SOUTH** - Check authentication libraries are up-to-date
- **EAST** - Confirm credentials aren't leaked in data flows
- **ALL** - Comprehensive security assessment

---

## Penetration Testing Integration

### Manual Auth Testing Checklist

```bash
# Test 1: Authentication bypass
curl -X GET http://localhost:5000/api/admin/users
# Expected: 401 Unauthorized

# Test 2: Expired token
curl -X GET http://localhost:5000/api/protected \
  -H "Authorization: Bearer <expired-token>"
# Expected: 401 Token expired

# Test 3: Invalid role access
curl -X DELETE http://localhost:5000/api/admin/users \
  -H "Authorization: Bearer <user-token>"
# Expected: 403 Insufficient permissions

# Test 4: SQL injection in auth
curl -X POST http://localhost:5000/login \
  -d '{"username": "admin" OR 1=1--", "password": "anything"}'
# Expected: 401 Invalid credentials (not successful login!)
```

---

## Next Steps

**Ready to scan?**
→ [Installation Guide](../../getting-started/installation/README.md)

**Learn other directions**:
→ [North: External Interfaces](./north.md)
→ [South: Dependencies](./south.md)
→ [East: Data Flows](./east.md)
→ [All: Comprehensive Scan](./all.md)

**Need help?**
→ [Troubleshooting Guide](../../operations/maintenance/troubleshooting.md)
→ [FAQ](../../reference/faq.md)

---

*West probing: Guard the gates, verify every entry.*
