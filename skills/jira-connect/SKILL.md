---
name: jira-connect
description: This skill is the shared Jira connection reference for the agile-flow plugin. It should be used when the user wants to connect Jira, set up the Atlassian integration, or when a Jira action fails. Triggers on Korean phrases like "지라 연결", "지라 연동 설정", "아틀라시안 연결", "지라가 안 돼", "MCP 연결 확인", and English phrases like "connect Jira", "set up Atlassian", "Jira not working", "jira auth". The other agile-flow skills (po-backlog, sprint-planning, daily-scrum, sprint-review, sprint-retro) point here for connection, tool reference, field tagging, and troubleshooting.
version: 1.0.0
---

# jira-connect — Jira connection (shared reference)

The single source of truth for how agile-flow talks to Jira. The five workflow skills reference this instead of repeating connection detail. Core principle throughout: **express intent in natural language and let Claude build the JQL / API calls** — skill files hold intent, not queries. JQL, the REST API, and workflow configuration are the automation target, not something a human writes.

## Connection — four tiers, in priority order

1. **Remote Atlassian MCP** (recommended; matches the lecture). One-time setup:
   ```bash
   claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
   ```
   Then inside Claude Code run `/mcp` and complete the browser OAuth login. The MCP acts with exactly the permissions of the logged-in account — verify org security policy before connecting a company Jira.
2. **`mcp-atlassian` MCP** (self-hosted / token). Add to the MCP config with `command: uvx`, `args: ["mcp-atlassian"]`, and env `JIRA_URL` / `JIRA_EMAIL` / `JIRA_API_TOKEN`. Use when a token setup is preferred over OAuth.
3. **REST API v3 fallback** (no MCP available). Call `/rest/api/3/issue`, `/search`, `/issue/{key}/transitions`, `/issue/{key}/comment`. Pass credentials on stdin, never in argv:
   ```bash
   jira_curl() { printf 'user = "%s:%s"\n' "$JIRA_EMAIL" "$JIRA_API_TOKEN" | curl -s -K - "$@"; }
   ```
4. **No connector at all** → do not fail. Output the fully-formatted issue text for the user to paste into Jira manually. The format-consistency benefit still holds.

To detect the current tier: check whether Atlassian MCP tools are available; if not, check for `JIRA_URL`/`JIRA_EMAIL`/`JIRA_API_TOKEN`; if neither, fall to tier 4.

## Actions available once connected

| Intent | Remote MCP (say this) | REST v3 |
|---|---|---|
| Find projects | "list the Jira projects I can see" | `GET /rest/api/3/project/search` |
| Search issues | "find open-sprint issues assigned to me" | `GET /rest/api/3/search?jql=…` |
| Get an issue | "get SOMA-2 with its fields" | `GET /rest/api/3/issue/SOMA-2` |
| Create issue | "create a Story/Task in SOMA titled …" | `POST /rest/api/3/issue` |
| Update fields | "set assignee / priority / fixVersion on …" | `PUT /rest/api/3/issue/SOMA-2` |
| Transition status | "move SOMA-2 to In Progress" | `POST /rest/api/3/issue/SOMA-2/transitions` |
| Add comment | "comment on SOMA-2: …" | `POST /rest/api/3/issue/SOMA-2/comment` |
| Link issues | "link SOMA-4 blocked by 미디어서버" | `POST /rest/api/3/issueLink` |

**Transition tip (prevents a common failure):** transition IDs vary per project workflow. Always **fetch the available transitions first** ("what transitions are available on SOMA-2?" / `GET …/transitions`) before moving an issue — do not assume a fixed ID or name.

## Field tagging conventions (shared across skills)

When creating or updating issues, use these fields consistently:

- **`parent`** — the Epic key (which theme/service chunk).
- **`fixVersions`** — the release/milestone. Tag the **story**, not the Epic; release progress is computed from the sum of tagged items.
- **`labels`** — area label + week (e.g. `week2`).
- **`assignee`** — only when a starter is confirmed; leave blank if undecided.
- **Sprint** — set during `sprint-planning`, not at backlog time. Sprint/fixVersion live on the story; sub-tasks follow their parent.

## Security

- **Never hardcode** Jira tokens in source or skill files.
- Keep `JIRA_URL` / `JIRA_EMAIL` / `JIRA_API_TOKEN` in the environment or a secrets manager; use an MCP `env` block only for local, uncommitted config.
- Ensure `.env` is gitignored. Validate credentials are set before any REST call and **fail fast** with a clear message.
- Get an API token at <https://id.atlassian.com/manage-profile/security/api-tokens>; use least-privilege tokens scoped to the needed projects; rotate immediately if exposed.

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `401 Unauthorized` | Invalid/expired token | Regenerate at id.atlassian.com |
| `403 Forbidden` | Token lacks project permission | Check token scope and project access |
| `404 Not Found` | Wrong key or base URL | Verify `JIRA_URL` and the issue key |
| transition fails | Wrong transition ID | Fetch transitions first (IDs are per-workflow) |
| `spawn uvx ENOENT` | `uvx` not on PATH | Use full path or set PATH in shell profile |
| Connection timeout | Network / VPN | Check VPN and firewall |

## Referenced by

`po-backlog` · `sprint-planning` · `daily-scrum` · `sprint-review` · `sprint-retro`. Each of those assumes a working connection and only names the fields/actions it needs; the setup, tool reference, security, and troubleshooting all live here.
