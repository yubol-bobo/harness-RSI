# ThetaEvolve: Test-time Learning on Open Problems

- **Authors:** Yiping Wang et al. (incl. Microsoft Research collaborators) — full list **[unverified]**
- **Year:** 2025 (arXiv 2511.23473, Nov 2025)
- **Venue:** ICML 2026 (poster, per icml.cc listing)
- **Link:** https://arxiv.org/abs/2511.23473

## TL;DR
Simplified open-source AlphaEvolve with a single small LLM that is **trained by RL at test time** on the evolution rewards; an 8B model sets new best-known bounds.

## Problem
AlphaEvolve uses frozen frontier models; can a small open model *learn* to evolve better during the search?

## Method
Single LLM; large program database; batch sampling; lazy penalties against stagnant outputs; optional reward shaping; in-context evolution + RL updates.

## Key results
- DeepSeek-R1-0528-Qwen3-8B: circle packing **2.63598308** and new bound on the first autocorrelation inequality (verified via abstract/secondary).
- RL at test time beats inference-only baselines across 2 models × 4 tasks; RL checkpoints evolve faster on unseen tasks.

## Why it matters for RSI
Shows "ability to evolve" is a trainable skill — bridge between harness-level evolution and weight-level self-improvement.

## Limitations
Narrow math/optimization tasks; RL risks diversity collapse (cf. UG-TTT).

## Connections
AlphaEvolve, TTT-Discover, UG-TTT, ShinkaEvolve.

## Questions
Does the learned evolving skill transfer to harness/agent evolution, not just math programs?
