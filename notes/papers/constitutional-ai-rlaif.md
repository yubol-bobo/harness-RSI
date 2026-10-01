# Constitutional AI (Bai et al. 2022) + RLAIF vs. RLHF (Lee et al. 2023)

- **Authors:** Yuntao Bai et al. (Anthropic) / Harrison Lee et al. (Google)
- **Year / Venue:** 2022 arXiv / 2023 arXiv, ICML 2024
- **Links:** https://arxiv.org/abs/2212.08073 · https://arxiv.org/abs/2309.00267

**TL;DR:** Replace human harmlessness/preference labels with AI feedback guided by a written set of principles; AI feedback performs comparably to human feedback.

**Problem:** Human preference labeling is expensive, slow, and exposes labelers to harmful content.

**Method:** CAI — SL stage: model critiques and revises its own responses per constitutional principles, SFT on revisions; RL stage: AI-labeled comparisons train a preference model → RL ("RLAIF"). Lee et al.: systematic RLAIF vs RLHF comparison; "direct RLAIF" uses LLM scores as reward without training an RM.

**Key results (verified, Lee et al.):** RLAIF ≈ RLHF on summarization and helpful dialogue (both strongly preferred over SFT; head-to-head equal); harmless rate 88% (RLAIF) vs 76% (RLHF); works with a labeler the same size as, or the same checkpoint as, the policy; d-RLAIF beats canonical RLAIF.

**Why it matters for RSI:** Removes humans from the labeling loop — a precondition for self-rewarding. Human input remains as the *constitution* (an anchor/spec).

**Limitations:** Judge biases propagate; no external ground truth; constitution quality matters.

**Connections:** Self-Rewarding, Meta-Rewarding, weak-to-strong (scalable oversight).

**Questions:** Does self-labeling with the same checkpoint keep working over many rounds?
