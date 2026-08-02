<p align="center">
  <h1 align="center">🏃 agile-flow</h1>
  <p align="center">
    <strong>Run a full Scrum cycle from Claude Code — mirrored to Jira, logged to markdown.</strong><br>
    Groom the backlog · plan sprints · run daily standups · review increments · hold retros.
  </p>
</p>

<p align="center">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
  <img alt="Version" src="https://img.shields.io/badge/version-1.1.0-blue.svg">
  <img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-plugin-8A63D2.svg">
  <img alt="Skills" src="https://img.shields.io/badge/skills-6-orange.svg">
  <img alt="PRs" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg">
</p>

---

**agile-flow** packages the five Scrum events as Claude Code skills, plus a shared connection skill. Say *"데일리 스크럼 하자"* or run `/agile-flow:po-backlog`, and Claude drives your Jira board through the Atlassian MCP while recording every meeting to `agile-logs/`. You write **intent in plain language** — Claude writes the JQL and API calls.

> **Why:** people's time belongs on the product (the only real Output). The operational data around it — meeting notes, backlog grooming, board updates — is repetitive and automatable. A skill standardises *the procedure*; the automation layer (hooks, scheduling, headless) standardises *when it runs*.

## ✨ Highlights

- **Six skills, one install** — the whole Scrum loop, ready to run.
- **Intent, not queries** — no JQL to memorise; describe what you want.
- **A ticket-writing standard** — every issue comes out in the same shape: `[area]` titles judgeable as done, binary completion criteria (no "it works"), story-vs-task typing so plumbing doesn't get a forced user story.
- **Four connection tiers** — remote Atlassian MCP → token MCP → REST → manual-paste; it degrades gracefully instead of failing.
- **Everything logged** — every meeting lands in `agile-logs/` as markdown you own.

## 🚀 Installation

This folder is both the plugin and its own marketplace (`source: "./"`). Two commands inside Claude Code:

```text
/plugin marketplace add https://github.com/xodbs1021/agile-flow
/plugin install agile-flow@agile-marketplace
```

Verify with `/plugin` — `agile-flow` appears under **Installed**.

### Prerequisites

1. Claude Code, logged in.
2. A Jira (Atlassian) account + one Scrum-template project.
3. A Jira connection — fastest path (one-time):
   ```bash
   claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
   ```
   then `/mcp` in Claude Code for the browser OAuth login. The `jira-connect` skill documents the token-MCP, REST, and no-connector fallbacks.

## 🧩 Skills

| Skill | Scrum stage | What it does | Jira action |
|---|---|---|---|
| `po-backlog` | Product Backlog | Requests → stories **or** technical tasks, MoSCoW, ordering, shared ticket standard | Create Story/Task · set Priority/Epic/fixVersion |
| `sprint-planning` | Planning → Sprint Backlog | Story selection, acceptance criteria (G/W/T), task breakdown, sprint goal | Create Task linked to Story · assign to sprint |
| `daily-scrum` | Daily Standup | 3 questions (yesterday/today/blockers) + log | Comments · status transitions |
| `sprint-review` | Sprint Review | Increment vs Acceptance Criteria + Definition of Done | Approve/return · comment |
| `sprint-retro` | Retro *(optional)* | KPT process inspection → 1–3 improvement actions | *(optional)* action → Task |
| `jira-connect` | *shared* | Connection tiers, tool reference, field tagging, security, troubleshooting | referenced by the five above |

## 💬 Usage

Invoke by natural language or slash command:

```text
"백로그 정리하자"          →  /agile-flow:po-backlog
"스프린트 플래닝 하자"     →  /agile-flow:sprint-planning
"데일리 스크럼 하자"       →  /agile-flow:daily-scrum
"스프린트 리뷰 하자"       →  /agile-flow:sprint-review
"회고 하자"               →  /agile-flow:sprint-retro
"지라 연결"               →  /agile-flow:jira-connect
```

**A one-cycle run:** `po-backlog` (register stories/tasks) → `sprint-planning` (pick + break down) → `daily-scrum` (each day) → `sprint-review` (approve/return) → `sprint-retro` (KPT). After each, check Jira and `agile-logs/`.

## 🛠️ How it works — the ticket-writing standard

`po-backlog` and `sprint-planning` write every issue to one standard so the output is consistent no matter who (or which session) issued it:

- **Type first** — real user value → `Story` (*As a / I want / so that*); technical/infra/research → `Task`, where the *왜 (Why)* line carries intent (no forced user story).
- **Title** — `[area] result-oriented phrase`, judgeable as done from the title alone.
- **Body** — fixed sections: 왜 / 무엇(scope in-out) / 완료 조건 / 참조 / 의존 / 용어.
- **Binary completion** — never "동작한다"; write the verifying command/query/screen. Vague words become measurable thresholds.
- **Design is linked, never pasted** — it lives in the source-of-truth and drifts if copied into a ticket.
- **Two-week rule** — only work startable within ~2 weeks gets a full ticket; further-out items stay one-line under their Epic.
- **Three axes** — every item has Epic (theme) + Sprint (time, set at planning) + Release/fixVersion (deploy, on the story).

## 🔄 Keeping `jira-connect` in sync with ECC

`jira-connect` was synthesized from a general Jira-integration skill — **not linked**, so upstream changes don't propagate automatically. A drift detector ships in this repo:

```bash
scripts/check-ecc-sync.sh          # ✅ in sync / ⚠️ upstream changed / ℹ️ no baseline
scripts/check-ecc-sync.sh --save   # accept the current upstream as the new baseline
```

`.claude/settings.json` registers a `SessionStart` hook that runs this check whenever you open Claude Code in the project, so drift surfaces on its own. See the section in each skill for the re-sync prompt.

## 🧱 Structure

```text
agile-flow/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest
│   └── marketplace.json     # single-plugin marketplace (source: "./")
├── skills/
│   ├── jira-connect/        # shared connection / tools / security / troubleshooting
│   ├── po-backlog/
│   ├── sprint-planning/
│   ├── daily-scrum/
│   ├── sprint-review/
│   └── sprint-retro/
├── scripts/
│   └── check-ecc-sync.sh    # upstream drift detector
├── .claude/settings.json    # SessionStart drift reminder
└── README.md
```

## 🤝 Contributing

Issues and PRs welcome. Skills are plain markdown (`skills/<name>/SKILL.md`) — edit the procedure, keep the ticket-writing standard, and re-install to test. Every skill holds *intent*, not hardcoded queries.

## 🙏 Credits

Designed from the AISW Maestro lecture *"Claude Code로 Agile 프로젝트 운영 스킬 만들고 자동화하기"* (스크럼 운영 × Jira 연동 × Claude Code 플러그인), then hardened with a shared connection layer and a battle-tested ticket-writing standard drawn from real Jira operating conventions.

## 📄 License

MIT
