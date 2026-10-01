# AlphaEvolve: A Coding Agent for Scientific and Algorithmic Discovery

- **Authors:** Alexander Novikov, Ngân Vũ, Marvin Eisenberger, Emilien Dupont, Po-Sen Huang, Adam Zsolt Wagner, Sergey Shirobokov, Borislav Kozlovskii, Francisco J. R. Ruiz, Abbas Mehrabian, M. Pawan Kumar, Abigail See, Swarat Chaudhuri, George Holland, Alex Davies, Sebastian Nowozin, Pushmeet Kohli, Matej Balog (Google DeepMind) — list from memory **[verify]**
- **Year:** 2025 (white paper May 2025; arXiv 2506.13131)
- **Venue:** DeepMind white paper / arXiv
- **Link:** https://arxiv.org/abs/2506.13131 · PDF (local) `papers/pdf/P0/2506.13131_alphaevolve-a-coding-agent-for-scientific-and-algorithmic-di.pdf`

## TL;DR
An asynchronous evolutionary loop in which Gemini models propose diffs to whole codebases (regions marked with EVOLVE-BLOCK), automated evaluators score them, and a MAP-Elites/island database keeps good and diverse programs — yielding new math results and deployed Google infrastructure improvements.

## Problem
FunSearch evolved a single short function with small LLMs; scale to whole files, many languages, expensive evaluators, and frontier LLMs.

## Method (verified in PDF)
- `# EVOLVE-BLOCK-START/END` markers; `evaluate()` returns dict of scalars (multi-objective).
- Prompt sampler: parents + inspirations + scores + context + **meta-prompt evolution**.
- LLM ensemble: **Gemini 2.0 Flash + Gemini 2.0 Pro**; SEARCH/REPLACE diffs or full rewrites.
- Evaluation **cascade** (cheap→expensive), optional LLM feedback, parallel evaluation (~100 compute-hours per candidate affordable).
- Program database: MAP-Elites + island models; asyncio distributed pipeline.

## Key results (verified in PDF)
- 4×4 complex matmul with **48** multiplications (first improvement over Strassen-recursive 49 in char. 0 in 56 years); SOTA on **14** matmul targets.
- >50 math problems: ~**75%** matched SOTA, ~**20%** improved (e.g. Erdős minimum overlap, kissing number 11D → **593**).
- Borg scheduling heuristic recovers **0.7%** of fleet-wide stranded compute (deployed).
- Gemini kernel tiling: **23%** average kernel speedup, **1%** less Gemini training time.
- TPU Verilog simplification; FlashAttention IR **32%** speedup, pre/post-processing **15%**.
- Ablations: evolution, context, meta-prompts, full-file evolution, strong LLMs all matter.

## Why it matters for RSI
Closes a (human-gated) loop: AlphaEvolve sped up training of the Gemini models that power it. Demonstrates the value of cheap precise evaluators.

## Limitations
Requires machine-gradable evaluators; closed system; compute-heavy; no learning in the mutator (fixed weights).

## Connections
FunSearch, OpenEvolve, ShinkaEvolve, ThetaEvolve, TTT-Discover; follow-ups: rational 48-mult algorithm (arXiv 2506.13242), Georgiev/Gómez-Serrano/Tao/Wagner 67-problem study (arXiv 2511.02864); May 2026 impact update (DeepConsensus −30% errors, ACOPF feasibility 14%→>88% **[secondary]**).

## Questions
How much does meta-prompt evolution contribute vs. the database? Can the cascade be learned?
