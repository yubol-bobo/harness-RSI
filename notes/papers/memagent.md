# MemAgent: Reshaping Long-Context LLM with Multi-Conv RL-based Memory Agent

- **Authors:** ByteDance Seed and Tsinghua University AIR (see arXiv for full list)
- **Year:** 2025 (arXiv July 2025); ICLR 2026
- **Link:** https://arxiv.org/abs/2507.02259

## TL;DR
Handle arbitrarily long inputs with a short context window by reading chunk by chunk and **overwriting a fixed-size memory** of ordinary tokens; the overwrite policy is **learned with RL**.

## Method
- Workflow: for each chunk, the model reads (memory + chunk) and writes a new memory; at the end it answers from the memory. Linear cost in document length.
- Training: extend **DAPO** to **multi-conversation** rollouts with independent contexts (each memory-update step is its own conversation); the final-answer reward is propagated to all memory-update conversations in the trajectory.

## Results (verified from abstract)
- Trained with 8K context on 32K-token documents; extrapolates to **3.5M-token QA with < 5% performance loss**.
- **95%+ on RULER at 512K**.

## Relevance to harness / RSI
- Context management is usually hand-written harness logic; here it becomes a **learned policy**. Weng predicts context engineering "will and should become a core part of intelligence".
- A template for RL over harness components: define the component as model calls, reward the end outcome.
- Safety angle: memory that accumulates can drift (e.g., *Your Agent May Misevolve* reports safety decay with memory accumulation), so learned memory needs safety evaluation over time.

## Questions to prepare
- Why use overwrite instead of append? (Bounded cost; forces compression.) What is lost?
- How is credit assigned across many memory-update conversations with only a final reward?
- Could the same multi-conversation RL train other harness components (planning, tool selection, sub-agent delegation)?
