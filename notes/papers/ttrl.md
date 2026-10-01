# TTRL: Test-Time Reinforcement Learning

- **Authors:** Yuxin Zuo, Kaiyan Zhang, et al. (Tsinghua / Shanghai AI Lab) **[authors partly unverified]**
- **Year / Venue:** 2025 / NeurIPS 2025
- **Link:** https://arxiv.org/abs/2504.16084

**TL;DR:** RL on unlabeled test questions using majority vote over the model's own samples as the pseudo-label.

**Problem:** RL needs ground-truth rewards; test-time data is unlabeled.

**Method:** For each question sample N outputs; label = majority answer; reward $r_i=\mathbb{1}[\text{ans}(y_i)=\text{maj}]$; standard outcome-reward RL (GRPO/PPO).

**Key results (verified):** Qwen2.5-Math-7B AIME 2024 pass@1 12.9% → 40.2% (~211%); ~76.5% average improvement across AIME 2024, AMC, MATH-500.

**Why it matters for RSI:** Self-improvement without labels at deployment time; turns test-time scaling (majority vote) into weights.

**Limitations:** Bounded roughly by the initial model's maj@N; can reinforce confident errors; risk of test-set adaptation confounds evaluation.

**Connections:** Sharpening (amortizing majority vote), R-Zero pseudo-labels, Huang et al. 2022 "LLMs can self-improve", TTT.

**Questions:** When does majority-vote reward produce collapse vs. improvement? Interaction with entropy?
