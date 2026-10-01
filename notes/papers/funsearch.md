# Mathematical Discoveries from Program Search with Large Language Models (FunSearch)

- **Authors:** Bernardino Romera-Paredes, Mohammadamin Barekatain, Alexander Novikov, Matej Balog, M. Pawan Kumar, Emilien Dupont, Francisco J. R. Ruiz, Jordan Ellenberg, Pengming Wang, Omar Fawzi, Pushmeet Kohli, Alhussein Fawzi (Google DeepMind) — author list from memory **[verify]**
- **Year:** 2023 (online Dec 2023), Nature 2024
- **Venue:** Nature
- **Link:** https://www.nature.com/articles/s41586-023-06924-6 · code https://github.com/google-deepmind/funsearch

## TL;DR
Evolve a single Python function with a frozen code LLM + automatic evaluator + island-based population; found new cap-set constructions and better bin-packing heuristics, as readable programs.

## Problem
LLMs hallucinate; can pairing them with a rigorous evaluator yield *verifiably new* mathematics?

## Method
Skeleton program with one evolvable function (e.g. `priority`); best-shot prompting with a few high-scoring previous versions; evaluator scores; island model with periodic reset of weak islands.

## Key results
- Cap set of size **512 in dimension 8** (verified, secondary).
- Cap-set capacity lower bound improved (2.2180 → 2.2202 via admissible sets; secondary source).
- Online bin-packing heuristics beating first-fit / best-fit on standard benchmarks.

## Why it matters for RSI
Template for "LLM as mutation operator + verifier" — the ancestor of AlphaEvolve and of harness evolution.

## Limitations
Only one function evolves; needs a cheap exact evaluator; many samples (millions reported **[unverified]**).

## Connections
AlphaEvolve (full-file, multi-LLM successor), OpenEvolve, ShinkaEvolve, genetic programming.

## Questions
How much of the result is the LLM vs. the island-based search? (AlphaEvolve's "no evolution" ablation suggests both matter.)
