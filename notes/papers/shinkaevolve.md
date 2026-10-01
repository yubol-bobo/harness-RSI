# ShinkaEvolve: Towards Open-Ended and Sample-Efficient Program Evolution

- **Authors:** Robert Tjarko Lange, Yuki Imajuku, Edoardo Cetin (Sakana AI)
- **Year:** 2025 (arXiv 2509.19349)
- **Venue:** ICLR 2026 (poster, per iclr.cc listing)
- **Link:** https://arxiv.org/abs/2509.19349

## TL;DR
Open-source AlphaEvolve-style framework focused on **sample efficiency**: adaptive parent sampling, novelty rejection sampling, bandit LLM-ensemble selection, meta-scratchpad; SOTA 26-circle packing in ~150 evaluations.

## Problem
LLM evolution typically needs thousands of samples; costly and closed.

## Method
- Parent sampling: power-law over rank $p_i\propto r_i^{-\alpha}$, or weighted $p_i\propto \sigma(\lambda(F_i-\alpha_0))\cdot\frac{1}{1+N_i}$ with $\alpha_0$ = median fitness, $N_i$ = offspring count.
- Novelty rejection: embedding cosine similarity of mutable code; above threshold → LLM-as-judge decides; else discard before evaluation.
- Bandit-based LLM ensemble selection; meta-scratchpad summarizing successful patterns into prompts; islands.

## Key results
- Circle packing (26 circles, max sum of radii): new SOTA-level solution with **~150 samples**, beating AlphaEvolve's reported value (verified via abstract/secondary).
- Other applications (AIME scaffolds, ALE-Bench, MoE load-balancing loss) **[from memory, unverified]**.

## Why it matters for RSI
Sample efficiency is the key cost lever for any evolution-based self-improvement; novelty rejection is a direct anti-collapse mechanism.

## Limitations
Small-scale benchmark tasks; circle packing is near-saturated; embedding similarity is a crude novelty measure.

## Connections
AlphaEvolve, OpenEvolve, DGM (same sigmoid×1/(1+n) selection), MAP-Elites, novelty search.

## Questions
Does novelty rejection hurt when the right move is a small refinement of an existing program?
