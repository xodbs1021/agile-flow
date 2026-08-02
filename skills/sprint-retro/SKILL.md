---
name: sprint-retro
description: This skill should be used when the user wants to run a Sprint Retrospective — inspecting the working process with KPT (Keep / Problem / Try) and producing improvement actions for the next sprint. Triggers on Korean phrases like "스프린트 회고", "회고 하자", "레트로", "KPT 하자", and English phrases like "sprint retro", "retrospective", "run a kpt retro". Optionally creates Jira Task issues for actionable improvements via the Atlassian MCP. This is the optional Scrum event.
version: 2.0.0
---

# sprint-retro — Sprint Retrospective (process inspection)

The Retrospective inspects **the way the team works**, not the product (that is the review's job — the two do not overlap). This skill runs a KPT retro and converts the discussion into 1–3 concrete improvement actions carried into the next sprint. It is an optional event; in solo practice it can be run lightly or skipped.

## What the retro improves

1. The working **process**.
2. The **product/output** quality (how it is produced).
3. The **team's capability** and direction (optimizing).

## Workflow (KPT)

1. **Keep** — what worked and should continue. Capture specific behaviours, not vague praise.
2. **Problem** — what went wrong or caused friction. State the observed fact, not blame.
3. **Try** — candidate changes addressing the Problems.
4. **Select actions.** Distil Keep/Problem/Try into **1–3 improvement actions** small enough to apply next sprint. More than three rarely gets done.
5. **Make actions trackable (optional).** For actions that are real work, create a Jira `Task` so they are not forgotten. Write it to the shared ticket standard — `[area] result-oriented` title + the **왜 / 무엇 / 완료 조건(이진)** sections. Pure behaviour changes can stay in the log.
6. **Write the retro log** (see below).

## Jira actions

Connection, tool reference, security, and troubleshooting live in the **`jira-connect`** skill. This skill assumes a working connection and expresses intent in natural language.

Actions this skill performs (optional): **create** a `Task` for an actionable improvement, tagged to the relevant Epic and next milestone. If no connector is available, output the formatted task text for manual paste. A retro that only produces logged behaviour changes needs no Jira write at all.

## Logging

Write `agile-logs/retro/sprint-<n>-retro-<YYYY-MM-DD>.md`: the Keep / Problem / Try items, the 1–3 selected actions, and any Jira keys created for them. Create the folder if missing.

## Worked example (SomaMarket, Sprint 1 KPT)

- **Keep** — 장애물(스토리지 권한)을 데일리에서 즉시 공유해 당일 해결.
- **Problem** — 이미지 업로드 작업을 반나절로 추정했으나 이틀 소요.
- **Try** — 외부 서비스 연동 Task는 사전 조사 Task(스파이크)를 먼저 배치.
- **Action (→ next sprint)** — `[플래닝] 외부 연동 스토리엔 스파이크 선행` — 왜: 미지의 외부 연동이 추정을 깬다 / 완료 조건: [ ] 다음 플래닝에서 외부 연동 스토리마다 스파이크 Task가 선행 배치됨. 필요 시 Jira Task로 생성.
