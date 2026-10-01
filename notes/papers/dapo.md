# DAPO: An Open-Source LLM Reinforcement Learning System at Scale

- **Authors:** Qiying Yu et al. (ByteDance Seed, Tsinghua AIR, and collaborators)
- **Year:** 2025 (arXiv March 2025); NeurIPS 2025
- **Link:** https://arxiv.org/abs/2503.14476 · code built on verl ([card](verl-hybridflow.md))

## TL;DR
**D**ecoupled Clip and **D**ynamic s**A**mpling **P**olicy **O**ptimization: four practical fixes to GRPO-style RL that make long-CoT reasoning RL work at scale, fully open (code, data, logs).

## Method (the four techniques)
1. **Clip-Higher:** decouple the PPO clip range into ε_low and a larger ε_high, so low-probability tokens can grow; prevents **entropy collapse** (the policy becoming deterministic too early).
2. **Dynamic Sampling:** filter out prompts whose sampled group is all-correct or all-wrong. With group-relative advantages these give zero gradient, so they waste the batch; keep sampling until the batch is full of informative prompts.
3. **Token-level policy-gradient loss:** average the loss over tokens rather than per sample first, so long responses aren't under-weighted (and long bad patterns are penalized properly).
4. **Overlong reward shaping:** soft penalty / masking for truncated responses, reducing reward noise from length limits.

## Results (verified from abstract)
- **50 points on AIME 2024** with Qwen2.5-32B base, beating DeepSeek-R1-Zero-Qwen-32B (47) with about **50% of the training steps**.
- A naive GRPO baseline in their setup reached ~30.

## Relevance to harness / RSI
- RL on self-generated rollouts is the main weight-level self-improvement engine; DAPO is the open recipe.
- **Clip-Higher = a fix for diversity collapse** inside the loop (Weng's bottleneck #4).
- **Overlong shaping = reward design**: a small example of how proxies (truncated → wrong) create noise and Goodhart effects.
- Used as the base RL algorithm for MemAgent (multi-conversation extension).

## Questions to prepare
- Derive the GRPO advantage and show why all-correct groups give zero gradient.
- Why does entropy collapse hurt exploration, and why does raising only the upper clip help?
- Sequence-level vs. token-level loss averaging: what bias does each introduce?
- How would you adapt dynamic sampling to multi-turn agent tasks where an episode is expensive?
