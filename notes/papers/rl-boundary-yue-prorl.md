# Elicit vs. Expand: Yue et al. 2025 vs. ProRL 2025

- **Papers:** (1) "Does Reinforcement Learning Really Incentivize Reasoning Capacity in LLMs Beyond the Base Model?" — Yang Yue, Zhiqi Chen, Rui Lu, Andrew Zhao, Zhaokai Wang, Shiji Song, Gao Huang. (2) "ProRL: Prolonged Reinforcement Learning Expands Reasoning Boundaries in LLMs" — Mingjie Liu, Shizhe Diao, Ximing Lu, Jian Hu, Xin Dong, Yejin Choi, Jan Kautz, Yi Dong (NVIDIA).
- **Year / Venue:** 2025 / both NeurIPS 2025 (Yue et al.: Best Paper runner-up)
- **Links:** https://arxiv.org/abs/2504.13837 · https://arxiv.org/abs/2505.24864

**TL;DR:** Yue: RLVR improves pass@1 but base models match/beat RL models at large k → RL elicits, doesn't expand. ProRL: long, stabilized, diverse RL beats base across pass@k, even where base fails at any k.

**Method:** Unbiased pass@k with large k (up to 256+) across math, code, visual reasoning (Yue). ProRL: KL control, periodic reference-policy resets, diverse task suite, long training.

**Key results (verified):** Yue: RLVR improves sampling efficiency; at large k base models solve more problems; RL narrows exploration. ProRL: gains across pass@k, including tasks the base never solves; boundary gains correlate with base weakness and training length.

**Why it matters for RSI:** Determines whether verifier-driven self-improvement is a ceiling-bounded "sharpener" or a genuine capability engine.

**Limitations:** Large-k pass@k can credit guessing; different models/tasks/training lengths make the papers hard to compare directly.

**Connections:** Sharpening, Mind the Gap, Absolute Zero (new tasks to expand the support).

**Questions:** What's the right metric for "new capability"? Does task generation break the ceiling?
