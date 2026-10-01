# OMNI: Open-endedness via Models of human Notions of Interestingness

- **Authors:** Jenny Zhang, Joel Lehman, Kenneth Stanley, Jeff Clune
- **Year:** 2023 (arXiv 2306.01711)
- **Venue:** ICLR 2024
- **Link:** https://arxiv.org/abs/2306.01711

## TL;DR
Use a foundation model as a **model of interestingness** to pick tasks that are both learnable and interesting, fixing the "infinitely many boring task variants" problem of learning-progress curricula.

## Method
Learning-progress-based auto-curriculum + FM filter that judges which tasks are interesting relative to those already mastered.

## Key results
Outperforms uniform sampling and learning-progress-only baselines in task-rich environments (qualitative; numbers not verified).

## Why it matters for RSI
Interestingness is the missing selection signal for open-ended self-improvement; lineage leads to OMNI-EPIC, ADAS, DGM, Hyperagents.

## Limitations
Interestingness inherits FM/human biases; evaluation in toy domains.

## Connections
AI-GAs, POET, Hughes et al. 2024, DGM.

## Questions
Can "interestingness" be gamed by a self-modifying agent the way benchmarks are?
