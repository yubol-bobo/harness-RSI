# SEAL: Self-Adapting Language Models

- **Authors:** Adam Zweiger, Jyothish Pari, Han Guo, Ekin Akyürek, Yoon Kim, Pulkit Agrawal (MIT)
- **Year / Venue:** 2025 / NeurIPS 2025
- **Link:** https://arxiv.org/abs/2506.10943

**TL;DR:** The model generates its own fine-tuning data and update directives ("self-edits"); RL trains it to produce self-edits that improve downstream performance after fine-tuning.

**Problem:** Models adapt to new knowledge/tasks using data "as is"; they don't decide how to restructure it for learning.

**Method:** Inner loop: SFT (LoRA) on self-edit SE ~ π_θ(·|context). Outer loop: reward = downstream improvement of the updated model; optimized with ReST-EM (filtered behavior cloning) **[algorithm choice from memory]**. Knowledge incorporation (self-edits = implications of a passage) and few-shot ARC (self-edits = augmentations + hyperparameters).

**Key results (verified):** Qwen2.5-7B SQuAD no-context QA: 33.5% (fine-tune on raw passage) → 47.0%, beating GPT-4.1-generated synthetic data (46.3%). ARC subset: RL-trained self-edits beat ICL and untrained self-edits (exact % **[unverified]**).

**Why it matters for RSI:** The model optimizes its *own learning procedure* — a model-level analog of harness self-modification ("learning to learn" via data generation).

**Limitations:** Catastrophic forgetting with sequential edits; every reward needs a fine-tune + eval (expensive); needs downstream eval tasks paired with contexts.

**Connections:** ReST-EM, TTT, meta-learning (MAML), Self-Instruct, continual learning.

**Questions:** Can self-edits be evaluated by a cheaper proxy? How to compose thousands of edits without forgetting?
