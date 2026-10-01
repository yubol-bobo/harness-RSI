# ACE — Agentic Context Engineering: Evolving Contexts for Self-Improving Language Models

- **Authors:** Qizheng Zhang, Changran Hu, et al. (Stanford, SambaNova, UC Berkeley) **[full author list: see paper]**
- **Year / Venue:** 2025 (arXiv Oct 2025) / ICLR 2026
- **Link:** https://arxiv.org/abs/2510.04618
- **Ladder level:** 2 (structured context / playbook)

## TL;DR
Treat context as an evolving *playbook* of itemized bullets maintained by Generator → Reflector → Curator roles; the curator emits incremental delta entries merged by deterministic code, which prevents context collapse and brevity bias.

## Problem
Prompt optimizers and memory systems (a) drift to short generic instructions (**brevity bias**) and (b) suffer **context collapse** when an LLM rewrites a long context end-to-end (AppWorld example: 18,282 tokens / 66.7% accuracy → 122 tokens / 57.1% after one rewrite).

## Method
1. **Playbook:** list of bullets, each with id, content, and helpful/harmful counters.
2. **Generator:** solves tasks, cites bullets used.
3. **Reflector:** critiques successful and failed trajectories (optionally iterative refinement), extracts lessons, tags bullets as helpful/harmful.
4. **Curator:** outputs compact **delta** items (new bullets / updates), not a full rewrite.
5. **Deterministic merge** (non-LLM) by id; **grow-and-refine**: periodic de-duplication via semantic embeddings and pruning.
6. Works offline (optimize system prompt on train set) and online (test-time memory); can run without labels using execution feedback.

## Key results (abstract)
- +10.6% on agent benchmarks and +8.6% on finance (domain-specific) vs strong baselines; lower adaptation latency and rollout cost.
- AppWorld leaderboard: matches top-ranked production agent on overall average and surpasses it on the harder test-challenge split using a smaller open-source model.

## Why it matters for RSI
Practical, persistent, label-light self-improvement in context. Its "itemized deltas + deterministic merge" is an instance of a *bounded edit surface*, a recurring safety/stability principle. Used as a baseline by Meta-Harness, MCE, AHE.

## Limitations
- Update rules and workflow are hand-designed (Weng) → not recursive; MCE learns them.
- Depends on feedback quality; playbook can grow large (Meta-Harness reports beating it with 4× fewer context tokens).

## Connections
Dynamic Cheatsheet (predecessor), GEPA (compared), MCE (meta-level generalization), Meta-Harness, AHE (baseline).

## Questions to think about
1. Why is a deterministic merge more stable than an LLM rewrite? Relate to "small learning rate".
2. How would you add held-out acceptance to ACE's curator?
