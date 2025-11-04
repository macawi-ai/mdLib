# Strigoi Documentation

[Introduction](./introduction.md)

---

# Getting Started

- [What is Strigoi?](./getting-started/what-is-strigoi.md)
- [Use Cases](./getting-started/use-cases.md)
- [Installation](./getting-started/installation/README.md)
  - [AMD64 Installation](./getting-started/installation/amd64.md)
  - [ARM64 Installation](./getting-started/installation/arm64.md)
  - [Pre-compiled Binaries](./getting-started/installation/binaries.md)
  - [Building from Source](./getting-started/installation/source.md)
- [Quick Start Guide](./getting-started/quick-start.md)
- [First Security Scan](./getting-started/first-scan.md)

---

# User Guide

- [CLI Overview](./user-guide/cli-overview.md)
- [Interactive Shell](./user-guide/interactive-shell.md)
- [Directional Probing](./user-guide/directional-probing/README.md)
  - [North: External Interfaces](./user-guide/directional-probing/north.md)
  - [South: Dependencies](./user-guide/directional-probing/south.md)
  - [East: Data Flows](./user-guide/directional-probing/east.md)
  - [West: Authentication](./user-guide/directional-probing/west.md)
  - [All: Comprehensive Scan](./user-guide/directional-probing/all.md)
- [Stream Tapping](./user-guide/stream-tapping.md)
- [MCP Server Scanning](./user-guide/mcp-scanning.md)
- [Understanding Results](./user-guide/understanding-results.md)

---

# Platform Operations

- [Deployment](./operations/deployment/README.md)
  - [Platform Services](./operations/deployment/platform-services.md)
  - [NATS JetStream](./operations/deployment/nats-jetstream.md)
  - [TimescaleDB](./operations/deployment/timescaledb.md)
  - [Fleet Manager](./operations/deployment/fleet-manager.md)
- [Configuration](./operations/configuration/README.md)
  - [Environment Variables](./operations/configuration/env-vars.md)
  - [Resource Limits](./operations/configuration/resources.md)
  - [Network Settings](./operations/configuration/network.md)
- [Monitoring](./operations/monitoring/README.md)
  - [Web Dashboard](./operations/monitoring/dashboard.md)
  - [Prometheus Metrics](./operations/monitoring/prometheus.md)
  - [Grafana Dashboards](./operations/monitoring/grafana.md)
  - [Health Checks](./operations/monitoring/health.md)
- [Maintenance](./operations/maintenance/README.md)
  - [Updates & Upgrades](./operations/maintenance/updates.md)
  - [Backup & Recovery](./operations/maintenance/backup.md)
  - [Log Management](./operations/maintenance/logs.md)
  - [Troubleshooting](./operations/maintenance/troubleshooting.md)

---

# Testing & Demo

- [Vulnerable MCP Examples](./testing/vulnerable-mcps/README.md)
  - [mcp-sqlite: SQL Injection](./testing/vulnerable-mcps/mcp-sqlite.md)
  - [mcp-filesystem: Path Traversal](./testing/vulnerable-mcps/mcp-filesystem.md)
  - [mcp-http-api: SSRF & Secrets](./testing/vulnerable-mcps/mcp-http-api.md)
  - [Installation & Testing](./testing/vulnerable-mcps/installation.md)
- [Demo Flow](./testing/demo-flow.md)
- [Test Scenarios](./testing/test-scenarios.md)
- [Validation Checklist](./testing/validation-checklist.md)

---

# Security Testing Deep Dives

- [Vulnerability Detection](./security/vulnerability-detection.md)
- [MITRE ATLAS Mapping](./security/mitre-atlas.md)
- [Detection Patterns](./security/detection-patterns/README.md)
  - [API Keys & Secrets](./security/detection-patterns/secrets.md)
  - [PII Detection](./security/detection-patterns/pii.md)
  - [SQL Injection](./security/detection-patterns/sql-injection.md)
  - [Path Traversal](./security/detection-patterns/path-traversal.md)
  - [SSRF Patterns](./security/detection-patterns/ssrf.md)
  - [Prompt Injection](./security/detection-patterns/prompt-injection.md)
- [Severity Scoring](./security/severity-scoring.md)
- [Remediation Guide](./security/remediation.md)

---

# Architecture

- [System Overview](./architecture/overview.md)
- [Component Architecture](./architecture/components.md)
- [NATS Event Streaming](./architecture/nats-streaming.md)
- [MetaFrame Protocol](./architecture/metaframe.md)
- [A2MCP Bridge](./architecture/a2mcp-bridge.md)
- [Multi-Architecture Support](./architecture/multi-arch.md)
- [Data Flow](./architecture/data-flow.md)

---

# Integration

- [Claude Code Integration](./integration/claude-code.md)
- [Gemini CLI Integration](./integration/gemini-cli.md)
- [ChatGPT CLI Integration](./integration/chatgpt-cli.md)
- [Custom MCP Servers](./integration/custom-mcp.md)
- [API Integration](./integration/api.md)

---

# Reference

- [Configuration Reference](./reference/configuration.md)
- [CLI Command Reference](./reference/cli-commands.md)
- [API Specification](./reference/api-spec.md)
- [MetaFrame Schema](./reference/metaframe-schema.md)
- [Environment Variables](./reference/env-vars.md)
- [Troubleshooting Guide](./reference/troubleshooting.md)
- [FAQ](./reference/faq.md)
- [Glossary](./reference/glossary.md)

---

# Appendix

- [Release Notes](./appendix/release-notes.md)
- [Roadmap](./appendix/roadmap.md)
- [Contributing](./appendix/contributing.md)
- [License](./appendix/license.md)
- [Credits](./appendix/credits.md)
