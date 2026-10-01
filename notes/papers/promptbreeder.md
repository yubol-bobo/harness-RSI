# Promptbreeder — Self-Referential Self-Improvement via Prompt Evolution

- **Authors:** Chrisantha Fernando, Dylan Banarse, Henryk Michalewski, Simon Osindero, Tim Rocktäschel (Google DeepMind)
- **Year / Venue:** 2023 / ICML 2024
- **Link:** https://arxiv.org/abs/2309.16797
- **Ladder level:** 1 (task prompts) with a self-referential level-5 twist (mutation prompts evolve)

## TL;DR
A genetic algorithm over prompts in which the instructions that *mutate* prompts are themselves evolved.

## Problem
Hand-crafted prompt strategies (CoT, Plan-and-Solve) are sub-optimal and domain-agnostic. Can an LLM evolve domain-specific prompts — and improve the way it improves them?

## Method
1. Inputs: problem description; seed sets of "thinking styles" and mutation-prompts.
2. Population of units; each unit = (typically two) task-prompts + a mutation-prompt (+ few-shot context).
3. **Binary tournament GA:** sample two units, compute fitness (accuracy of task-prompts on a random training batch); loser replaced by a mutated copy of winner.
4. **Five classes of mutation operators:** direct mutation (zero-order / first-order with mutation-prompt), estimation-of-distribution mutation (from population), **hyper-mutation** (mutate the mutation-prompt itself), Lamarckian mutation (reverse-engineer a prompt from a successful "working out"), and crossover / context shuffling.
5. Repeat for many generations.

## Key results
- Outperforms Chain-of-Thought and Plan-and-Solve prompting on commonly used arithmetic and commonsense reasoning benchmarks (abstract).
- Evolves intricate prompts for hate-speech classification (abstract).
- Specific per-benchmark numbers **[not reproduced; see paper tables]**.

## Why it matters for RSI
First clear demonstration of *self-referential* improvement in language space: the mutation operator is part of the genome. Weng cites it as the early example of evolutionary prompt search.

## Limitations
- Recursion is shallow: the GA, fitness, and selection are fixed code.
- Many LLM calls; fitness on small random batches is noisy.
- Prompts only — no tools, memory, control flow.

## Connections
STOP (concurrent self-referential idea in code); OPRO (non-evolutionary LLM optimizer); GEPA (adds reflection and Pareto selection); AlphaEvolve's co-evolving meta-prompts.

## Questions to think about
1. Do evolved mutation-prompts transfer across tasks? What would that imply?
2. Why does diversity (population) matter more for prompts than for gradient methods?
