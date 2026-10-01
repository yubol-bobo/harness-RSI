#!/usr/bin/env bash
# Download arXiv PDFs listed in papers/arxiv_ids.tsv and extract plain text.
#
# Usage:
#   scripts/fetch_papers.sh            # P0 only (Weng's blog references, ~35 papers)
#   scripts/fetch_papers.sh P0 P1      # P0 + awesome-rsi list
#   scripts/fetch_papers.sh all        # everything (~220 papers)
#
# Output: papers/pdf/<tier>/<arxiv_id>_<slug>.pdf  and  papers/txt/<tier>/<...>.txt
# P0 PDFs are committed; P1/P2 PDFs are git-ignored (size). All .txt extracts are committed (grep-able).
# Needs arxiv.org reachable (in the cloud sandbox, add it to the environment's allowed domains).
set -euo pipefail
cd "$(dirname "$0")/.."

tiers=("$@"); [ ${#tiers[@]} -eq 0 ] && tiers=(P0)
[ "${tiers[0]}" = "all" ] && tiers=(P0 P1 P2)

ok=0; fail=0
while IFS=$'\t' read -r tier id slug _section _title; do
  [ "$tier" = "tier" ] && continue
  [[ " ${tiers[*]} " == *" $tier "* ]] || continue
  pdf="papers/pdf/$tier/${id}_${slug}.pdf"
  txt="papers/txt/$tier/${id}_${slug}.txt"
  mkdir -p "$(dirname "$pdf")" "$(dirname "$txt")"
  if [ ! -s "$pdf" ]; then
    if curl -fsSL -m 60 -A "harness-rsi-notes/1.0" "https://arxiv.org/pdf/$id" -o "$pdf"; then
      ok=$((ok+1)); sleep 1   # be polite to arXiv
    else
      rm -f "$pdf"; fail=$((fail+1)); echo "FAIL $id $slug" >&2; continue
    fi
  fi
  [ -s "$txt" ] || pdftotext -layout "$pdf" "$txt" 2>/dev/null || true
done < papers/arxiv_ids.tsv
echo "downloaded=$ok failed=$fail"
