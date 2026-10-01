# SIA — Self Improving AI with Harness & Weight Updates

- **Authors:** Prannay Hebbar, Yogendra Manawat, Samuel Verboomen, Alesia Ivanova, Selvam Palanimalai, Kunal Bhatia, Vignesh Baskaran (Hexo Labs)
- **Year / Venue:** 2026 (arXiv May 2026) / preprint
- **Link:** https://arxiv.org/abs/2605.27276
- **Ladder level:** 4 + weights (joint optimization)

## TL;DR
A loop with a Meta-Agent (proposes initial harness), a Task-Specific Agent (executes), and a Feedback-Agent that, from recent trajectories, decides whether the next iteration updates the harness or the task agent's weights.

## Problem
Harness evolution cannot instill domain intuition; weight training alone doesn't make a model agentic. Can one loop choose between the two levers?

## Method
1. Meta-Agent writes an initial harness for the task.
2. Task-Specific Agent runs; trajectories logged.
3. Feedback-Agent reviews and chooses: harness update (search/act behavior) or weight update (fine-tuning for domain intuition).
4. Repeat.
Objective (conceptual): $\max_{h,\theta}\mathbb{E}_x R(x,\mathrm{Run}(M_\theta,h,x))$ with a learned coordinate-choice controller.

## Key results (abstract, vs. initial baseline)
- LawBench (Chinese legal charge classification): +56.6%.
- GPU kernels: 91.9% runtime reduction.
- Single-cell RNA denoising: +502%.

## Why it matters for RSI
Early attempt to unify harness-level and model-level self-improvement in one loop — the direction Weng calls "Joint Optimization with Model Weights".

## Limitations (Weng)
- Task agent (gpt-oss-120b) much weaker than Meta/Feedback agents (Claude Sonnet 4.6) — gains may reflect strong-model supervision.
- Weak baselines; hard to cross-reference; "direction interesting, evidence provisional". Training stability and Goodhart effects open.

## Connections
Continual Harness (weight co-learning), Autodata (weak-solver training), Harness-R1, SEAL.

## Questions to think about
1. What experiment would isolate the contribution of the Feedback-Agent's choice policy?
2. Which lessons should go into weights vs. harness? Propose a criterion.
