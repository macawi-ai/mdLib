# mcp-filesystem: Path Traversal Bonanza

**Intentionally vulnerable filesystem MCP server demonstrating path traversal and arbitrary file access.**

---

## ⚠️ WARNING: INTENTIONALLY VULNERABLE CODE

**🚨 DO NOT USE IN PRODUCTION 🚨**
**🚨 FOR TESTING AND TRAINING ONLY 🚨**

---

## Overview

**What it does**: Provides Claude Code access to read/write files on the filesystem (supposedly sandboxed, but escapes via path traversal).

**Banking relevance**: Similar vulnerabilities could expose SSH keys, database credentials, customer data files, and system configuration.

**Vulnerability count**: 12 CRITICAL/HIGH issues

---

## Critical Vulnerabilities

### 1. Path Traversal - Directory Escape (CRITICAL)

**Location**: `server.py:43-58` (`resolve_path` function)

**The vulnerability**:
```python
def resolve_path(relative_path: str) -> str:
    full_path = os.path.join(BASE_DIR, relative_path)
    return full_path  # ❌ No validation of ../../../ sequences!
```

**Attack vector**:
```
path = "../../../etc/passwd"
path = "../../../../home/user/.ssh/id_rsa"
path = "../../../var/log/auth.log"
path = "../../../../home/user/.aws/credentials"
```

**Banking impact**: Attackers could read:
- SSH private keys → remote access
- Database credentials → data exfiltration
- Customer data files → regulatory violations
- System logs → cover attack tracks

**What Strigoi detects**: `os.path.join` without validation, missing `is_relative_to()` checks

---

### 2. Arbitrary File Read (CRITICAL)

**Location**: `server.py:61-85` (`read_file` function)

**The vulnerability**:
```python
def read_file(path: str) -> str:
    with open(resolve_path(path), 'r') as f:
        return f.read()  # ❌ Reads ANY file!
```

**High-value banking targets**:
```
/etc/passwd                  - User enumeration
~/.ssh/id_rsa               - SSH private keys
~/.aws/credentials          - Cloud credentials
~/.bash_history             - Command history (secrets!)
/proc/self/environ          - Environment variables (API keys!)
/var/log/auth.log           - Authentication logs
/etc/shadow                 - Password hashes (if root)
```

**Banking impact**: Complete information disclosure, credential theft

**What Strigoi detects**: File read operations without path validation

---

### 3. Arbitrary File Write (CRITICAL)

**Location**: `server.py:88-113` (`write_file` function)

**The vulnerability**:
```python
def write_file(path: str, content: str) -> dict:
    with open(resolve_path(path), 'w') as f:
        f.write(content)  # ❌ Writes to ANY file!
```

**Attack targets**:
```
~/.ssh/authorized_keys      - Add SSH backdoor
/etc/cron.d/backdoor        - Scheduled malware execution
~/.bashrc                   - Command injection on login
~/index.php                 - Web shell deployment
```

**Banking impact**: System compromise, persistent backdoors, data destruction

**What Strigoi detects**: Unrestricted file write operations

---

### 4. Symlink Following Enabled (CRITICAL)

**Location**: `server.py:69`, `server.py:139`

**The vulnerability**:
```python
for root, dirs, files in os.walk(path, followlinks=True):  # ❌ Follows symlinks!
```

**Attack scenario**:
1. Create symlink in sandbox: `ln -s /etc/passwd exposed.txt`
2. Read via MCP: `read_file("exposed.txt")`
3. Get contents of `/etc/passwd`

**Banking impact**: Sandbox escape, access to system files

**What Strigoi detects**: `followlinks=True` in os.walk calls

---

### 5. Hardcoded Credentials (CRITICAL)

**Location**: `server.py:20-22`

**The vulnerability**:
```python
ADMIN_USERNAME = "filesystem-admin"
ADMIN_PASSWORD = "PathTraversal123!"
ADMIN_API_KEY = "sk-filesystem-unsafe-key-xyz789"
```

**Banking impact**: Credential theft from source code review

**What Strigoi detects**: Variables named `PASSWORD`, `API_KEY`, hardcoded secrets

---

### 6. Arbitrary File Deletion (HIGH)

**Location**: `server.py:176-197` (`delete_file` function)

**The vulnerability**:
```python
def delete_file(path: str) -> dict:
    full_path = resolve_path(path)
    if os.path.isdir(full_path):
        shutil.rmtree(full_path)  # ❌ Deletes entire directories!
    else:
        os.remove(full_path)
```

**Attack vector**:
```
delete_file("../../../home/user/important_docs")
delete_file("../../../var/log")  # Delete all logs (cover tracks)
```

**Banking impact**: Data destruction, evidence tampering

