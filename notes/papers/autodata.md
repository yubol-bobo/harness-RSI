# Autodata: An agentic data scientist to create high quality synthetic data

- **Who / when:** Ilia Kulikov et al., Meta FAIR. arXiv [2606.25996](https://arxiv.org/abs/2606.25996), Jun 2026.
- **One-line:** an agent acting as a *data scientist* builds training and eval data at "just-right" difficulty. The data-scientist agent itself is then **meta-optimized**.

## Mechanism (per Weng and abstract summaries)
- The main agent orchestrates:
  - a **challenger** that proposes problems,
  - a **weak solver**,
  - a **strong solver**,
  - a **verifier/judge**.
- Keep items where **the strong solver succeeds and the weak solver fails**. This is a difficulty band that is learnable but not trivial.
- The challenger's prompt is updated iteratively from solver and verifier feedback.
- Practical instance: **Agentic Self-Instruct**. Domains: CS research tasks, legal reasoning, reasoning with mathematical objects.

## Results
- Beats classical synthetic-data baselines (matched **CoT Self-Instruct**). Meta-optimizing the data-scientist agent gives a further, larger lift (per abstract). Exact numbers not verified here.

## Weng's critique (important)
The synthesized tasks fine-tune **weak solvers, not the strong model**. If the loop cannot iteratively improve the strong model, it is "more like indirect distillation over a generated prompt distribution, with less RSI flavor."

## RSI reading
- Improver-improves-improver: **yes** (the meta-optimized data scientist).
- Does the improved artifact feed back into the improver? **Not shown.** To close the loop, train the strong model on Autodata output, then use it as the next data scientist.

## Interview hooks
- The "just right" difficulty filter is a curriculum (compare with Absolute Zero, the R-Zero challenger/solver setup, POET).
- Converting inference compute into data quality is a scaling lever.
