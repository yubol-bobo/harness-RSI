# MLE-bench: Evaluating Machine Learning Agents on Machine Learning Engineering

- **Who / when:** Jun Shern Chan et al. (OpenAI). arXiv [2410.07095](https://arxiv.org/abs/2410.07095), Oct 2024. ICLR 2025. Repo: github.com/openai/mle-bench.
- **One-line:** **75 offline Kaggle competitions**. The agent must train models, prepare data, and submit predictions, graded against the real Kaggle leaderboards.

## Design
- Each competition: description, dataset, local grading script, and human leaderboard for medal thresholds.
- Metric: % of competitions where the agent earns a **medal** (bronze or better). Also above-median rate.
- Includes **resource-scaling** (more attempts / more time help) and **contamination** analyses.
- A low-complexity "Lite" subset of 22 competitions is widely used [count unverified].

## Results
- Paper: **o1-preview + AIDE scaffold ≥ bronze in 16.9%** of competitions (pass@1).
- 2025–26 agent papers: ~40–44% medals on the full set (e.g. FM Agent 43.6%, Operand Quant 39.6%). ~80% on Lite (MLEvolve, PiEvolve, Famou-Agent 2.0) [self-reported, unverified].
- OpenAI tracks "MLE-Bench Revised" in its Preparedness AI self-improvement suite.

## Caveats
- Kaggle solutions are public, so contamination is a risk.
- Medal thresholds vary by competition era. Scores depend heavily on compute and time.
- Classic Kaggle ML ≠ frontier LLM research.
- Note: Jun Shern Chan is also credited with data collection for Anthropic's "When AI builds itself" visuals.
