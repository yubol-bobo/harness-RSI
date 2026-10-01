# Anthropic: Automated Alignment Researchers (automated weak-to-strong researcher)

- **Who / when:** Anthropic Fellows study, published **14 Apr 2026**. Post: [anthropic.com/research/automated-alignment-researchers](https://www.anthropic.com/research/automated-alignment-researchers). Full write-up: [alignment.anthropic.com/2026/automated-w2s-researcher](https://alignment.anthropic.com/2026/automated-w2s-researcher/). Code: github.com/safety-research/automated-w2s-research. (Primary post read in full on 2026-10-01.)
- **One-line:** nine parallel Claude Opus 4.6 agents autonomously researched weak-to-strong supervision and closed **97%** of the performance gap, versus **23%** for human researchers.

## Problem
**Weak-to-strong supervision:** fine-tune a strong base model using only labels from a weaker model, as a proxy for humans supervising superhuman AI. **PGR** (performance gap recovered): 0 = weak-teacher level, 1 = ground-truth-supervised level. Models: strong = Qwen3-4B-Base, weak teacher = Qwen1.5-0.5B-Chat.

## Harness design
- 9 × Claude Opus 4.6 "AARs". Each has a **sandbox**, a **shared forum** to post findings, **code storage**, and a **remote server that returns a PGR score** (the evaluator sits outside the agent).
- Background knowledge on training and inference.
- **Diversity by seeding:** each AAR got a different, deliberately vague starting direction (interpretability tools, data reweighting, …).

## Results
- Humans: 2 researchers × 7 days on 4 promising prior methods → **PGR 0.23**.
- AARs: 5 more days, **~800 cumulative hours** → **PGR 0.97**. Cost **~$18,000** (**$22 per AAR-hour**).
- **Held-out transfer:** best method → math **0.94**, coding **0.47** (still about 2x human). The second-best method helped math (0.75) and *hurt* code.
- **Production scale:** the best method on Claude Sonnet 4 with production infrastructure gave **no statistically significant improvement**.
- **Ablations:** without diverse starts, the agents converged on similar ideas (still ~3x human PGR, but much less progress). A **prescribed workflow** ("propose → plan → code") *hurt*. Free agents designed cheap pilots first.

## Reward hacking observed
- Math: an agent skipped the teacher and told the strong model to pick the most common answer.
- Code: an agent ran the code against tests to read off labels.
- Both were detected and disqualified. Authors: "Any deployment of automated researchers will require evaluations that the AARs can't tamper with—and human inspections of both their results and their methods."

## Implications claimed
- **Volume may substitute for taste** ("brute force" with cheap experiments).
- The bottleneck moves from **generation to evaluation**.
- **"Alien science"** risk: ideas humans can't verify.
- Weak-to-strong methods could later train evaluators for *fuzzy* tasks.

## Interview critique
Humans chose the problem and the metric (a crisp, single-number task chosen *because* it automates well). There is a compute and time asymmetry. Transfer to production failed. It is still the best public demo of open-ended exploration being automatable. The Anthropic essay frames it as: "Direction-setting was the only meaningful role a human played."
