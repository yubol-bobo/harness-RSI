# Learning to Discover at Test Time (TTT-Discover)

- **Authors:** Mert Yuksekgonul et al. (Stanford / NVIDIA collaborators; incl. Yu Sun, James Zou, Carlos Guestrin per memory) — full list **[unverified]**
- **Year:** 2026 (arXiv 2601.16175, Jan 2026)
- **Venue:** ICML 2026 (poster, per icml.cc listing)
- **Link:** https://arxiv.org/abs/2601.16175 · https://test-time-training.github.io/discover/

## TL;DR
Instead of searching with a frozen LLM, run RL **on the single test problem** with an objective that rewards the *best* outcome; sets records in math, GPU kernels, algorithms, and biology.

## Problem
Discovery wants one exceptional solution; frozen-model search can't internalize problem structure; mean-reward RL is risk-neutral.

## Method
- gpt-oss-120b fine-tuned via Tinker (~50 RL steps per problem).
- **Entropic objective** weighting samples exponentially by reward (risk-seeking; tends to max as temperature→0) — exact form in paper.
- **PUCT-inspired reuse**: buffer of past attempts; choose which state to extend balancing value and exploration.
- Importance-sampling correction for sampler/learner mismatch.

## Key results (verified via search snippets)
- Erdős minimum overlap **0.380876** (prior AI 0.380924; human 0.380927).
- Autocorrelation inequality AC1: **C₁ ≤ 1.50286** (beats AlphaEvolve V2 and ThetaEvolve).
- GPUMode TriMul: A100 **2198 µs** vs human 4531 µs; H100 **1161 µs** vs 1371 µs.
- Also past AtCoder contests and single-cell denoising.

## Why it matters for RSI
Test-time weight updates on the problem = a form of self-improvement during inference; the population moves from prompt to parameters.

## Limitations
Needs exact, cheap reward; GPU training per problem; diversity collapse risk (addressed by UG-TTT).

## Connections
ThetaEvolve, AlphaEvolve, UG-TTT, test-time training (Sun et al.), MCTS/PUCT.

## Questions
How does compute-matched TTT-Discover compare with a large frozen-model evolution run?
