# HarnessDev: Can LLMs Create and Evolve Their Own Agent Harness?

- **Authors:** Yuhao Wu et al. (ByteDance Seed, Singapore University of Technology and Design, Georgia Tech, and collaborators; part of the "Self-Developing Agents" project with TokenWave.AI / M-A-P)
- **Year:** 2026 (arXiv, submitted 2026-09-01)
- **Link:** https://arxiv.org/abs/2609.01437 · project: self-developing-agents.github.io
- **Sibling papers:** [Aspire & S³Gym](aspire-s3gym.md)

## TL;DR
A benchmark that scores an LLM on **the harness it builds**, not on the tasks it completes. The model must create a runnable agent harness from a weak seed, then evolve it from execution feedback; the harness is then run on held-out downstream benchmarks.

## Method
- **Creation phase:** start from a minimal seed harness and a small number of example cases; build a complete execution system (tools, loop, context handling, etc.).
- **Evolution phase:** start from your own created harness and revise it iteratively using downstream execution feedback, aiming to improve benchmark performance.
- **Scale:** six creator LLMs, four domains (code, search & research, writing, ML experimentation), five downstream benchmarks, **2,207 held-out instances**.
- **Reference points:** mature human-engineered harnesses for each domain.

## Results (verified from abstract-level summaries)
- Generated harnesses **stay well behind** mature human-engineered references on **code** and **search/research**.
- They **match or exceed** the chosen references on **writing** and **ML experimentation**.
- Evolution yields gains, but they are **unstable**, **transfer only partially** to held-out tasks, and **depend heavily on which model runs the harness**.
- (secondary summary, verify in paper) search gap example: 52.4 vs. 92.2 on BrowseComp.

## Relevance to harness / RSI
- Makes "harness-level RSI" (Weng 2026: Meta-Harness, Self-Harness, AHE) into a standardized benchmark from a lab that is likely interviewing you.
- Separates *creation skill* from *improvement skill*: the second is the recursive part.
- Partial transfer and model-dependence are classic **regressional Goodhart** and **overfitting-to-the-executor** signals: the core challenge of making self-improvement real.
- Safety angle: when the harness is the object being evolved, permission and evaluator code must be outside the editable surface (see [note 08](../08-safety-and-theory-of-rsi.md)).

## Questions to prepare
- Why might model-built harnesses lag on code and search but not on writing and ML experimentation? (Hypothesis: code/search harnesses encode lots of tacit engineering: sandboxing, retries, retrieval, caching, test running.)
- How would you make evolution gains transfer? (Multi-model, multi-domain acceptance gates; evidence-driven edits as in AHE; replication.)
- Is the evolving harness ever able to touch its own evaluation pipeline? How would you test for evaluator tampering?
- Does model-dependence argue for model-specific harness diffs rather than one universal harness?
