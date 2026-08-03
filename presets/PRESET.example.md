# agile-flow project preset (example)

A preset pins per-project conventions so the skills stop asking every time. Fill a copy
and place it at your **project root** as `agile-flow-preset.md` (private projects keep it
in their own repo/wiki, not here). `po-backlog` and `sprint-planning` load it when present.

## Epics (fixed — assign to these, don't invent new ones)
- <KEY-1> <name> — label:<area>
- <KEY-2> <name> — label:<area>

## Releases (fixVersion)
- <M1> <name> · <M2> <name> · <M3> <name>

## Reference-link base
- <https://github.com/org/your-wiki/blob/main/>   # 참조 links resolve against this base
- <https://your-site.atlassian.net/browse/>       # ticket-link base — 의존/참조/본문 속 KEY-123은 이 base로 하이퍼링크

## Area labels
- <area1> · <area2> · <area3>

## Project rules (optional)
- Gate items require a demo recording or reproduction procedure in the DoD.
- Two-week rule, ticket = story sub-unit, fixVersion/sprint live on the story, etc.
