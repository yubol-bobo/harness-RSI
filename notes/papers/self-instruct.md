# Self-Instruct: Aligning Language Models with Self-Generated Instructions

- **Authors:** Yizhong Wang, Yeganeh Kordi, Swaroop Mishra, Alisa Liu, Noah A. Smith, Daniel Khashabi, Hannaneh Hajishirzi
- **Year / Venue:** 2022 (arXiv) / ACL 2023
- **Link:** https://arxiv.org/abs/2212.10560

**TL;DR:** A model bootstraps instruction-tuning data from 175 seed tasks by generating instructions, inputs and outputs, filtering, and fine-tuning itself.

**Problem:** Human-written instruction data is limited in quantity and diversity.

**Method:** Iterative generation of new instructions from in-context seed examples; classification vs. generation task handling; heuristic filters (e.g., ROUGE-L novelty, invalid outputs); fine-tune the same model.

**Key results (verified):** ~52K instructions / 82K instances; vanilla GPT-3 +33% absolute on Super-NaturalInstructions, on par with InstructGPT-001; human eval on novel expert tasks leaves a 5% gap to InstructGPT-001.

**Why it matters for RSI:** Origin of the synthetic-data era (Alpaca etc.). Note: Alpaca used a *stronger* teacher → distillation, not self-improvement.

**Limitations:** Noisy data (a sizable fraction of outputs incorrect **[unverified %]**); heuristic filtering; inherits model biases.

**Connections:** Instruction back-translation, Self-Rewarding (prompt generation), model collapse.

**Questions:** How many self-instruct rounds before diversity collapses?
