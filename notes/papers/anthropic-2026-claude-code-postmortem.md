# Claude Code Quality Postmortem (April 2026)

- **Title:** An update on recent Claude Code quality reports
- **Authors:** Anthropic
- **Year:** Apr 23, 2026
- **Link:** https://www.anthropic.com/engineering/april-23-postmortem
- **Status:** read in full

**One-line TL;DR:** Perceived "model degradation" in Claude Code was three **harness** changes: a lower default effort, a thinking-clearing cache optimization with a per-turn bug, and a verbosity-limiting system-prompt line that cost ~3% on a broader eval.

**Problem:** User reports of worse quality that internal evals and dogfooding didn't reproduce. The API and inference layer were unaffected.

**What happened:**
1. Mar 4: default reasoning effort high → medium (latency). Reverted Apr 7. Now xhigh for Opus 4.7, high for others.
2. Mar 26: clear old thinking once after more than 1 h idle (`clear_thinking_20251015`, `keep:1`). A bug cleared it **every turn** afterwards, causing forgetfulness, repetition, odd tool choices, and cache misses that drained usage limits. Fixed Apr 10 (v2.1.101). It passed human and automated review, unit/e2e tests, and dogfooding. Opus 4.7 Code Review found the bug when given full repo context; Opus 4.6 did not.
3. Apr 16: system prompt line "keep text between tool calls to ≤25 words … final responses to ≤100 words". Ablations showed a **3% drop** for Opus 4.6 and 4.7. Reverted Apr 20.

**Remediations:** staff use the exact public build; per-model broad eval suite for every system-prompt change; line-level ablations; prompt-change review tooling; model-gated CLAUDE.md guidance; soak periods and gradual rollouts.

**Why it matters for harness/RSI:** Strong real-world evidence that **harness edits move "intelligence"** as much as model changes, and that harness changes need eval gating, i.e. exactly the regression-testing discipline that automated harness evolution (Self-Harness, AHE) formalizes.

**Limitations:** No per-issue quantitative breakdown besides the 3%; it is a vendor's own account.

**My questions:** What eval would have caught bug #2 before release, e.g. long idle-resume session evals? How do you detect slice-specific regressions that look like noise in aggregate?
