# Self-Improvement in Language Models: The Sharpening Mechanism

- **Authors:** Audrey Huang, Adam Block, Dylan J. Foster, Dhruv Rohatgi, Cyril Zhang, Max Simchowitz, Jordan T. Ash, Akshay Krishnamurthy
- **Year / Venue:** 2024 (arXiv) / ICLR 2025
- **Link:** https://arxiv.org/abs/2412.01951

**TL;DR:** Self-improvement = using the model as its own verifier to sharpen probability mass onto high-quality sequences, amortizing inference-time search into the weights.

**Method:** Statistical framework with sample access to a base policy; self-reward e.g. $\log\pi_{\text{base}}(y|x)$; two algorithm families: SFT-sharpening (best-of-N under self-reward then SFT) and RLHF-sharpening (online RL against self-reward).

**Key results (verified):** SFT-sharpening is minimax optimal when the base model has sufficient coverage; RLHF-sharpening can beat it by exploiting online exploration, bypassing coverage. Coverage coefficient form $\mathbb{E}_x[1/\pi_{\text{base}}(y^\star|x)]$ **[unverified exact form]**.

**Why it matters for RSI:** The clearest theoretical account of what self-improvement can and can't do without new external information: it concentrates, it does not create — except via exploration.

**Limitations:** Self-reward = likelihood is a narrow notion of quality; theory under idealized sampling oracles.

**Connections:** Yue et al. pass@k debate, TTRL (majority vote sharpening), Mind the Gap, ReST-EM.

**Questions:** What's the analog for verifiers stronger than likelihood? Can exploration provably expand support?
