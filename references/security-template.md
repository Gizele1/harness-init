# SECURITY.md Template

Template for `docs/SECURITY.md`. Fill from Phase 0 discovery — describe patterns, not secrets.

## Exclusion Rules

docs/SECURITY.md MUST NOT contain:
- Actual secret values, API keys, or tokens
- Specific environment variable names used for secrets (use generic descriptions instead)
- Internal infrastructure details (IP addresses, internal hostnames, ports)
- Known unpatched vulnerability details
- Exact file paths where credentials are stored

Use generic descriptions: "Database credentials are loaded from environment variables" — not "DB_PASSWORD in .env".

## Template

<!-- AGENT INSTRUCTION: The exclusion rules above apply to ALL sections below.
     Never include specific environment variable names, credential file paths,
     internal hostnames/IPs, or unpatched vulnerability details anywhere. -->

~~~markdown
# Security

## Authentication

| Flow | Method | Where |
|------|--------|-------|
| {flow name} | {JWT / session / OAuth / API key} | {general location: middleware, gateway, etc.} |

## Authorization

{Describe the permission model: RBAC, ABAC, resource-based, etc.}
{Which layer enforces it — reference docs/architecture/LAYERS.md}

## Secrets Management

- **Storage:** {environment variables / secrets manager / vault — generic, no names}
- **Rotation:** {policy: manual / automated / on-deploy}
- **Access:** {who/what can read secrets — CI, app runtime, developers}

## Threat Model

| Threat | Mitigation | Status |
|--------|-----------|--------|
| {e.g., injection} | {e.g., parameterized queries} | {in place / planned} |
| {e.g., XSS} | {e.g., CSP headers + output encoding} | {in place / planned} |

## Dependencies

- Security-critical dependencies: {auth library, crypto library — names only, no versions with known CVEs}
- Dependency update policy: {Dependabot / manual / scheduled}

## Incident Response

- How to report: {general process}
- Escalation: {team / channel — no PII}
~~~

## When to Omit Sections

- **No auth:** Skip Authentication and Authorization (e.g., CLI tools, static sites)
- **No secrets:** Skip Secrets Management (e.g., client-only libraries)
- **Internal tool:** Threat Model can be briefer — focus on data sensitivity
