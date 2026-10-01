# DeepSeek-R1 / R1-Zero: Incentivizing Reasoning via Reinforcement Learning

- **Authors:** DeepSeek-AI
- **Year / Venue:** 2025 / arXiv; Nature (Sept 2025)
- **Link:** https://arxiv.org/abs/2501.12948

**TL;DR:** Pure RL with rule-based verifiable rewards from a base model (no SFT) produces long chain-of-thought reasoning with emergent self-verification.

**Problem:** Does reasoning require supervised CoT data?

**Method:** GRPO (group-normalized advantages, no critic) on DeepSeek-V3-Base with accuracy + format rewards. R1 adds cold-start SFT, multi-stage RL, and distillation.

**Key results (verified):** R1-Zero AIME 2024 pass@1 15.6% → 71.0% (arXiv), 77.9% (Nature version); 86.7% with majority voting.

**Why it matters for RSI:** Self-generated rollouts + external checker = the dominant modern self-improvement recipe (RLVR); "aha moment" shows emergent self-correction.

**Limitations:** R1-Zero readability/language mixing; only verifiable domains; debate whether it expands or elicits (Yue et al. vs ProRL).

**Connections:** STaR/ReST-EM (offline version), TTRL, Absolute Zero, sharpening.

**Questions:** How much of the gain is format/length elicitation vs. new capability?
