# Self-Rewarding Language Models

- **Authors:** Weizhe Yuan, Richard Yuanzhe Pang, Kyunghyun Cho, Xian Li, Sainbayar Sukhbaatar, Jing Xu, Jason Weston (Meta, NYU)
- **Year / Venue:** 2024 / ICML 2024
- **Link:** https://arxiv.org/abs/2401.10020

**TL;DR:** One model is both policy and reward model (via LLM-as-a-Judge); iterative DPO on self-judged pairs improves both instruction following and judging.

**Problem:** Fixed reward models trained from human preferences cap alignment at human level and don't improve during training.

**Method:** Seed SFT on instruction data + evaluation (judge) data. Each iteration: generate prompts, sample N responses, score with an additive 5-point rubric prompt by the same model, form (best, worst) pairs, train $M_{t+1}$ from $M_t$ with DPO.

**Key results (verified):** Llama-2-70B after three iterations outperforms Claude 2, Gemini Pro, and GPT-4 0613 on the AlpacaEval 2.0 leaderboard; judge quality also improves. (Exact win-rate ~20.4% **[unverified]**.)

**Why it matters for RSI:** First prominent demo that the *reward signal itself* can co-improve with the policy.

**Limitations:** Only 3 iterations; length inflation; possible reward hacking; judge saturates; evaluation by GPT-4-based leaderboards.

**Connections:** Meta-Rewarding, CAI/RLAIF, SPIN, Mind the Gap.

**Questions:** What bounds the number of productive iterations? How to detect judge-actor collusion?
