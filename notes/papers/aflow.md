# AFlow — Automating Agentic Workflow Generation

- **Authors:** Jiayi Zhang, et al. (MetaGPT / DeepWisdom team and collaborators) **[full list: see paper]**
- **Year / Venue:** 2024 (arXiv Oct 2024) / ICLR 2025
- **Link:** https://arxiv.org/abs/2410.10762
- **Ladder level:** 3 (workflow graph as code)

## TL;DR
Represent workflows as code graphs of LLM-invoking nodes and use a variant of Monte Carlo Tree Search, with LLM-driven expansion and execution feedback, to discover better workflows automatically.

## Problem
Workflow design is manual; earlier automated methods (ADAS) search inefficiently.

## Method
- Workflow $W=(N,E)$; nodes have (model, prompt, temperature, output format); edges are code (conditionals, loops). Predefined **operators** (Generate, Format, Review & Revise, Ensemble, Test, Programmer, ...) compress the space.
- Objective $W^*=\arg\max_{W}G(W,T)$.
- Loop (Weng):
  1. Initialize $W_0$ from a template.
  2. **Select** node via soft mixture of score-based probability and uniform exploration.
  3. **Expand:** LLM modifies the workflow code conditioned on parent performance and prior modification experience (what worked/failed).
  4. **Execute & evaluate** (multiple runs for variance).
  5. **Backpropagate** experience; keep improved workflows.
  6. Stop at top-k plateau or budget.

## Key results (abstract)
- 5.7% average improvement over SOTA baselines across six benchmarks (QA, code, math).
- Smaller models with AFlow workflows outperform GPT-4o on specific tasks at 4.55% of its inference cost (dollars).
- Outperforms ADAS (Weng's figure).

## Why it matters for RSI
Shows structured search (tree + experience) beats flat archives for workflow optimization; demonstrates "harness can substitute for model scale" on narrow tasks.

## Limitations
- Benchmark-specific workflows; requires a numeric evaluator; does not touch tools/memory/permissions.
- Operator set is hand-designed.

## Connections
ADAS, EvoAgentX (framework integrating AFlow-like optimizers), GEPA/MIPRO (inside-node prompt optimization), AlphaEvolve-style search.

## Questions to think about
1. What's the role of the operator vocabulary? Trade-off between expressivity and search efficiency.
2. How would you make AFlow robust to evaluation noise?
