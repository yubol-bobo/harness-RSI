# Beyond Human Data: Scaling Self-Training for Problem-Solving with Language Models (ReST-EM)

- **Authors:** Avi Singh, John D. Co-Reyes, Rishabh Agarwal, et al. (Google DeepMind)
- **Year / Venue:** 2023 (arXiv) / TMLR 2024
- **Link:** https://arxiv.org/abs/2312.06585

**TL;DR:** Self-training with binary correctness feedback, framed as expectation–maximization: sample + filter (E-step), fine-tune (M-step), repeat; beats training on human solutions.

**Problem:** Human-written solutions are scarce for math/code; can model-generated data with verifiable feedback substitute?

**Method:** Maximize $\log p(O{=}1\mid x)$ via ELBO. E-step: $q^{t+1}\propto r(x,y)\,\pi_{\theta_t}(y\mid x)$ (sample, keep correct). M-step: $\arg\max_\theta \mathbb{E}_q[r\log\pi_\theta(y\mid x)]$. Builds on ReST (Gulcehre et al. 2023, Grow/Improve). Fine-tunes from base each iteration **[unverified]**.

**Key results (verified via summaries):** On MATH and APPS with PaLM-2, outperforms SFT on human data; benefit grows with model size; multiple iterations help MATH but overfit on APPS; improves pass@1 more than pass@k.

**Why it matters for RSI:** Clean theory + scalable recipe (decouples data collection from optimization). Also used as the outer-loop RL in SEAL.

**Limitations:** Requires verifiable reward; few-iteration plateaus/overfitting; off-policy.

**Connections:** STaR, RFT, RLVR/GRPO, SEAL, sharpening.

**Questions:** Why does pass@k not improve — is this the sharpening ceiling?
