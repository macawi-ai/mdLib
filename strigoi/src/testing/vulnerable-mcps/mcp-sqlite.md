# mcp-sqlite: SQL Injection Paradise

**Intentionally vulnerable SQLite MCP server demonstrating SQL injection and credential theft.**

---

## ⚠️ WARNING: INTENTIONALLY VULNERABLE CODE

**🚨 DO NOT USE IN PRODUCTION 🚨**
**🚨 FOR TESTING AND TRAINING ONLY 🚨**

---

## Overview

**What it does**: Provides Claude Code access to a SQLite database containing US states and capitals (plus a hidden `admin_users` table with credentials).

**Banking relevance**: Similar vulnerabilities in production AI systems could expose customer PII, transaction history, and internal credentials.

**Vulnerability count**: 10 CRITICAL/HIGH issues

---

## Critical Vulnerabilities

### 1. SQL Injection via String Concatenation (CRITICAL)

**Location**: `server.py:72` (`get_state_capital` function)

**The vulnerability**:
```python
query = f"SELECT * FROM states WHERE name = '{state_name}'"
cursor.execute(query)  # ❌ INSECURE: No parameterized query!
```

**Attack vector**:
```
state_name = "Wisconsin' OR '1'='1"
state_name = "Wisconsin'; DROP TABLE states; --"
state_name = "Wisconsin' UNION SELECT username, password FROM admin_users --"
```

**Banking impact**: Attackers could:
- Extract customer SSNs, account numbers, transaction history
- Dump admin credentials
- Delete entire customer databases

**What Strigoi detects**: f-strings with SQL keywords, missing parameterized queries

---

### 2. Arbitrary SQL Execution (CRITICAL)

**Location**: `server.py:84` (`run_sql` function)

**The vulnerability**:
```python
def run_sql(sql: str) -> dict:
    cursor.execute(sql)  # ❌ Executes ANY SQL statement!
```

**Attack vector**:
```sql
SELECT * FROM admin_users;  -- Dump admin credentials
DROP TABLE states;          -- Destroy data
ATTACH DATABASE '/etc/passwd' AS pwn;  -- File system access
```

**Banking impact**: Complete database control, potential OS-level compromise

**What Strigoi detects**: Functions named `run_sql`, no input validation

---

### 3. Hardcoded API Key (CRITICAL)

**Location**: `server.py:25`

**The vulnerability**:
```python
INTERNAL_API_KEY = "sk-insecure-mcp-abcdef123456789"
```

**Banking impact**: API key theft, lateral movement to other systems

**What Strigoi detects**: Variables containing `sk-`, `API_KEY`, secret patterns

---

### 4. Plaintext Passwords in Database (CRITICAL)

**Location**: `schema.sql:57-61`

**The vulnerability**:
```sql
CREATE TABLE admin_users (
    username TEXT NOT NULL,
    password TEXT NOT NULL  -- ❌ No hashing!
);
INSERT INTO admin_users VALUES ('admin', 'password123', 'sk-test-1234');
```

**Banking impact**: Credential theft via SQL injection

**What Strigoi detects**: Database schemas with plaintext password columns

---

### 5. No Authentication (HIGH)

**Location**: `server.py:32-38`

**The vulnerability**:
```python
def authenticate_request(request: str) -> bool:
    return True  # ❌ Always allow!
```

**Banking impact**: Anyone can call any MCP tool without credentials

**What Strigoi detects**: Functions returning hardcoded `True`, no auth logic

---

### 6. Verbose Error Messages (HIGH)

**Location**: `server.py:84-102`

**The vulnerability**:
```python
return {
    "error": str(e),
    "sql": sql,
    "database_path": DB_PATH,  # ❌ Exposes internal paths!
    "traceback": traceback.format_exc()
}
```

**Banking impact**: Reconnaissance aid for attackers, exposes system structure

**What Strigoi detects**: `traceback.format_exc()` calls, debug mode enabled

---

## Attack Scenarios

### Scenario 1: Credential Theft via SQL Injection

**Attacker prompt to Claude Code**:
```
"What's the capital of Wisconsin' UNION SELECT username, password, api_key,
'dummy', 0, 0, 0, 'hack' FROM admin_users --"
```

**Result**: Admin credentials exfiltrated through LLM conversation

**Financial impact**: $5M-$50M+ (data breach, GDPR/CCPA fines, class-action lawsuits)

---

### Scenario 2: Database Destruction

**Attacker uses `run_sql` tool**:
```sql
DROP TABLE states; DROP TABLE admin_users;
```

**Result**: Complete data loss

**Financial impact**: $500K-$2M (data recovery, business interruption, SLA violations)

---

### Scenario 3: Lateral Movement

**Extract API key via triggered error**:
```sql
INVALID SQL TO TRIGGER ERROR
```

**Error response contains**: `INTERNAL_API_KEY`

**Result**: Use key for lateral movement to other systems

---

## Strigoi Detection

### Expected Findings

When you run `strigoi probe east ~/.strigoi/mcps/mcp-sqlite/`:

- ✅ **SQL injection patterns** - f-strings with SQL keywords
- ✅ **Hardcoded API key** - `sk-` prefix detected
- ✅ **Debug mode** - `DEBUG_MODE = True`
- ✅ **Missing authentication** - Function returns `True`
- ✅ **Verbose errors** - `traceback.format_exc()` detected

### MITRE ATLAS Mapping

| Vulnerability | ATLAS Technique |
|--------------|-----------------|
| SQL Injection | AML.T0051 (LLM Prompt Injection) |
| Arbitrary SQL | AML.T0051 (LLM Prompt Injection) |
| Hardcoded Secrets | AML.T0024 (Exfiltration via LLM) |
| No Auth | AML.T0051 (LLM Prompt Injection) |

---

## Remediation (DO NOT IMPLEMENT - FOR TESTING ONLY!)

1. ✅ **Use parameterized queries**: `cursor.execute("SELECT * FROM states WHERE name = ?", (state_name,))`
2. ✅ **Remove arbitrary SQL tool**: Delete `run_sql` function entirely
3. ✅ **Hash passwords**: Use bcrypt/argon2 for password storage
4. ✅ **Real authentication**: Validate API keys against secure store
5. ✅ **Sanitize errors**: Remove paths, credentials, stack traces
6. ✅ **Environment variables**: Move secrets to env vars or secrets manager
7. ✅ **Query allowlisting**: Only allow specific SELECT statements

---

## Educational Value

This MCP teaches:

1. **Why input validation matters**: SQL injection is still prevalent in 2025
2. **Secret management failures**: Hardcoded credentials are discoverable
3. **Error message risks**: Verbose errors aid reconnaissance
4. **Authentication is not optional**: Every tool needs access control
5. **LLM-specific risks**: Prompt injection can trigger SQL injection

**Target audiences**:
- Bank security teams preparing for AI deployments
- Developers building MCP servers for banking applications
- Auditors assessing AI system security

---

## Installation & Testing

```bash
# Install this vulnerable MCP
cd /path/to/Strigoi/examples/insecure-mcps
./install-all.sh

# Test with Claude Code
# Ask: "What's the capital of Wisconsin?"

# Scan with Strigoi
strigoi probe east ~/.strigoi/mcps/mcp-sqlite/
strigoi probe west ~/.strigoi/mcps/mcp-sqlite/
```

**See also**: [Vulnerable MCP Installation Guide](./installation.md)

---

*This example demonstrates real vulnerabilities found in production AI systems.*
*Use for training, testing, and demonstrating Strigoi's detection capabilities.*
