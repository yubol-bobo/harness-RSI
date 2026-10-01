# Agent Workflow Memory (AWM)

- **Authors:** Zora Zhiruo Wang, Jiayuan Mao, Daniel Fried, Graham Neubig
- **Year / Venue:** 2024 (arXiv Sept 2024) / ICML 2025
- **Link:** https://arxiv.org/abs/2409.07429
- **Ladder level:** 2 (memory of reusable workflows)

## TL;DR
Induce commonly reused routines ("workflows") from past successful trajectories and selectively provide them to the agent; works offline (from training examples) and online (from the agent's own test-time experience).

## Problem
Web agents re-solve every task from scratch and fail on long-horizon tasks; humans reuse routines.

## Method
1. Collect trajectories (offline annotated, or online self-generated, judged by an LLM evaluator).
2. **Induce workflows:** LLM abstracts sub-routines with example-specific values replaced by placeholders.
3. Add workflows to agent memory (context); in online mode, the memory grows as the agent solves test queries in a stream; workflows can build on earlier workflows.

## Key results (abstract)
- +24.6% and +51.1% relative success rate on Mind2Web and WebArena respectively, with fewer steps on WebArena.
- Online AWM generalizes in cross-task/website/domain evaluations, beating baselines by 8.9 to 14.0 absolute points as train–test gaps widen.

## Why it matters for RSI
Online, label-light persistent improvement with a structured memory unit (workflow) — a "procedural memory" level between insights (ExpeL) and code skills (Voyager).

## Limitations
- Online mode depends on an LLM judge (false positives become bad workflows).
- Workflows are text guidance, not executable/verified.

## Connections
Voyager, ExpeL, ACE, Dynamic Cheatsheet, AFlow/ADAS (workflow as architecture vs workflow as memory).

## Questions to think about
1. Workflow-as-memory vs workflow-as-architecture (AFlow): when is each preferable?
2. How to cheaply validate a newly induced workflow before adding it?
