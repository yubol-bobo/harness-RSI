# Meta-Harness — End-to-End Optimization of Model Harnesses

- **Authors:** Yoonho Lee, Nair, Zhang, Lee, Omar Khattab, Chelsea Finn (Stanford IRIS Lab) **[full first names for middle authors: see paper]**
- **Year / Venue:** 2026 (arXiv March 2026) / preprint
- **Link:** https://arxiv.org/abs/2603.28052 (project page: yoonholee.com/meta-harness)
- **Ladder level:** 4 (harness code)

## TL;DR
An outer loop where a coding-agent proposer searches over *harness code* (what to store, retrieve, and show the model), with filesystem access to the source, scores, and raw execution traces of every prior candidate. Output: a Pareto frontier of harnesses.

## Problem
Prior text optimizers (OPRO, GEPA, ACE...) compress feedback into short summaries/scores in a prompt, losing the information needed to diagnose *why* a harness fails; and they optimize only part of the harness.

## Method
1. Each candidate harness = a directory: source code, evaluation scores, rollout trajectories, state updates.
2. Proposer = coding agent (e.g., Claude Code-style) that navigates the full history with `grep`/`cat`, performs counterfactual diagnosis of failures from raw logs, and writes a new harness.
3. Evaluate new harness; keep qualified candidates; maintain Pareto frontier (e.g., accuracy vs. context cost).
4. Iterate. Search can be initialized from strong human harnesses (TerminalBench-2: Terminus-KIRA, Terminus-2).

## Key results
- Online text classification: +7.7 points over a SOTA context-management system (ACE) with 4× fewer context tokens (abstract).
- Retrieval-augmented math: one discovered harness improves accuracy on 200 IMO-level problems by 4.7 points on average across five held-out models (abstract).
- TerminalBench-2: discovered harness surpasses Terminus-KIRA and ranks #1 among Claude Haiku 4.5 agents; reported 37.6% (Haiku 4.5) and 76.4% (Opus 4.6) **[secondary sources; verify]**.
- Diagnostic context per iteration reportedly ~10M tokens vs. ~26K for prior optimizers **[secondary source: awesome-harness-engineering]**.

## Why it matters for RSI
Weng: "once harness design becomes an executable search space, a strong coding agent can exploit the same design space human engineers use." Key insight: **feedback access (observability) is the bottleneck**, and filesystems scale it.

## Limitations
- Requires a strong proposer and many expensive evaluations.
- Proposer is fixed (not self-improving); TerminalBench gains are modest when starting from strong harnesses.
- Benchmark-level search/eval overlap concerns (see "Rethinking the Evaluation of Harness Evolution").

## Connections
ACE (baseline), GEPA (Pareto, reflection), DSPy (Khattab), AHE (layered observability), MCE (filesystem-based contexts), Self-Harness.

## Questions to think about
1. Why is raw-trace access better than summaries? When would summaries be better (cost, distraction)?
2. How should one choose the Pareto objectives for harness search?
