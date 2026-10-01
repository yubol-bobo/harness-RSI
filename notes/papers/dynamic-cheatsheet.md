# Dynamic Cheatsheet — Test-Time Learning with Adaptive Memory

- **Authors:** Mirac Suzgun, Mert Yuksekgonul, Federico Bianchi, Dan Jurafsky, James Zou
- **Year / Venue:** 2025 (arXiv April 2025) / EACL 2026
- **Link:** https://arxiv.org/abs/2504.07952
- **Ladder level:** 2 (test-time persistent memory)

## TL;DR
Give a black-box LM a persistent, self-curated "cheatsheet" of strategies, code snippets and insights that evolves across a stream of queries — no labels, no weight updates.

## Problem
LMs solve each query in isolation, re-deriving the same strategies and repeating the same mistakes.

## Method
1. **Generator:** solve query $x_i$ with current memory $M_i$ in context.
2. **Curator:** after answering, update the memory: $M_{i+1} = \mathrm{Curate}(M_i, x_i, \hat y_i)$ — keep concise, transferable, verified-looking insights and code; drop redundancy.
3. Variants: cumulative (DC-Cu) and retrieval-synthesis (DC-RS, retrieve similar past queries then synthesize) **[variant names recalled; verify]**.
4. No ground-truth labels: the model judges usefulness itself.

## Key results (abstract, search-verified)
- GPT-4o Game of 24: ~10% → 99% after discovering and reusing a Python solver.
- Claude 3.5 Sonnet accuracy on AIME more than doubled.
- Equation balancing: near-perfect for GPT-4o and Claude vs. baselines ~50%.
- Claude: +9% GPQA-Diamond, +8% MMLU-Pro (Engineering & Physics).

## Why it matters for RSI
Shows large gains from *label-free* persistent context evolution, and that code snippets in memory turn one-off solutions into reusable tools. ACE builds directly on DC and fixes its rewrite-induced context collapse.

## Limitations
- Monolithic rewrites → context collapse risk (ACE's critique); memory can encode wrong strategies (no external verifier).
- Gains concentrated on tasks with reusable procedures (Game of 24); smaller on knowledge tasks.

## Connections
ACE, ExpeL, AWM, TextGrad (same group), Voyager (code skills).

## Questions to think about
1. Without labels, what prevents self-reinforcing errors? Design a cheap verifier.
2. Why do "algorithmic" tasks benefit most from memory?
