---
name: po-backlog
description: This skill should be used when the user wants to groom or manage the Product Backlog, or issue backlog items to Jira in a consistent shape — turning requests into stories or technical tasks, classifying with MoSCoW, ordering by priority, and writing each item to a shared ticket standard. Triggers on Korean phrases like "백로그 정리", "백로그에 추가", "이거 스토리로 만들어줘", "티켓 발급해줘", "우선순위 매겨줘", "제품 백로그 보여줘", and English phrases like "groom the backlog", "add to the backlog", "turn this into a user story", "write a ticket", "prioritize the backlog". Creates and re-orders Jira issues, sets Priority, Epic (parent), and fixVersion via the Atlassian MCP.
version: 2.0.0
---

# po-backlog — Product Backlog management

The Product Backlog is the single, ordered source of every requirement. This skill acts as the Product Owner's assistant and, just as importantly, enforces one **shared ticket-writing standard** so that whoever issues an item, the same structure comes out. It converts requests into well-formed backlog items, classifies them with MoSCoW, keeps the list ordered by priority, and mirrors the result into Jira. Order equals priority — the position of an item *is* its rank.

## Core rules (never violate)

- **Single source**: requirements enter only through the backlog. Do not scatter them across chats or docs.
- **PO owns edits**: only the Product Owner adds, changes, or deletes backlog items. When acting on someone else's request, capture it but flag that PO approval orders it.
- **Order = priority**: there is no separate "priority" concept beyond rank. Higher position = higher priority.
- **Progressive refinement**: detail top items down to a full ticket; leave lower items as a one-line title.
- **Two-week rule**: only work that can start within ~2 weeks becomes a fully detailed item. Everything further out stays as a single sentence under its Epic description. This prevents a backlog junkyard of 100 issues no one reads.
- **Design lives in the source-of-truth, not in tickets**: put background and design in the project wiki/docs and *link* to it. Never paste design into a ticket body — it drifts from the real source.

## Three axes — every item belongs to three independently

A backlog item is not just "under an Epic". It sits on three independent axes:

```
item "상품 등록 API 구현"
 ├─ Epic:    어느 주제/서비스 덩어리인가   (theme axis)
 ├─ Sprint:  언제 하나                      (time axis — set later in sprint-planning)
 └─ Release: 어느 마일스톤에 실리나 (fixVersion, deploy axis)
```

In `po-backlog`, set the **Epic (parent)** and the **Release (fixVersion)** and the **rank**. Do **not** set the Sprint here — that is assigned during `sprint-planning`. Tag `fixVersion` on the **story**, not on the Epic, because release progress is computed from the sum of its tagged items.

## Decide the item type first — story vs technical task

Before writing anything, decide which the request is:

- **Real user value present** → write a **user story**: *As a `<role>`, I want `<capability>`, so that `<benefit>`.* If the role or benefit is missing, ask — do not invent them. A requirement with no role and no benefit is an "ownerless requirement" and the main cause of backlog bloat.
- **Technical / infra / research work, no direct user value** (e.g. CI pipeline, schema migration, a spike) → do **not** force a user-story sentence onto it. Write it as a **Task**; the *왜 (Why)* line carries the intent instead. Forcing "As a…" onto plumbing produces noise, not clarity.

## The ticket-writing standard

### Title — `[area] result-oriented phrase`

Judge "is it done?" from the title alone. The `[area]` matches the Epic's label.

- ✅ `[상품] 등록 API — 필수항목 누락 시 400 반환`
- ✅ `[검색] 제목 부분일치 검색 + 최신순 정렬`
- ❌ `등록 작업` (no result) · ❌ `검색 관련` (unjudgeable)

### Description template (fixed order)

For an item being refined into a next-sprint candidate, write the body in this exact order:

```
**왜:**   한두 줄 — 이게 없으면 무엇이 안 되는가. 배경은 정본 링크로 대체.
**무엇:** 범위. 포함/제외를 한 줄로 명시 ("~는 이 항목 범위 밖" → 스코프 크립 차단).
**완료 조건:** 체크박스, 각 항목이 이진(binary) — 검증 명령/절차/화면 포함.
  - [ ] 예: 필수항목 하나라도 비면 등록 거부 (확인: 가격 빈 요청 → 400 + 미등록)
**참조:** 정본 링크 1~3개 — 반드시 클릭 가능한 URL. 설계 복붙 금지.
**의존:** 선행 항목/미결이 있으면 키로, 없으면 "없음".
**용어:** 본문에 *를 붙인 용어의 한 줄 풀이.
```

