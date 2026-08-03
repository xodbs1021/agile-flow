---
name: sprint-planning
description: This skill should be used when the user wants to run a Sprint Planning meeting — selecting stories, writing or checking acceptance criteria, breaking stories into tasks, and setting a sprint goal. Triggers on Korean phrases like "스프린트 플래닝", "플래닝 하자", "이번 스프린트 계획 세우자", "태스크로 쪼개줘", "인수 기준 만들어줘", and English phrases like "sprint planning", "plan the sprint", "break this story into tasks", "write acceptance criteria". Creates Jira Task issues linked to stories and assigns the selected work to the sprint via the Atlassian MCP.
version: 2.1.0
---

# sprint-planning — Sprint Planning meeting

Sprint Planning turns "the customer's language into developer documents." This skill runs the meeting in three steps and produces two outputs: a **Sprint Backlog** (selected stories + their tasks) and a one-sentence **Sprint Goal**. The sprint goal is the single ruler used later to accept or reject scope changes.

## Inputs

Start from the top of the Product Backlog (the `Must` candidates, already shaped by `po-backlog`). Confirm sprint length (1–4 weeks, fixed) and how much capacity is available. Keep `Must` work near ~60% of capacity so Should/Could act as a buffer.

## The three steps

### STEP 1 — Story → verifiable spec (acceptance criteria)

For each selected story, attach acceptance criteria in **Given / When / Then** form:

> **Given** `<precondition>` · **When** `<action>` · **Then** `<expected result>`

- Each criterion must allow a **binary pass/fail** judgement. There is no "80% done", and never write "동작한다" — write the verifying command / query / screen procedure so reviewer and author see the same thing.
- Replace vague words ("fast", "pretty", "nice") with **measurable** thresholds (e.g. "results shown within 2 seconds", "loads 20 items per scroll"). When a vague term is found, propose the measurable form and confirm it.

### STEP 2 — Break into tasks

Decompose each story into tasks sized **half a day to two days**. Include testing and documentation as tasks, not afterthoughts. Prefer a spike (research task) first when a story depends on an unfamiliar external service.

Tasks are technical work — do **not** force a user-story sentence onto them; the *왜 (Why)* line carries the intent. Write each task to the shared ticket standard:

- **Title** — `[area] result-oriented phrase`, judgeable as done from the title alone (e.g. `[상품] 등록 API POST /products — 필수항목 검증`).
- **Body** — the fixed sections: **왜 / 무엇(포함·제외) / 완료 조건(이진, 검증 절차 포함) / 참조(정본 링크) / 의존 / 용어(*각주)**. Keep tasks shorter than stories but do not drop the section structure.
- **Ticket keys are always hyperlinks** — Jira does not auto-link a bare `KEY-123` in API-created bodies. Wherever a task mentions another issue (본문·참조·의존), write `[KEY-123](https://<site>.atlassian.net/browse/KEY-123)`; use the preset's ticket-link base when present.

### STEP 3 — Assign owners

The team that will do the work owns estimation and assignment — the PO does not assign. Record one owner per task.

## Outputs

- **Sprint Backlog** — the selected stories plus every task under them.
- **Sprint Goal** — one sentence capturing the increment's purpose (e.g. *"물건을 올리고 찾을 수 있다"*).

## Jira actions

Connection, tool reference, security, and troubleshooting live in the **`jira-connect`** skill. This skill assumes a working connection and expresses intent in natural language; Claude builds the queries.

Note on hierarchy: the official Jira unit for a split-out piece of work is a `Sub-task`, but sub-tasks cannot be independently placed on the board/sprint. Therefore create each task as a **`Task` issue linked to its parent Story**, so it can be tracked on the sprint board.

Actions this skill performs: **create** `Task` issues linked to their Story; **assign the selected stories (and their tasks) to the sprint** — this skill is where the **Sprint** axis is set (the story already carries its Epic and fixVersion from `po-backlog`); set the **sprint goal / sprint name**. Create the sprint first if none exists.

## Estimation (optional, for teams)

For multi-person teams, add Planning Poker with the Fibonacci scale (1·2·3·5·8·13): reveal simultaneously to avoid anchoring; when values diverge widely, that signals differing understanding of scope — hear the lowest and highest rationale, then re-estimate. Often the fix is splitting scope (e.g. move notifications out of a chat story), not re-estimating. Skip for solo practice.

## Logging

Write the plan to `agile-logs/planning/sprint-<n>-plan-<YYYY-MM-DD>.md`: sprint goal, length, selected stories with acceptance criteria, task list with sizes and owners, and the Jira keys created. Create the folder if missing.

## Worked example (SomaMarket, SOMA-2 상품 등록)

- **STEP 1** — Given 사진·제목·가격 중 하나가 빈 상태에서 · When 등록을 누르면 · Then 누락 항목이 표시되고 등록되지 않는다.
- **STEP 2** — 상품 테이블 스키마 (0.5d) · 등록 API POST /products (1d) · 이미지 업로드 (1d) · 등록 화면 UI (1–2d) · 등록 E2E 테스트 (0.5d). 각 Task는 제목 규칙 + 6절 본문으로 발급.
- **STEP 3** — C: 스키마·API · B: 이미지 업로드·E2E · A: 등록 화면 UI.
- **Output** — Sprint Backlog = SOMA-1·2·3 + tasks; Sprint Goal = "물건을 올리고 찾을 수 있다".

## Project preset (optional)

If the project provides a filled **`agile-flow-preset.md`** at its root (fixed Epics, Releases/fixVersions, a reference-link base, and area labels), load it and use those values instead of asking each time — e.g. assign to the preset's Epics, tag its Releases, and build 참조 links from its link base. See `presets/PRESET.example.md` for the shape. Without a preset, ask for Epic/Release when they are needed.
