# Meta-Rewarding Language Models: Self-Improving Alignment with LLM-as-a-Meta-Judge

- **Authors:** Tianhao Wu, Weizhe Yuan, Olga Golovneva, Jing Xu, Yuandong Tian, Jiantao Jiao, Jason Weston, Sainbayar Sukhbaatar
- **Year / Venue:** 2024 (arXiv) / EMNLP 2025
- **Link:** https://arxiv.org/abs/2407.19594

**TL;DR:** Adds a meta-judge role: the model judges its own judgments, producing preference pairs that train the judge, so judging ability keeps improving with the actor.

**Problem:** In Self-Rewarding, actor improves but judge saturates quickly.

**Method:** Roles actor / judge / meta-judge, all the same model. Actor pairs from judge scores; judge pairs from meta-judge comparisons of judgments; DPO on both; length-control mechanism for actor pairs.

**Key results (verified):** Llama-3-8B-Instruct: AlpacaEval 2 length-controlled win rate 22.9% → 39.4%; Arena-Hard 20.6% → 29.1%; no human labels.

**Why it matters for RSI:** Recursive improvement of the *evaluator*, not just the policy — a step toward keeping the generation–verification gap open.

**Limitations:** Few iterations; meta-judge positional/self biases; LLM-judged benchmarks.

**Connections:** Self-Rewarding, V-STaR, EvoLM (rubric co-evolution).

**Questions:** Is there a fixed point where meta-judging stops helping? Infinite regress of judges?
