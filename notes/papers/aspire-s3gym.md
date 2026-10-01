# Aspire and S³Gym (Self-Developing Agents project, ByteDance Seed et al.)

- **Titles:** *Aspire: Can Models Self-Evolve from Vague Goals?* and *S³Gym: Can LLMs Turn Self-Testing and Self-Judging into Self-Improvement?*
- **Authors / affiliations:** ByteDance Seed with Singapore University of Technology and Design, M-A-P, TokenWave.AI and others (full author lists: see arXiv)
- **Year:** 2026 (arXiv, late Aug / Sep 2026), released together with [HarnessDev](harnessdev.md) under the banner "From Half-Loop to Closed-Loop RSI"
- **Links:** Aspire https://arxiv.org/abs/2608.31111 · S³Gym https://arxiv.org/abs/2608.31100 · project self-developing-agents.github.io

## TL;DR
- **Aspire:** give the agent only a vague natural-language capability goal (e.g., "become a better physicist"); keep the test tasks hidden; see whether it can turn the goal into data, training signals and updates (to **weights or harness**) that actually improve hidden-test performance.
- **S³Gym:** in seven text games, can an agent test itself, judge its own outcomes, and turn that into real improvement, when it **cannot see** the programmatic verifier's step rewards or final score?

## Method
- **Aspire:** unified interactive environment supporting both model-weight and agent-harness evolution. The agent chooses data and update methods, builds training/validation signals, and decides when to evaluate. Hidden, expert-authored evaluation set: **520 items over six goals**.
- **S³Gym:** three coupled capabilities: Self-Testing, Self-Judging, Self-Improvement. Self-judgments decide how experience is organized and reused; environment scores (hidden from the agent) measure actual performance. Compares three ways to use experience: **History-ICL** (raw history in context), **score-conditioned Summary Memory**, and **parameter Training**.

## Results (verified from abstracts)
- **Aspire:** vague goals redirect effort toward *interpreting the goal*. Agents routinely complete training and harness-editing loops, but **weight-level gains are sparse and unstable**, and the **strongest evolved harness is still below the engineered Qwen-Agent reference**.
- **S³Gym:** improvement is **highly task-dependent and often fails to transfer**. Summaries help when experience compresses into reusable rules but often underperform raw history when success depends on precise state. Parameter training gives large gains on some tasks and **severe negative transfer** on others. "Recognizing successful actions is insufficient."

## Relevance to harness / RSI
- Directly tests the "closing the loop" step: the agent must build its *own evaluator* (Aspire's validation signals; S³Gym's self-judging). This is Weng's bottleneck #1 (weak and fuzzy evaluators) turned into a benchmark.
- S³Gym's hidden verifier is the "evaluator outside the loop" principle used as a measurement design.
- Both report that loops *run* but *gains don't reliably compound*: good evidence for a "soft, bottlenecked" view of near-term RSI.

## Questions to prepare
- How would you measure the "Goodhart gap" between the agent's self-built validation score and the hidden score across iterations?
- When should experience go into memory vs. weights? (S³Gym: depends on whether it compresses into rules.)
- What would make weight-level self-evolution in Aspire stable? (Data quality checks, held-out self-validation, smaller steps, rollback.)