- **완료 조건에 "동작한다" 금지** — "동작"은 사람마다 다르다. 검증 명령·쿼리·화면 절차로 써야 리뷰어와 작성자가 같은 것을 본다. 행동 시나리오면 Given/When/Then도 가능.
- **Coarse bottom items** (beyond the 2-week horizon) skip the full template: just title + MoSCoW grade + a one-line *왜*. Expand to the full template only when the item nears the top.

### Glossary footnotes (required when cross-discipline)

The moment a teammate hits a term from another discipline and has to go search, the ticket has failed. Mark the first occurrence of a hard term with `*` and explain it in one line under **용어**, phrased as *"what it means in this project"* — not a dictionary definition. Skip terms the team uses daily.

## MoSCoW + feature buffer

Assign exactly one grade with a reason:

- **Must** — the product does not work without it (minimum release definition).
- **Should** — important but a costly workaround exists.
- **Could** — nice to have; include only if capacity allows.
- **Won't (this time)** — agreed out of scope now; a scope-defence decision worth recording.

Keep `Must` near ~60% of capacity per release/sprint (DSDM guidance); the remaining 30–40% (Should/Could) absorbs uncertainty. If problems arise, shed Could before Should to protect the Musts.

## Workflow

### Intent A — Add / issue an item

1. **Decide type** (story vs technical task) per the rule above.
2. **Draft** title + description in the standard. Ask for any missing role/benefit (stories) or missing *왜/완료 조건* (tasks).
3. **Classify** with MoSCoW + reason; apply the feature buffer.
4. **Place** on the axes: Epic (parent), Release (fixVersion), and rank (weigh risk, value, dependency, size).
5. **Reflect into Jira** (see below). Record `Won't` items as a note only — never create an issue for them, but never silently drop the decision either.

### Intent B — Re-prioritize

Read the current ranked backlog, propose a new order with a one-line justification per move (risk/value/dependency/size), and on confirmation update rank and Priority.

### Intent C — Show the backlog

Retrieve the ordered list of sprint-unassigned issues and present rank, key, title, type, MoSCoW grade, Epic, fixVersion, and refinement level as a table.

## Jira actions

Connection, tool reference, security, and troubleshooting live in the **`jira-connect`** skill — see it for setup and the four connection tiers (remote MCP → mcp-atlassian → REST → manual-paste). This skill assumes a working connection and expresses **intent** in natural language; Claude builds the JQL / API calls.

Actions this skill performs: **create** an issue (`Story` for user-value items, `Task` for technical items), **set Priority/rank**, and place it on the axes. Fields set here: **`parent`** (Epic key), **`fixVersions`** (milestone — tagged on the story, never the Epic), **`labels`** (area + week), **`assignee`** (only if a starter is confirmed). Do **not** set Sprint here — that is assigned in `sprint-planning`. Record `Won't` items as a note only, never as an issue.

## Logging

After any change, append to `agile-logs/backlog/backlog-<YYYY-MM-DD>.md`: timestamp, intent, and per item — type (story/task), title, description sections, MoSCoW grade + rationale, Epic, fixVersion, rank, and Jira key. Create the folder if missing. Logs are operational data for transparency — they are not the product.

## Worked example (SomaMarket) — the two item types side by side

**User-story item** — request *"상품 등록 기능 넣어줘"*:
> `[상품] 상품 등록 — 필수항목 누락 시 등록 거부`
> **왜:** 판매자가 물건을 못 올리면 거래 자체가 성립하지 않는다.
> **무엇:** 사진·제목·가격·설명 입력 후 등록. (결제·안전거래는 범위 밖.)
> **완료 조건:** [ ] 가격 빈 상태로 등록 시 400 + 미등록 (확인: 빈 요청 → 응답코드·DB 미삽입)
> As a 판매자, I want 사진·제목·가격·설명으로 상품을 등록하고 싶다, so that 안 쓰는 물건을 빠르게 내놓을 수 있다.
> MoSCoW **Must** · Epic 상품거래MVP · fixVersion M1 · rank #2 → Jira `Story` SOMA-2.

**Technical item** — no forced user story:
> `[인프라] CI 파이프라인 — PR마다 테스트·빌드 자동 실행`
> **왜:** 매 PR을 수동 검증하면 회귀가 늦게 발견된다.
> **완료 조건:** [ ] PR 열면 GitHub Actions가 테스트+빌드 실행, 실패 시 머지 차단.
> MoSCoW **Should** · Epic 개발환경 · fixVersion M1 → Jira `Task` (유저스토리 문구 없음).
