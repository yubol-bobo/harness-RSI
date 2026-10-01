# Rethinking the Evaluation of Harness Evolution for Agents

- **Authors:** Yike Wang, Huaisheng Zhu, Zhengyu Hu, Yige Yuan, Zhengyu Chen, Shakti Senthil, Hannaneh Hajishirzi, Yulia Tsvetkov, Pradeep Dasigi, Teng Xiao
- **Year / Venue:** 2026 (arXiv July 2026) / preprint
- **Link:** https://arxiv.org/abs/2607.12227
- **Ladder level:** methodology critique (level 4)

## TL;DR
Harness evolution methods search on a benchmark and report on the same benchmark, and rarely compare against simple test-time search at matched budget. Under fair protocols on Terminal-Bench 2.1 (GPT-5.4, Claude Opus 4.6), automatic harness evolution does not consistently beat simple test-time scaling and gives only marginal held-out gains.

## Problem
Are reported harness-evolution gains real generalizable improvements, or search-on-test effects?

## Method
1. Treat harness evolution as an iterative search procedure → compare to task-level search baselines (e.g., retries/best-of-k) under matched feedback and inference budgets.
2. Separate search tasks from evaluation tasks.

## Key results (abstract)
- Automatic harness evolution does not consistently outperform simple test-time scaling methods; limited generalization.
- With search and evaluation tasks separated, evolved harnesses give only marginal held-out improvements.

## Why it matters for RSI
The essential skeptical counterweight to Meta-Harness/AHE/Self-Harness headline numbers. In an interview, citing it shows evaluation maturity.

## Limitations
- One benchmark family and two frontier models; very strong models may benefit less (cf. "Harness Updating Is Not Harness Benefit").

## Connections
Self-Harness (uses held-out split), AHE (transfer test), Meta-Harness, Lin et al. 2026.

## Questions to think about
1. Design a protocol that fairly credits *amortization*: harness evolution costs once, test-time scaling costs per query.
2. What benchmark properties make harness evolution likely to generalize?
