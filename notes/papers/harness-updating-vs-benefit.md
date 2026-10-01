# Harness Updating Is Not Harness Benefit: Disentangling Evolution Capabilities in Self-Evolving LLM Agents

- **Authors:** Lin et al. **[first author possibly Minhua Lin — unverified]**
- **Year / Venue:** 2026 (arXiv May 2026) / preprint
- **Link:** https://arxiv.org/abs/2605.30621
- **Ladder level:** analysis paper (levels 2–4)

## TL;DR
Self-evolving agents need two different capabilities: *harness-updating* (writing useful harness edits) and *harness-benefit* (actually exploiting the updated harness). The first is roughly flat across model scales; the second is non-monotonic — mid-tier models benefit most.

## Problem
Prior work conflates "the model improved its harness" with "the improved harness helped". Which capability limits self-evolution, and does it scale with model size?

## Method
- Factorize: proposer/evolver model (writes edits) × executor model (uses harness).
- Cross models from small open models (Qwen family, incl. a 9B Qwen3.5) to Claude Opus 4.6; measure update quality and downstream benefit separately.

## Key results (Weng + abstract-level)
- Harness-updating capability ~flat across models (Weng's figure: from Qwen2-32B to Opus 4.6); a 9B evolver writes skills "procedurally isomorphic" to Opus's.
- Harness-benefit is non-monotonic: middle-tier models benefit most. Benefit requires invoking skills/tools correctly and timely, plus long-horizon instruction following.
- Exact numbers **[not reproduced]**.

## Why it matters for RSI
Refines STOP's "capability dependence": the bottleneck is often the *consumer* of the harness, not the *author*. Practical: cheap models can author harness updates; evaluate benefit per target model; for strongest models gains may shrink because behavior is already internalized.

## Limitations
- Results depend on which harness components are evolved (skills vs. code) and on task families.
- "Flat updating" may not hold for deeper levels (e.g., optimizer code as in STOP).

## Connections
STOP, Self-Harness (model-specific edits), AHE (cross-model transfer), Harness-R1 (training a small harness engineer), Weng's "internalization" thesis.

## Questions to think about
1. Design a training objective that increases harness-benefit (skill-following RL?).
2. Why would the strongest models benefit less? Give two hypotheses and an experiment to separate them.
