# Mind the Gap: Examining the Self-Improvement Capabilities of Large Language Models

- **Authors:** Yuda Song, Hanlin Zhang, Carson Eisenach, Sham Kakade, Dean Foster, Udaya Ghai
- **Year / Venue:** 2024 (arXiv) / ICLR 2025
- **Link:** https://arxiv.org/abs/2412.02674

**TL;DR:** Formalizes self-improvement (generate → self-verify → filter → distill) and identifies the generation–verification gap as the governing quantity; a variant scales monotonically with pretraining FLOPs.

**Method:** Define the gap as the utility improvement of verification-reweighted generations over raw generations; measure across model families, tasks, and verification methods; study iterative self-improvement.

**Key results (verified at abstract level):** A relative generation–verification gap scales monotonically with pretraining FLOPs. Further findings on when self-improvement fails (some tasks have ~no gap), saturation of iterative improvement, and verification method choice **[details unverified]**.

**Why it matters for RSI:** Gives the "fuel gauge" for any self-improvement loop; links scaling laws to RSI.

**Limitations:** Mostly best-of-N/filtering style self-improvement; limited to tasks with ground truth for measurement.

**Connections:** Sharpening, V-STaR, Meta-Rewarding, Self-Rewarding.

**Questions:** Does the gap shrink after self-improvement (consuming its own fuel)? How do tools/executors change it?
