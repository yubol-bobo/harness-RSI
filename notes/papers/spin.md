# SPIN: Self-Play Fine-Tuning Converts Weak Language Models to Strong Language Models

- **Authors:** Zixiang Chen, Yihe Deng, Huizhuo Yuan, Kaixuan Ji, Quanquan Gu (UCLA)
- **Year / Venue:** 2024 / ICML 2024
- **Link:** https://arxiv.org/abs/2401.01335

**TL;DR:** A GAN-like self-play game: the new model learns to distinguish human SFT responses from its previous iterate's responses; loss is DPO-like with human as chosen, self as rejected.

**Problem:** Getting more out of an SFT dataset without new human/AI preference labels.

**Method:** $\mathcal{L}=\mathbb{E}\big[\ell\big(\lambda\log\frac{p_\theta(y|x)}{p_{\theta_t}(y|x)}-\lambda\log\frac{p_\theta(y'|x)}{p_{\theta_t}(y'|x)}\big)\big]$, $y\sim p_{\text{data}}$, $y'\sim p_{\theta_t}$, $\ell(t)=\log(1+e^{-t})$. Iterate with the new model as opponent. Theory: global optimum iff $p_\theta=p_{\text{data}}$.

**Key results (verified):** zephyr-7b-sft-full: HF Open LLM Leaderboard average 58.14 → 63.16 (iter 3), >10% gains on GSM8K and TruthfulQA; MT-Bench 5.94 → 6.78.

**Why it matters for RSI:** Shows self-play as a data-efficiency tool; also a clear example of a *bounded* loop (cannot exceed $p_{\text{data}}$).

**Limitations:** Ceiling at human data quality; gains diminish across iterations; leaderboard metrics.

**Connections:** DPO, GANs, SPPO (Nash self-play), Self-Rewarding.

**Questions:** Is SPIN's improvement mostly fixing SFT under-fitting?
