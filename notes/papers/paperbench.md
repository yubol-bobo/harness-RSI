# PaperBench: Evaluating AI's Ability to Replicate AI Research

- **Who / when:** Giulio Starace et al. (OpenAI Preparedness). arXiv [2504.01848](https://arxiv.org/abs/2504.01848), Apr 2025. ICML 2025. Code in openai/frontier-evals.
- **One-line:** can an agent replicate a top ML paper **from its text alone**: understand it, write the codebase, run the experiments?

## Design
- **20** ICML 2024 Spotlight/Oral papers.
- Hierarchical **rubrics co-developed with the original authors**: **8,316** individually gradable leaf requirements in total.
- Graded by an **LLM judge**. **JudgeEval** measures the judge against human grading.
- **PaperBench Code-Dev**: a lighter variant that grades code development only (no execution).

## Results
- At launch, the best was **Claude 3.5 Sonnet (new) ≈ 21%** average replication score (simple agent scaffold). It did **not** beat ML PhDs; human baseline ~41% on a subset after 48 h [unverified exact].
- Third-party leaderboard (sampled Aug 2026): Qwen3.8 Max ~93%, GPT-5.6 Sol ~90.5%, Claude Fable 5 ~88.8% [aggregator, unverified]. The benchmark is near saturation.
- OpenAI uses PaperBench in its Preparedness "AI self-improvement" evals.

## Caveats
- LLM-judge errors. Rubrics reward following the paper, not discovery.
- Contamination risk grows as the papers age, since public reimplementations appear.

## Why it matters
Replication is a prerequisite for research (Anthropic's framing of CORE-Bench). It is also a **verification primitive**: an independent agent that can't replicate your AI-written paper is a red flag.
