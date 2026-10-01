# A Self-Improving Coding Agent (SICA)

- **Authors:** Maxime Robeyns, Martin Szummer, Laurence Aitchison (Bristol / iGent AI)
- **Year:** 2025 (arXiv 2504.15228)
- **Venue:** ICLR 2025 Workshop on Scaling Self-Improving Foundation Models (SSI-FM)
- **Link:** https://arxiv.org/abs/2504.15228

## TL;DR
Removes the meta-agent/target-agent split: the best agent in the archive edits its own codebase; SWE-bench Verified (random subset) 17% → 53%.

## Problem
ADAS-style systems use a fixed meta-agent; can the agent improve the code that runs it?

## Method
- Archive of agent versions with benchmark results; each iteration the best agent is the meta-agent, reviews the archive, implements an improvement to itself.
- Utility $U = 0.5\,p_{score} + 0.25(1-\min(1,p_{cost}/\$10)) + 0.25(1-\min(1,p_{time}/300s))$, ×0.5 on timeout.
- Asynchronous LLM **overseer** monitors for pathological behaviour.

## Key results
17% → 53% on a random subset of SWE-bench Verified; gains on LiveCodeBench and synthetic agent benchmarks.

## Why it matters for RSI
Simple, reproducible self-referential loop with explicit cost/time in the utility and an oversight mechanism.

## Limitations
Greedy (best-agent) selection → local optima; subset evaluation is noisy; gains largest on agentic tasks, smaller on pure reasoning tasks **[from memory]**.

## Connections
DGM (archive-based open-ended version), HGM, ADAS, STOP.

## Questions
How do SICA's overseer and DGM's hidden evaluators compare as anti-hacking measures?
