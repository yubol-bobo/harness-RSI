# Agent-World: Scaling Real-World Environment Synthesis for Evolving General Agent Intelligence

- **Authors:** Renmin University of China and ByteDance Seed (see arXiv for full list)
- **Year:** 2026 (arXiv April 2026)
- **Link:** https://arxiv.org/abs/2604.18292

## TL;DR
A **self-evolving training arena**: automatically discover real-world environments and synthesize verifiable tasks, then train agents with multi-environment RL while the arena **detects capability gaps and generates targeted new tasks**, so policy and environments co-evolve.

## Method
1. **Agentic environment–task discovery:** explore topic-aligned databases and executable tool ecosystems across thousands of real-world environment themes; synthesize **verifiable tasks with controllable difficulty**.
2. **Continuous self-evolving agent training:** multi-environment RL plus a self-evolving arena that identifies weaknesses through dynamic task synthesis and drives targeted learning (closed loop).

## Results (verified from abstract)
- Consistently outperforms prior environment-scaling baselines across **23 agent benchmarks** (tool use, assistant, reasoning, coding).

## Relevance to harness / RSI
- Closes the loop on the **curriculum and environment**, not only the policy (cf. POET, OMNI, Absolute Zero, R-Zero in this repo).
- Environment generation = evaluator generation: task verifiers can be wrong or gameable, so Goodhart applies to the arena itself.
- Directly relevant to how ByteDance scales agentic RL for Seed models.

## Questions to prepare
- How do you verify that synthesized tasks are correct and not trivially hackable?
- How do you avoid the arena drifting toward tasks that are easy to verify but unimportant?
- How would you measure "capability gap" without overfitting to the arena's own tasks?
