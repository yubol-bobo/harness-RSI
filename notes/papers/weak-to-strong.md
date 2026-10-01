# Weak-to-Strong Generalization: Eliciting Strong Capabilities With Weak Supervision

- **Authors:** Collin Burns, Pavel Izmailov, Jan Hendrik Kirchner, Bowen Baker, Leo Gao, Leopold Aschenbrenner, Yining Chen, Adrien Ecoffet, Manas Joglekar, Jan Leike, Ilya Sutskever, Jeff Wu (OpenAI)
- **Year / Venue:** 2023 (arXiv) / ICML 2024
- **Link:** https://arxiv.org/abs/2312.09390

**TL;DR:** Strong models fine-tuned on weak-model labels outperform their supervisors; simple methods recover much of the gap.

**Method:** Metric PGR = (weak→strong − weak)/(strong ceiling − weak). Tasks: NLP classification, chess puzzles, ChatGPT reward modeling. Methods: auxiliary confidence loss, bootstrapping via intermediate models, unsupervised fine-tuning.

**Key results (verified):** GPT-2-level supervisor → GPT-4 on NLP with confidence loss recovers ~80% of the gap; inconsistent across settings, poor for reward modeling.

**Why it matters for RSI:** A self-improving model's supervisor is its weaker past self; also the analogy for humans supervising superhuman models (scalable oversight).

**Limitations:** Analogy imperfect (imitating weak-model errors vs. human errors); PGR noisy.

**Connections:** Self-Rewarding, CAI, Weng's Autodata (weak/strong solvers).

**Questions:** Does iterating weak-to-strong compound or saturate?
