# Epistemic Uncertainty for Test-Time Discovery (UG-TTT)

- **Authors:** Kainat Riaz and 7 co-authors **[names unverified]**
- **Year:** 2026 (arXiv 2605.11328, 11 May 2026)
- **Venue:** arXiv preprint
- **Link:** https://arxiv.org/abs/2605.11328

## TL;DR
Test-time RL for discovery collapses toward familiar patterns (mean reward up, max plateaus); an ensemble of LoRA adapters provides an epistemic-uncertainty exploration signal that keeps diversity and raises max reward.

## Problem
Standard RL penalizes high-variance mutations → policy prioritizes familiar patterns → diversity collapse in weights.

## Method
Small ensemble of low-rank adapters over a frozen base; per-token mutual information between ensemble predictions and adapter identity isolates epistemic (not aleatoric) uncertainty; used as a regularizer/bonus.

## Key results
Higher max reward on **3 of 4** discovery benchmarks; substantially higher solution diversity; ablation shows the regularizer is essential (abstract-level; numbers not verified).

## Why it matters for RSI
Brings the QD/novelty lesson into weight-space self-improvement.

## Limitations
Ensemble cost; one of four tasks not improved; preprint.

## Connections
TTT-Discover, ThetaEvolve, novelty search, Bayesian deep ensembles.

## Questions
Could the same epistemic signal guide parent selection in program-database evolution?
