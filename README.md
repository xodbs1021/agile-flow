# agile-flow

Run a full Scrum cycle from Claude Code. `agile-flow` packages five workflow skills that map the Scrum events to concrete Jira actions, plus a shared **`jira-connect`** skill that handles connection, field tagging, and troubleshooting. Every meeting is recorded as a markdown log under `agile-logs/`.

Built as the reference plugin for the AISW Maestro lecture *"Claude Code로 Agile 프로젝트 운영 스킬 만들고 자동화하기"* (스크럼 운영 × Jira 연동 × Claude Code 플러그인), then hardened with a shared connection layer and a team ticket-writing standard.

> **Philosophy:** people's time goes into the product (the only real Output); the operational data around it — meeting notes, backlog, board — is automated. A skill standardises *the procedure*; the automation layer (hooks, scheduling, headless) standardises *when it runs*.

## Skills

| Skill | Scrum stage | What it does | Jira action |
|---|---|---|---|
| `po-backlog` | Product Backlog | Requests → user stories **or** technical tasks, MoSCoW, ordering, shared ticket standard | Create Story/Task, set Priority/Epic/fixVersion |
| `sprint-planning` | Planning → Sprint Backlog | Story selection, acceptance criteria (G/W/T), task breakdown, sprint goal | Create Task linked to Story, assign to sprint |
| `daily-scrum` | Daily Standup | 3 questions (yesterday/today/blockers) + log | Comments, status transitions |
| `sprint-review` | Sprint Review | Increment vs Acceptance Criteria + Definition of Done (evidence for gate items) | Approve/return, comment |
| `sprint-retro` | Retro (optional) | KPT process inspection → 1–3 improvement actions | (optional) action → Task |
| `jira-connect` | — (shared) | Connection tiers, tool reference, field tagging, security, troubleshooting | referenced by the five above |

Each meeting is logged to `agile-logs/{backlog,planning,daily,review,retro}/`.

## Ticket-writing standard (applied by po-backlog / sprint-planning)

- **Type first**: real user value → `Story` with *As a / I want / so that*; technical/infra/research → `Task` where the *왜* line carries intent (no forced user story).
- **Title** `[area] result-oriented phrase` — done/not-done judgeable from the title alone.
- **Body** fixed sections: 왜 / 무엇(포함·제외) / 완료 조건 / 참조 / 의존 / 용어.
- **Completion criteria are binary** — never "동작한다"; write the verifying command/query/screen. Vague words become measurable thresholds.
- **Design lives in the source-of-truth and is linked**, never pasted into the ticket.
- **Two-week rule**: only work startable within ~2 weeks gets a full ticket; further-out items stay one-line under their Epic.
- **Three axes**: every item has Epic (theme) + Sprint (time, set at planning) + Release/fixVersion (deploy, on the story).

## Prerequisites

1. Claude Code (logged in).
2. An Atlassian (Jira) account and one Scrum-template project (the lecture uses key `SOMA`).
3. A Jira connection — see the `jira-connect` skill. Fastest path (one-time):

   ```bash
   claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
   ```

   Then inside Claude Code run `/mcp` and complete the browser OAuth login. `jira-connect` also documents a token-based MCP, a REST fallback, and a no-connector (manual-paste) mode.

## Install

This folder is both the plugin and its own marketplace (`marketplace.json` → `source: "./"`). Two commands:

```text
# 1. register this folder as a marketplace
/plugin marketplace add /Users/kty/agile-flow

# 2. install the plugin
/plugin install agile-flow@agile-marketplace
```

Verify with `/plugin` (agile-flow should appear under Installed). After editing a skill, update the marketplace or reinstall to pick up changes.

## Usage

Invoke by natural language or as a slash command:

- Natural language: *"데일리 스크럼 하자"*, *"백로그 정리하자"*, *"스프린트 플래닝 하자"*, *"스프린트 리뷰 하자"*, *"회고 하자"*, *"지라 연결"*.
- Slash command: `/agile-flow:po-backlog`, `/agile-flow:sprint-planning`, `/agile-flow:daily-scrum`, `/agile-flow:sprint-review`, `/agile-flow:sprint-retro`, `/agile-flow:jira-connect`.

A typical one-cycle run: `po-backlog` (register stories/tasks) → `sprint-planning` (pick + break down) → `daily-scrum` (each day) → `sprint-review` (approve/return) → `sprint-retro` (KPT). After each, check Jira and `agile-logs/`.

## Design note — intent, not queries

Skill files hold **intent in plain language** ("find my issues in the open sprint"); Claude writes the actual JQL / REST calls. JQL, the REST API, and Jira workflow configuration are deliberately out of scope for the skills — they are the automation target, not the thing a human writes.

## Extending — the automation layer

The skills standardise procedures; add an execution layer on top:

- **Hooks** — e.g. a `SessionStart` hook that reminds you if today has no standup log.
- **Scheduling** — cron / Task Scheduler for a 09:00 sprint-status brief.
- **Headless** — `claude -p "..."` to update issue status at the end of a deploy script.

## Structure

```text
agile-flow/
├── .claude-plugin/
│   ├── plugin.json         # plugin manifest
│   └── marketplace.json    # single-plugin marketplace (source: "./")
├── skills/
│   ├── jira-connect/SKILL.md    # shared connection / tools / security / troubleshooting
│   ├── po-backlog/SKILL.md
│   ├── sprint-planning/SKILL.md
│   ├── daily-scrum/SKILL.md
│   ├── sprint-review/SKILL.md
│   └── sprint-retro/SKILL.md
└── README.md
```

## License

MIT

## Keeping `jira-connect` in sync with ECC

`jira-connect` was hand-synthesized from ECC's `jira-integration` skill — **there is no automatic linkage**. When ECC updates that skill, agile-flow does not change on its own. This repo ships a drift detector:

```bash
scripts/check-ecc-sync.sh          # ✅ in sync / ⚠️ ECC changed / ℹ️ no baseline
scripts/check-ecc-sync.sh --save   # accept the current ECC version as the new baseline
```

The baseline (`scripts/.ecc-jira-integration.sha` + `.baseline.md`) is committed, so the check is meaningful across machines that have the ECC plugin installed.

**Automatic reminder** — `.claude/settings.json` registers a `SessionStart` hook that runs the check whenever you open Claude Code in this project. On drift you'll see a one-line notice at session start; then say *"ECC jira-integration 바뀐 거 jira-connect에 반영해줘"* to re-sync, and run `--save` to accept the new baseline.

**Periodic (session-independent) alternative** — add a cron entry on macOS/Linux:

```cron
# every Monday 09:00, print drift to a log you check
0 9 * * 1 /Users/kty/agile-flow/scripts/check-ecc-sync.sh >> /Users/kty/agile-flow/agile-logs/ecc-sync.log 2>&1
```
