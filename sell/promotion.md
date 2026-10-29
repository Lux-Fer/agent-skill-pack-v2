# 推广素材 — Agent Skill Pack V2

## X / Twitter

```
Your AI agent isn't bad at coding. It's missing institutional knowledge.

Agent Skill Pack V2 — 15 production-ready skills for Claude Code, Codex, Cursor & Hermes:

test-writer · debug-master · code-review · security-auditor
refactor-pro · api-designer · migration-master · +8 more

Each one: exact steps, exact commands, real pitfalls.
MIT, free.

github.com/Lux-Fer/agent-skill-pack-v2
```

## Reddit r/ClaudeAI / r/ChatGPTCoding / r/SideProject

**Title:** I packaged 15 agent skills that fixed my AI coding workflow (free, MIT)

**Body:**
Every "prompt pack" I bought was a list of vibes. What actually changed my output was giving the agent a *procedure* — when to activate, what order, which command, which pitfall.

So I wrote 15 of them, one per recurring task:
- `debug-master` — 5-step systematic debugging instead of guess-and-check
- `security-auditor` — OWASP-style pass before every commit
- `test-writer` — enforces RED→GREEN→REFACTOR
- `migration-master` — zero-downtime schema changes
- +11 more (api-designer, refactor-pro, ci-craftman, doc-generator...)

Standard `skills/<name>/SKILL.md` format, so it drops into Claude Code, Codex, Cursor, or Hermes:

```
git clone https://github.com/Lux-Fer/agent-skill-pack-v2
cp -r agent-skill-pack-v2/skills/* ~/.hermes/skills/
```

MIT licensed, no upsell gate. Would love feedback on which skills are missing.

## Hacker News (Show HN)

**Title:** Show HN: 15 agent skills as drop-in SKILL.md files

**Text:** Agent skills are getting traction (anatomy hit 22k stars as a single skill), but most packs are prompt collections without procedure. This is 15 skills covering the recurring dev loop — debug, review, security, migration, CI, docs. Standard SKILL.md layout, MIT. Curious whether procedure-heavy skills actually beat good prompting in others' experience.

## 转化路径

免费仓库 → star → README 底部 Sponsors / BMC → issue「extended」询价 → $29-49 扩展版
