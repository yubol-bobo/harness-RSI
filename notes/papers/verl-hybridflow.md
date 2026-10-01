# HybridFlow: A Flexible and Efficient RLHF Framework (verl)

- **Authors:** Guangming Sheng et al. (ByteDance Seed / Doubao team and The University of Hong Kong)
- **Year:** 2024 arXiv; EuroSys 2025
- **Link:** https://arxiv.org/abs/2409.19256 · code https://github.com/volcengine/verl

## TL;DR
An RL-for-LLMs training framework that is both **flexible** (easy to express new RL dataflows like PPO, GRPO, ReMax) and **efficient** (high throughput at scale). Open-sourced as **verl**, now one of the most widely used RL libraries for LLM reasoning and agent training.

## Method
- **Hybrid programming model:** a *single controller* expresses the high-level RL dataflow (generate → score → compute advantages → update), while *multi-controller* workers do distributed computation. Control flow is decoupled from computation, so new algorithms are a few lines of driver code.
- **3D-HybridEngine:** reshards actor weights between the training layout and the generation (inference) layout with zero memory redundancy and less communication.
- Integrates with multiple training (FSDP, Megatron) and inference (vLLM, SGLang) backends.

## Results (verified from abstract)
- **1.5×–20×** training throughput over prior RLHF frameworks across model sizes and RL algorithms.

## Relevance to harness / RSI
- Weight-level self-improvement is RL on self-generated experience; verl is the substrate (DAPO, ReTool, MemAgent all build on it).
- Agentic multi-turn RL turns the **rollout environment into a harness** (tools, sandboxes, timeouts, reward functions). Harness design choices in rollouts directly shape what the policy learns, and where it can reward-hack.

## Questions to prepare
- Why does RL for LLMs need resharding between training and generation? (Different parallelism layouts are optimal for each.)
- What changes for **multi-turn, tool-using** rollouts? (Async/variable-length episodes, environment latency, sandbox management, partial rollouts.)
- Where should reward computation live so the policy can't influence it? (Separate, sandboxed reward workers; read-only test data.)
