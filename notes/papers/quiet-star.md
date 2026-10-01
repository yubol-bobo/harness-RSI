# Quiet-STaR: Language Models Can Teach Themselves to Think Before Speaking

- **Authors:** Eric Zelikman, Georges Harik, Yijia Shao, Varuna Jayasiri, Nick Haber, Noah D. Goodman
- **Year / Venue:** 2024 / COLM 2024
- **Link:** https://arxiv.org/abs/2403.09629

**TL;DR:** Train a model to generate internal "thoughts" at every token of ordinary text, rewarding thoughts that improve prediction of the actual future text.

**Problem:** STaR needs curated QA; reasoning is implicit in all text.

**Method:** Parallel thought generation after each token (start/end-of-thought tokens), a learned mixing head interpolating post-thought and base predictions, REINFORCE on thoughts using the log-likelihood gain on future tokens ("teacher forcing" multiple tokens ahead).

**Key results (verified):** Mistral-7B continued-pretrained on OpenWebMath / C4: zero-shot GSM8K 5.9% → 10.9%, CommonsenseQA 36.3% → 47.2%, without task fine-tuning.

**Why it matters for RSI:** The signal is the data itself — no labels or judge — a self-supervised self-improvement objective that scales with pretraining corpora.

**Limitations:** Large compute overhead; modest absolute numbers; thoughts are not necessarily interpretable.

**Connections:** STaR; later "RL on pretraining data" / reasoning-in-pretraining lines; sharpening (likelihood as signal).

**Questions:** Does this scale to frontier pretraining? Does it expand or just sharpen?
