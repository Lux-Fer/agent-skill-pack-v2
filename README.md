# Agent Skill Pack V2 — 15 Production-Ready AI Coding Skills

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-blue.svg" alt="Version 2.0.0">
  <img src="https://img.shields.io/badge/skills-15-success.svg" alt="15 Skills">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="MIT License">
  <a href="https://github.com/sponsors/Lux-Fer"><img src="https://img.shields.io/github/sponsors/Lux-Fer?style=social" alt="Sponsors"></a>
  <a href="https://buymeacoffee.com/luxfer"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-☕-yellow.svg" alt="Buy Me a Coffee"></a>
</p>

**Stop telling your AI coding agent what to do. Give it institutional knowledge.**

A curated pack of **15 production-ready agent skills**. Each one is a focused `SKILL.md` that your agent loads on demand and tells it *exactly* what to do — in what order, with which commands, and which pitfalls to avoid.

Works with **Hermes Agent, Claude Code, Codex, Cursor, Cline, OpenClaw** — anything that reads `skills/<name>/SKILL.md`.

---

## Install

```bash
# Clone
git clone https://github.com/Lux-Fer/agent-skill-pack-v2.git
cd agent-skill-pack-v2

# Hermes Agent — copy all skills
cp -r skills/* ~/.hermes/skills/

# Claude Code — project-level
cp -r skills/* .claude/skills/

# Codex / other agents — point your skills directory at ./skills
```

Verify: `ls ~/.hermes/skills/` should now list 15 directories, each with a `SKILL.md`.

To install just one:

```bash
cp -r skills/security-auditor ~/.hermes/skills/
```

---

## What's Inside

| # | Skill | Category | Result |
|---|-------|----------|--------|
| 1 | **test-writer** | Quality | Tests written before code. RED → GREEN → REFACTOR, enforced. |
| 2 | **debug-master** | Development | 5-step systematic debugging. No more random guessing. |
| 3 | **code-review** | Quality | Diff analysis with severity-ranked findings and fixes. |
| 4 | **security-auditor** | Quality | OWASP-style audit: injection, secrets, authz, supply chain. |
| 5 | **refactor-pro** | Development | Safe, incremental refactors that keep tests green. |
| 6 | **performance-profiler** | Development | Find the real bottleneck before optimizing. |
| 7 | **api-designer** | Design | Versioned, consistent REST/GraphQL API contracts. |
| 8 | **architecture-designer** | Design | Trade-off-driven system design with ADRs. |
| 9 | **migration-master** | Development | Zero-downtime schema and framework migrations. |
| 10 | **dependency-manager** | Maintenance | Audit, dedupe, and upgrade deps without breaking builds. |
| 11 | **ci-craftman** | DevOps | Pipelines that fail fast and cache correctly. |
| 12 | **commit-polisher** | Git | Conventional commits and clean history, automatically. |
| 13 | **doc-generator** | Docs | READMEs, API references, and guides from the code itself. |
| 14 | **readme-artist** | Docs | READMEs that convert visitors into users. |
| 15 | **prompt-engineer** | AI | Rewrite vague instructions into precise agent prompts. |

Each skill is 100–1,000 lines of concrete procedure: when to activate, numbered steps, exact commands, verification, and a pitfalls section.

---

## Why a Skill Pack?

Generic prompts produce generic output. A skill encodes **how a senior engineer actually does the job here** — the ordering, the checks, the failure modes. Loading a skill costs a few hundred tokens and removes an entire class of rework.

```
agent + "review this PR"                    →  surface-level nitpicks
agent + code-review skill + "review this PR" →  severity-ranked findings with patches
```

---

## Structure

```
skills/
├── api-designer/
│   └── SKILL.md      # YAML frontmatter: name, description, version, tags
├── debug-master/
│   └── SKILL.md
└── ... 15 total
```

Every skill uses standard frontmatter:

```yaml
---
name: security-auditor
description: What it does and when to use it
version: 1.0.0
tags: [security, audit]
---
```

---

## License

MIT — use them commercially, ship them in your product, fork them. See [LICENSE](LICENSE).

---

## Support

If this pack saved you time, consider supporting development:

- ⭐ **Star this repo** — it genuinely helps
- 💖 [GitHub Sponsors](https://github.com/sponsors/Lux-Fer)
- ☕ [Buy Me a Coffee](https://buymeacoffee.com/luxfer)

**Want the extended edition** (25 skills + team rollout playbook)? Open an issue titled `extended` and I'll send details.
