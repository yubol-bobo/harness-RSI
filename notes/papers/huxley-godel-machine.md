# Huxley-Gödel Machine: Human-Level Coding Agent Development by an Approximation of the Optimal Self-Improving Machine (HGM)

- **Authors:** Wenyi Wang, Piotr Piękos, Li Nanbo, Firas Laakom, Yimeng Chen, Mateusz Ostaszewski, Mingchen Zhuge, Jürgen Schmidhuber (KAUST et al.)
- **Year:** 2025 (arXiv Oct 2025)
- **Venue:** ICLR 2026 (oral, per iclr.cc listing)
- **Link:** https://arxiv.org/abs/2510.21614

## TL;DR
Selecting self-modifying agents by their own benchmark score is the wrong signal; select by **clade-metaproductivity (CMP)** — how well an agent's descendants do — estimated with Thompson sampling in a tree search.

## Problem
**Metaproductivity–Performance Mismatch**: an agent's benchmark performance poorly predicts its potential to produce better descendants, which DGM/SICA implicitly assume.

## Method
- CMP(a): aggregate benchmark performance over the clade (a and its descendants).
- Paper argues access to true CMP suffices to simulate the Gödel Machine's decisions under assumptions.
- HGM: tree search over self-modifications; Thompson sampling over Beta posteriors of clade success/failure counts; expansion decoupled from evaluation (async). [exact estimator: see paper]

## Key results
- Outperforms DGM and SICA on SWE-bench Verified and Polyglot using fewer allocated CPU-hours (verified, abstract).
- Agent optimized on SWE-bench Verified with GPT-5-mini, evaluated on SWE-bench Lite with GPT-5, matches the best officially checked human-engineered agents (verified, abstract); ~57% figure from secondary press **[unverified number]**.

## Why it matters for RSI
Reframes RSI selection as credit assignment over lineages (like MCTS value backup) — the right objective for "improve the improver".

## Limitations
CMP estimates are noisy early in a lineage; still fixed FM; still benchmark-bound.

## Connections
DGM, SICA, Gödel Machine, MCTS/Thompson sampling, Hyperagents.

## Questions
- Can CMP be predicted from code features before descendants exist (a learned metaproductivity model)?
