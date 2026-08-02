---
name: daily-scrum
description: This skill should be used when the user wants to run a daily standup — answering yesterday / today / blockers, recording a log, and updating the Jira board. Triggers on Korean phrases like "데일리 스크럼 하자", "스탠드업 하자", "데일리 하자", "오늘 스크럼", and English phrases like "daily scrum", "standup", "run the daily standup". Records the standup to a markdown log and reflects it in Jira (status transitions To Do → In Progress → Done, and comments) via the Atlassian MCP.
version: 2.0.0
---

# daily-scrum — Daily standup

The daily standup is a **team synchronisation and early blocker-detection** device, not a status report to a manager. This skill collects the three standard questions, records them, and moves the Jira board to match. Timebox mindset: keep it to ~15 minutes; 1–2 minutes per person.

## The three questions

1. **어제 한 일** — What was done yesterday.
2. **오늘 할 일** — What will be done today.
3. **장애물 (Blocker)** — What is blocking progress.

In a solo setup, the same three questions summarise the day; Claude does the recording and board update.

## Workflow

1. **Pull today's work.** Retrieve the current sprint's issues assigned to the person (intent: *"show my issues in the open sprint"* — let Claude build the JQL, e.g. open sprint + `assignee = currentUser()`). For a team, iterate per member.
2. **Ask the three questions.** Capture concise answers. Do not expand into problem-solving discussion here — that is the anti-pattern this event guards against.
3. **Update the board (Jira).** For each item mentioned:
   - Transition status to match reality: `To Do → In Progress → Done`. A task started today moves to In Progress; a finished one to Done. **Fetch the available transitions first** — IDs are per-workflow (see `jira-connect`).
   - Add a short **comment** capturing the progress note. Write the note as a concrete fact (what changed / what was verified), not "동작함".
4. **Handle blockers after the meeting.** Never solve blockers during standup. Record each blocker with an **owner** and a follow-up action (e.g. "스토리지 권한 발급 → B(스크럼 마스터)가 종료 직후 처리"). Note it in the log and, if useful, as a Jira comment.
5. **Write the log** (see below).

## Jira actions

Connection, tool reference, the transition-ID tip, security, and troubleshooting live in the **`jira-connect`** skill. This skill assumes a working connection and expresses intent in natural language.

Actions this skill performs: **search** the open sprint for the person's issues; **transition** issue status (`To Do → In Progress → Done`); **add comments** with the progress note. It does not create issues.

## Logging

Write one file per day: `agile-logs/daily/<YYYY-MM-DD>.md`. Include, per person: the three answers, the status transitions applied (issue key: from → to), comments added, and any blocker with its owner and follow-up. Create the folder if missing. These three sentences per person are the entire input to this skill — recording and Jira reflection are automated.

## Worked example (SomaMarket, 연수생 C)

- ① 어제: SOMA-2 상품 테이블 스키마 설계·마이그레이션 작성 완료.
- ② 오늘: 상품 등록 API (POST /products) 구현 시작.
- ③ 장애물: 이미지 스토리지 계정 권한이 아직 없다.

Board effect: move the "등록 API" task `To Do → In Progress`; comment the progress; log the blocker with owner **B** to resolve right after the meeting. Total time: 1–2 min × 3 people, inside the 15-minute box.
