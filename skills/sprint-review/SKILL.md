---
name: sprint-review
description: This skill should be used when the user wants to run a Sprint Review — inspecting the increment, checking each story against its acceptance criteria and the Definition of Done, and approving or rejecting it. Triggers on Korean phrases like "스프린트 리뷰", "리뷰 하자", "완료 검사", "스프린트 결과 점검", and English phrases like "sprint review", "review the sprint", "check the increment". Approves or returns stories, moving rejected work back to the Product Backlog and commenting outcomes in Jira via the Atlassian MCP.
version: 2.0.0
---

# sprint-review — Sprint Review (product inspection)

The Sprint Review inspects the **product**, not the process. For every story committed to the sprint, this skill asks four questions and records the verdict. The decision authority is the PO. Crucially: **there is no partial credit** — a story is either Done or it returns to the Product Backlog.

## Two rulers

Judge each story against **both**:

- **Acceptance Criteria (AC)** — story-specific. Question: *does this story meet its requirement?* (Given/When/Then, binary — the same criteria written in `sprint-planning`.)
- **Definition of Done (DoD)** — common to all work. Question: *is this result releasable?* Typical DoD: tests pass, code review complete, docs updated. A story can meet its AC yet fail DoD (e.g. not reviewed) — then it is not done.

**Gate items need evidence.** For any story tied to a release gate/milestone, the DoD includes a **demo recording or a written reproduction procedure**. "It works" spoken aloud is not evidence — a re-runnable procedure is (and it doubles as review/audit material).

## Workflow

1. **Gather the sprint's stories.** Retrieve every story assigned to the sprint under review (intent: *"list issues in sprint N"* — let Claude build the query).
2. **Inspect each story** with four questions:
   1. Was the work completed?
   2. Was it built right? (demo against each acceptance criterion)
   3. Approve / reject — PO decides.
   4. If rejected or unfinished → return to Product Backlog.
3. **Apply verdicts in Jira** (see below). Approved → mark Done. Rejected/unfinished → remove from sprint and reopen into the backlog; never leave it as "80% done" inside the sprint. Add a comment recording the reason.
4. **Write the review log** (see below).

## Jira actions

Connection, tool reference, the transition-ID tip, security, and troubleshooting live in the **`jira-connect`** skill. This skill assumes a working connection and expresses intent in natural language.

Actions this skill performs: **list** the sprint's stories; **transition** approved stories to Done; **return** rejected/unfinished stories to the backlog (remove from sprint + reopen); **comment** the verdict and reason on each. Fetch transitions first — IDs are per-workflow.

## Logging

Write `agile-logs/review/sprint-<n>-review-<YYYY-MM-DD>.md`: per story — key, title, AC check result, DoD check result (incl. evidence link for gate items), verdict (approved / returned), reason, and the Jira action taken. Create the folder if missing.

## Worked example (SomaMarket, Sprint 1)

- **SOMA-1 회원가입** — 인수 기준 3건 시연 모두 통과 + 재현 절차 기록 → PO(A) 승인 → Done.
- **SOMA-2 상품 등록** — "필수 항목 누락 시 등록 거부" 시연에서 가격 없이 등록됨 → PO 거부 → Product Backlog로 반환 (스프린트에서 제거, reopen). "80% 완료" 상태로 남기지 않는다.

The review inspects the product; the process is inspected separately in the retro — the two events do not overlap.