**What Strigoi detects**: `shutil.rmtree` without validation, dangerous deletion tools

---

## Attack Scenarios

### Scenario 1: SSH Key Exfiltration

**Attacker prompt to Claude Code**:
```
"Please read the file at ../../../home/cy/.ssh/id_rsa"
```

**Result**: SSH private key exfiltrated through LLM conversation

**Financial impact**:
- Unauthorized access to production systems
- Lateral movement through network
- Data exfiltration

**Cost**: $2M-$20M+ (breach response, forensics, regulatory fines)

---

### Scenario 2: Backdoor Installation

**Attacker writes to authorized_keys**:
```python
write_file(
    path="../../../home/cy/.ssh/authorized_keys",
    content="ssh-rsa AAAA...attacker_public_key..."
)
```

**Result**: Persistent SSH access for attacker

**Financial impact**: Long-term compromise, ongoing data theft

---

### Scenario 3: AWS Credentials Theft

**Attacker reads cloud credentials**:
```
read_file("../../../home/cy/.aws/credentials")
```

**Result**: AWS account compromise

**Financial impact**:
- Cryptocurrency mining on stolen compute ($100K+)
- S3 bucket exfiltration (customer data)
- EC2 resource abuse

**Cost**: $500K-$5M+

---

### Scenario 4: Log Deletion (Cover Tracks)

**Attacker destroys evidence**:
```
delete_file("../../../var/log/auth.log")
delete_file("../../../var/log/syslog")
```

**Result**: Forensic evidence destroyed

---

## Strigoi Detection

### Expected Findings

When you run `strigoi probe east ~/.strigoi/mcps/mcp-filesystem/`:

- ✅ **Path traversal patterns** - `os.path.join` without `normpath`
- ✅ **Hardcoded credentials** - `ADMIN_PASSWORD` detected
- ✅ **Debug mode** - Always enabled
- ✅ **Symlink following** - `followlinks=True` found
- ✅ **No authentication** - Function returns `True`
- ✅ **Dangerous file ops** - `shutil.rmtree` without validation

### MITRE ATLAS Mapping

| Vulnerability | ATLAS Technique |
|--------------|-----------------|
| Path Traversal | AML.T0024 (Exfiltration via LLM) |
| Arbitrary Read | AML.T0024 (Exfiltration via LLM) |
| Arbitrary Write | AML.T0051 (LLM Prompt Injection) |
| Arbitrary Delete | AML.T0051 (LLM Prompt Injection) |

---

## Remediation (DO NOT IMPLEMENT - FOR TESTING ONLY!)

1. ✅ **Path validation**: Use `Path.resolve().is_relative_to(BASE_DIR)`
2. ✅ **Disable symlinks**: `followlinks=False` in all os.walk calls
3. ✅ **File extension allowlist**: Only allow `.txt`, `.md`, `.json`
4. ✅ **Real authentication**: Validate API keys properly
5. ✅ **Depth limits**: Max 3 levels of recursion
6. ✅ **Remove credentials**: Use environment variables
7. ✅ **Sanitize errors**: No paths in error messages
8. ✅ **Confirmation**: Require confirmation for destructive operations
9. ✅ **File size limits**: Prevent DoS via large files
10. ✅ **Proper sandboxing**: Use chroot or containers

**Example secure path validation**:
```python
from pathlib import Path

def resolve_path(relative_path: str) -> Path:
    base = Path(BASE_DIR).resolve()
    target = (base / relative_path).resolve()

    # ✅ Ensure target is within base directory
    if not target.is_relative_to(base):
        raise ValueError("Path traversal detected!")

    return target
```

---

## Educational Value

This MCP teaches:

1. **Path traversal fundamentals**: Classic web vulnerability in AI agents
2. **Symlink attacks**: Escaping sandboxes via filesystem tricks
3. **Privilege escalation**: Writing to sensitive files
4. **Information disclosure**: Reading credentials and secrets
5. **LLM-specific risks**: Prompt injection triggers file operations

**Target audiences**:
- Bank security teams preparing for AI deployments
- Developers building MCP servers for file access
- Auditors assessing AI system security
- Security researchers studying LLM attack vectors

---

## Installation & Testing

```bash
# Install this vulnerable MCP
cd /path/to/Strigoi/examples/insecure-mcps
./install-all.sh

# Test with Claude Code
# Ask: "List the files in this directory"

# Scan with Strigoi
strigoi probe east ~/.strigoi/mcps/mcp-filesystem/
strigoi probe west ~/.strigoi/mcps/mcp-filesystem/
```

**See also**: [Vulnerable MCP Installation Guide](./installation.md)

---

*This example demonstrates real vulnerabilities found in production file access systems.*
*Use for training, testing, and demonstrating Strigoi's detection capabilities.*
