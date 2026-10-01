# MCE — Meta Context Engineering via Agentic Skill Evolution

- **Authors:** Haoran Ye, Xuning He, et al. (Peking University) **[full list: see paper]**
- **Year / Venue:** 2026 (arXiv Jan 2026) / ICML 2026 (per official repo)
- **Link:** https://arxiv.org/abs/2601.21557
- **Ladder level:** 2 (base: context) + 5-ish (meta: the context-engineering mechanism)

## TL;DR
A bi-level framework: a meta-level agent evolves *context-engineering skills* (how to build context) via agentic crossover over a history of skills and scores; a base-level agent executes the skill to optimize the actual context (files and code) from training rollouts.

## Problem
Context-engineering methods like ACE hard-code the mechanism (bullets, reflect/curate rules). Different tasks need different mechanisms.

## Method
- A skill $s$ defines a context function $c_s = (\rho_s, F_s)$: static components $\rho_s$ (prompts, knowledge bases, code libraries) and dynamic operators $F_s$ (search, selection, filtering, formatting); $c = F_s(x;\rho_s)$.
- **Bi-level objective:** inner $c_s^* = \arg\max_{c_s} J_\text{train}(c_s; s)$; outer $s^* = \arg\max_{s\in\mathcal S} J_\text{val}(c_s^*)$.
- Loop $k$:
  1. Meta-agent: $s_k = \text{crossover}(\tau, \mathcal H_{k-1})$ over history $\mathcal H_{k-1}=\{(s_i,c_i,J_i^\text{train},J_i^\text{val})\}$.
  2. Base agent: $c_k = \text{engineer}(\tau, s_k; c^*_{k-1}, \mathcal R_k)$ from rollout feedback.
  3. Evaluate on train and validation; append to $\mathcal H$.
- Implementation: context = directory of files (`skill.md`, context, data rollouts); both levels are coding agents with Read/Write/Edit/Bash/Glob/Grep/TodoWrite.

## Key results (abstract)
- 5.6–53.8% relative improvement over state-of-the-art agentic CE methods (mean 16.9%).
- Official repo reports offline average relative gain 89.1% vs. ACE's 70.7% **[secondary source]**.

## Why it matters for RSI
Separates *mechanism* from *content* and makes the mechanism learnable with a validation-based outer loop — a principled step from persistent to recursive improvement in context space.

## Limitations
- Expensive (two agentic levels); the meta-level crossover procedure itself is fixed.
- Validation set reuse across many outer iterations can overfit.

## Connections
ACE (baseline/ancestor), Meta-Harness (code-level analogue; filesystem history), ALMA (meta-learned memory designs), MemEvolve, MetaSkill-Evolve (two-timescale).

## Questions to think about
1. Is MCE's outer loop more like hyperparameter optimization or meta-learning? What would make it the latter?
2. What should a skill *not* be allowed to change?
