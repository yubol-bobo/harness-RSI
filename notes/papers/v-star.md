# V-STaR: Training Verifiers for Self-Taught Reasoners

- **Authors:** Arian Hosseini, Xingdi Yuan, Nikolay Malkin, Aaron Courville, Alessandro Sordoni, Rishabh Agarwal
- **Year / Venue:** 2024 / COLM 2024
- **Link:** https://arxiv.org/abs/2402.06457

**TL;DR:** Keep STaR's incorrect samples and use correct-vs-incorrect pairs to DPO-train a verifier; use it for best-of-k at test time; iterate.

**Problem:** STaR discards most samples (the failures), wasting signal.

**Method:** Each iteration: generator SFT on correct samples; verifier trained with DPO on (correct ≻ incorrect) pairs collected across iterations; inference = best-of-k ranked by verifier.

**Key results (verified):** 4%–17% test-accuracy improvement over existing self-improvement and verification approaches on code generation and math reasoning with LLaMA-2 models.

**Why it matters for RSI:** Explicitly grows the *generation–verification gap* from the model's own failures.

**Limitations:** Still needs ground-truth labels for training; verifier used at inference (cost); verifier distribution tied to generator.

**Connections:** STaR, Mind the Gap (Song et al.), process/outcome reward models, Meta-Rewarding (improving the judge).

**Questions:** Can the verifier's judgments be fed back as RL reward without hacking?
