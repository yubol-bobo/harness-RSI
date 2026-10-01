# R-Zero: Self-Evolving Reasoning LLM from Zero Data

- **Authors:** Chengsong Huang, Wenhao Yu, et al. (Tencent AI Seattle / WashU) **[author list partly unverified]**
- **Year / Venue:** 2025 (arXiv) / ICLR 2026
- **Link:** https://arxiv.org/abs/2508.05004

**TL;DR:** Two copies of a base model co-evolve: a Challenger proposes questions at the Solver's edge; the Solver trains on them with majority-vote pseudo-labels.

**Problem:** Self-evolution without any seed tasks or labels, beyond domains with executors.

**Method:** Challenger reward $r_{\text{unc}}=1-2|\hat p-\tfrac12|$ ($\hat p$ = Solver self-consistency with majority answer), plus repetition penalty; GRPO. Solver trains (GRPO) on filtered questions using majority-vote pseudo-labels. Alternate.

**Key results (verified):** Qwen3-4B-Base: +6.49 on math reasoning benchmarks, +7.54 on general-domain reasoning benchmarks (after three iterations for math).

**Why it matters for RSI:** Fully label-free curriculum generation; shows self-consistency can substitute for executors — to a point.

**Limitations:** Pseudo-label accuracy declines as difficulty rises → performance plateaus/declines after a few iterations **[unverified quantitative detail]**; math-centric.

**Connections:** Absolute Zero (executor-grounded), TTRL (majority-vote reward), Weng's Autodata (challenger / weak / strong solvers).

**Questions:** Can a verifier role (third agent) fix label noise? Multi-solver disagreement rewards (later work)?
