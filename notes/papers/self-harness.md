# Self-Harness — Harnesses That Improve Themselves

- **Authors:** Zhang et al. **[full list: see paper]**
- **Year / Venue:** 2026 (arXiv June 2026) / preprint
- **Link:** https://arxiv.org/abs/2606.09498
- **Ladder level:** 4 (bounded harness surfaces), same-model self-improvement

## TL;DR
The same model that runs inside the harness mines its own verifier-grounded failure patterns, proposes bounded harness edits, and keeps only edits with no regression on both held-in and held-out tasks. Large Terminal-Bench-2.0 gains for three open-ish models, with model-specific learned instructions.

## Problem
Harnesses are hand-tuned per model; outer-loop methods often rely on a stronger external agent. Can a model improve its own harness safely?

## Method
1. **Weakness mining:** run $h_t$, collect traces, cluster failures into verifier-grounded patterns. Failure record = terminal verifier-level cause + causal status of the relevant agent behavior + abstract mechanism (same surface error ≠ same cause).
2. **Bounded proposal:** same model under $h_t$ gets (i) editable surfaces, (ii) failure patterns, (iii) passing behaviors to preserve, (iv) summaries of previous edits. Prefer recurrent, addressable patterns fixable by narrow changes; diverse candidates.
3. **Validation:** regression test on held-in $D_\text{in}$ (fixed?) and held-out $D_\text{out}$ (new breakage?). Accept only with no regression on both; merge accepted edits into $h_{t+1}$; log rejections.

## Key results (search-verified, Terminal-Bench-2.0)
| Model | Held-out pass rate | Held-in pass rate |
|---|---|---|
| MiniMax M2.5 | 40.5% → 61.9% | 43.0% → 50.0% |
| Qwen3.5-35B-A3B | 23.8% → 38.1% | 15.1% → 36.0% |
| GLM-5 | 42.9% → 57.1% | 47.7% → 57.0% |
Up to +21.4 pp absolute. Learned harness instructions differ by model (target different weaknesses).
Note: held-out split appears small (pass rates move in ~2.4 pp steps, consistent with ~42 tasks) **[inference, not stated]** → wide confidence intervals.

## Why it matters for RSI
Shows persistent self-improvement *without a stronger teacher*, with an explicit conservative acceptance rule. Weng's caution: editable surfaces must be designed and permission/security layers must remain outside the loop.

## Limitations
- Small held-out sets; reward hacking risks remain; proposer procedure fixed.
- Gains may partly reflect fixing harness/model mismatch that a human could also fix quickly.

## Connections
AHE, Meta-Harness, "Harness Updating Is Not Harness Benefit" (same-model updating feasible; benefit varies), STOP (capability dependence), SkillOpt (bounded edits + held-out gains).

## Questions to think about
1. Is "no regression on held-out" too conservative? Propose a statistical acceptance test.
2. Why might learned edits be model-specific? What does that imply for harness portability?
