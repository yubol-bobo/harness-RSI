# Model Collapse (Shumailov et al. 2024) + Accumulate vs. Replace (Gerstgrasser et al. 2024)

- **Authors:** Ilia Shumailov, Zakhar Shumaylov, Yiren Zhao, Nicolas Papernot, Ross Anderson, Yarin Gal / Matthias Gerstgrasser, Rylan Schaeffer, et al.
- **Year / Venue:** Nature 631 (July 2024) / 2024 (ICML 2024 workshop; COLM 2024 **[venue unverified]**)
- **Links:** https://doi.org/10.1038/s41586-024-07566-y · https://arxiv.org/abs/2404.01413

**TL;DR:** Recursively training on model-generated data (replacing real data) loses distribution tails and degenerates; accumulating real + synthetic data keeps test error bounded.

**Method:** Shumailov: theory on discrete distributions/Gaussians, experiments with GMMs, VAEs, OPT-125m fine-tuned on WikiText-2 over generations. Gerstgrasser: linear-regression analysis + LM/diffusion/VAE experiments comparing replace vs. accumulate.

**Key results (verified):** Tails of the original distribution disappear ("irreversible defects"). Replace → test error increases with iterations; accumulate → finite upper bound independent of number of iterations (constant ~π²/6 factor **[unverified]**).

**Why it matters for RSI:** Every self-training loop is a recursive data loop; this sets the design rules: keep real data, accumulate, filter with external signals, maintain diversity.

**Limitations:** Shumailov's setup is "indiscriminate" use without filtering/verification — verified self-training (RLVR) is a different regime.

**Connections:** Anchored Self-Play, SPIN (human anchor), Self-Instruct.

**Questions:** Does verifier filtering provably prevent collapse? How does entropy collapse in RL relate?
