# STaR: Bootstrapping Reasoning With Reasoning

- **Authors:** Eric Zelikman, Yuhuai Wu, Jesse Mu, Noah D. Goodman
- **Year / Venue:** 2022 / NeurIPS 2022
- **Link:** https://arxiv.org/abs/2203.14465

**TL;DR:** A model bootstraps chain-of-thought ability by fine-tuning on its own rationales that reach the correct answer, plus "rationalizations" generated with the answer given as a hint.

**Problem:** Rationale-annotated data is expensive; few-shot CoT is weak on small models.

**Method:** Loop: (1) few-shot generate rationale + answer; (2) keep if answer correct; (3) for failures, give the correct answer as a hint and keep hint-conditioned rationales that reach it (trained *without* the hint); (4) fine-tune; repeat. Gradient view: $\nabla J=\sum_i\mathbb{E}[\mathbb{1}(\hat y_i=y_i)\nabla\log p_M(\hat y_i,\hat r_i\mid x_i)]$ — filtered SFT ≈ policy gradient with binary reward.

**Key results (verified):** CommonsenseQA 72.5% with GPT-J 6B, comparable to a ~30x larger fine-tuned GPT-3 (73.0%); +35.9% over few-shot and +12.5% over direct-answer fine-tuning. GSM8K 5.8% → 10.7%.

**Why it matters for RSI:** Canonical model-level self-improvement loop; template for ReST-EM, RFT, RLVR. Rationalization is an early fix for "no gradient from unsolved problems."

**Limitations:** Requires labeled answers; correct answers with wrong rationales get reinforced (esp. multiple choice); needs some initial few-shot ability. Restarting from the base model each iteration **[unverified detail]**.

**Connections:** ReST-EM (EM formalization), V-STaR (use failures for a verifier), Quiet-STaR (generalize to arbitrary text), R1-Zero (on-policy RL version).

**Questions:** Is rationalization off-policy bias harmful at scale? How does it compare to GRPO with hints?
