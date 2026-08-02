#!/usr/bin/env bash
# check-ecc-sync.sh — detect when ECC's jira-integration skill drifts from the
# baseline that agile-flow's jira-connect was synced against.
#
# agile-flow/jira-connect was hand-synthesized from ECC's jira-integration skill.
# There is NO automatic linkage — this script tells you when ECC changed so you
# can decide whether to re-sync jira-connect.
#
# Usage:
#   scripts/check-ecc-sync.sh          # report drift (exit 0 in sync, 1 if drifted, 2 if not found)
#   scripts/check-ecc-sync.sh --save   # accept current ECC version as the new baseline
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_COPY="$HERE/.ecc-jira-integration.baseline.md"

# Locate ECC's jira-integration SKILL.md (highest installed version).
CACHE_GLOB="$HOME/.claude/plugins/cache/ecc"/*/*/skills/jira-integration/SKILL.md
ECC_FILE="$(ls -1 $CACHE_GLOB 2>/dev/null | sort -V | tail -1 || true)"

if [[ -z "${ECC_FILE:-}" || ! -f "$ECC_FILE" ]]; then
  echo "⚠️  ECC jira-integration skill not found in the plugin cache."
  echo "    (Looked under: $HOME/.claude/plugins/cache/ecc/*/*/skills/jira-integration/SKILL.md)"
  echo "    Is the ECC plugin installed? Nothing to compare — skipping."
  exit 2
fi

CUR_HASH="$(shasum -a 256 "$ECC_FILE" | awk '{print $1}')"

if [[ "${1:-}" == "--save" ]]; then
  cp "$ECC_FILE" "$BASELINE_COPY"
  echo "$CUR_HASH  $ECC_FILE" > "$HERE/.ecc-jira-integration.sha"
  echo "✅ Baseline saved."
  echo "    source : $ECC_FILE"
  echo "    sha256 : $CUR_HASH"
  exit 0
fi

if [[ ! -f "$HERE/.ecc-jira-integration.sha" ]]; then
  echo "ℹ️  No baseline yet. Run:  scripts/check-ecc-sync.sh --save"
  exit 2
fi

OLD_HASH="$(awk '{print $1}' "$HERE/.ecc-jira-integration.sha")"

if [[ "$CUR_HASH" == "$OLD_HASH" ]]; then
  echo "✅ In sync — ECC jira-integration is unchanged since the last agile-flow sync."
  exit 0
fi

echo "⚠️  ECC jira-integration CHANGED since agile-flow last synced."
echo "    baseline sha : $OLD_HASH"
echo "    current  sha : $CUR_HASH"
echo "    ECC file     : $ECC_FILE"
echo
echo "Review the diff, then decide whether jira-connect needs updating:"
echo "    diff \"$BASELINE_COPY\" \"$ECC_FILE\""
echo
echo "In Claude Code:  \"ECC jira-integration 바뀐 거 agile-flow의 jira-connect에 반영해줘\""
echo "After re-syncing jira-connect, accept the new baseline:"
echo "    scripts/check-ecc-sync.sh --save"
exit 1
