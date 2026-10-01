# GEPA — Reflective Prompt Evolution Can Outperform Reinforcement Learning

- **Authors:** Lakshya A. Agrawal, Shangyin Tan, Dilara Soylu, Noah Ziems, Rishi Khare, Krista Opsahl-Ong, Arnav Singhvi, Herumb Shandilya, Michael J. Ryan, Meng Jiang, Christopher Potts, Koushik Sen, Alexandros G. Dimakis, Ion Stoica, Dan Klein, Matei Zaharia, Omar Khattab
- **Year / Venue:** 2025 (arXiv July 2025) / ICLR 2026 (oral)
- **Link:** https://arxiv.org/abs/2507.19457
- **Ladder level:** 1 (prompts of compound AI systems)

## TL;DR
GEPA (Genetic-Pareto) samples trajectories, *reflects* on them in natural language (including evaluator feedback text) to propose prompt edits, and maintains a Pareto frontier of candidates; it beats GRPO with far fewer rollouts and beats MIPROv2.

## Problem
RL (e.g., GRPO) adapts LLMs with thousands of rollouts that are each compressed to a scalar. Language is a richer learning medium — can prompt evolution with reflection be more sample-efficient?

## Method
1. Pool $\mathcal P = \{\Phi_0\}$, per-instance score matrix on a Pareto validation set.
2. **Pareto-based candidate selection:** keep candidates that are best on at least one instance; sample a parent weighted by how many instances it "wins" (preserves diverse strategies, avoids local optima).
3. **Reflective prompt mutation:** run the parent on a minibatch, collect traces and evaluator *feedback text* $\mu_f$ (e.g., compiler errors, failed rubric items), pick a module, ask a reflection LM to diagnose and rewrite that module's instruction.
4. **System-aware merge:** crossover two Pareto candidates that evolved different modules.
5. Accept if minibatch improves → evaluate on Pareto set → add to pool. Loop until budget.

## Key results (abstract / search-verified)
- Qwen3-8B: outperforms GRPO (24k rollouts) by up to 20%, using up to 35× fewer rollouts; average +6% across six tasks.
- Surpasses MIPROv2 on all benchmarks and models: +13% aggregate vs. MIPROv2's +5.6%.
- Also explored as an inference-time search strategy for code optimization **[details in paper]**.

## Why it matters for RSI
Strong evidence that learning in *language space* from rich feedback can beat weight-space RL in sample efficiency — the core bet of harness-level self-improvement. Pareto frontier = cheap quality-diversity.

## Limitations
- Requires informative feedback text; with only scalar rewards gains shrink.
- Optimizes prompts only (no code/tools/control flow).
- Risk of overfitting the Pareto validation set; prompt length can grow.

## Connections
OPRO, Promptbreeder (evolution), Reflexion (verbal feedback), MIPRO (baseline), ACE (compares with GEPA; addresses brevity bias), Meta-Harness (Pareto frontier over harness code), AlphaEvolve (evolutionary code search).

## Questions to think about
1. Why does instance-wise Pareto selection beat "keep the global best"? Relate to quality-diversity.
2. When would GRPO beat GEPA? (Hint: skills not expressible as instructions; very large data.)
3. Can GEPA-style reflection be used to propose *weight-update data* instead of prompts?
