# ADAS — Automated Design of Agentic Systems (Meta Agent Search)

- **Authors:** Shengran Hu, Cong Lu, Jeff Clune
- **Year / Venue:** 2024 (arXiv Aug 2024) / ICLR 2025
- **Link:** https://arxiv.org/abs/2408.08435
- **Ladder level:** 3 (workflow / agent architecture as code)

## TL;DR
Define agents in code; a meta-agent iteratively programs new agents, conditioned on an ever-growing archive of previously discovered agents and their scores. Discovered agents beat hand-designed ones and transfer across domains and models.

## Problem
Agent designs (CoT, self-consistency, debate, self-refine...) are hand-invented. Can their design be automated — including inventing new building blocks?

## Method (Weng's steps)
1. Initialize archive with simple agents (CoT, CoT-SC, Self-Refine, LLM debate, etc.).
2. Meta-agent writes a new agent: high-level idea first, then a Python `forward()` that calls the foundation model.
3. Two self-refine passes check novelty/"interestingness" and fix bugs.
4. Evaluate on validation data; add (code, score) to archive.
5. Repeat for N iterations.

Objective: $\max_{a\in\mathcal A}\mathrm{Eval}(a)$ where $\mathcal A$ = Turing-complete code space.

## Key results
- Discovered agents outperform state-of-the-art hand-designed agents on coding, science, math (abstract).
- Transfer within math: +25.9% on GSM8K and +13.2% on GSM-Hard over baselines (search-verified).
- DROP F1 +13.6/100 and MGSM +14.4% **[recalled from abstract; verify]**.
- Agents remain strong when transferred across domains and models.

## Why it matters for RSI
Moves the optimization target from prompts to *agent code* — the turning point Weng highlights ("code is a universal language"). Open-endedness flavor (archive + novelty) from Clune's lab foreshadows DGM.

## Limitations
- Costly evaluation; mostly single-call-chain QA/math agents, not long-horizon tool-using harnesses.
- Meta-agent is fixed (not recursive); AFlow reports outperforming ADAS.

## Connections
AFlow (MCTS alternative), DGM and Hyperagents (same group lineage; self-referential), OPRO (archive-in-context), Meta-Harness.

## Questions to think about
1. Why does "novelty" help even if the goal is only performance?
2. What would make ADAS recursive? (Let the meta-agent edit its own prompt/code — cf. Hyperagents.)
