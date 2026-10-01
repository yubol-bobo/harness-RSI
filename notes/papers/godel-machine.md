# Gödel Machines: Self-Referential Universal Problem Solvers Making Provably Optimal Self-Improvements

- **Authors:** Jürgen Schmidhuber
- **Year:** 2003 (arXiv cs/0309048, revised to 2006); book chapter 2007
- **Venue:** Tech report IDSIA-19-03 / arXiv; later in *Artificial General Intelligence* (Springer, 2007)
- **Link:** https://arxiv.org/abs/cs/0309048

## TL;DR
A theoretical self-improving machine that may rewrite *any* part of its own code — including its proof searcher — but only after formally proving the rewrite increases expected utility, which makes each rewrite globally optimal relative to continuing the search.

## Problem
How can a general problem solver improve itself without hard-wired limits, and with a guarantee that self-changes are beneficial?

## Method
- Program = solver + **proof searcher**, with axioms encoding hardware, initial code, environment assumptions and utility $u$ (expected future reward incl. time costs).
- Self-rewrite executes only when a *target theorem* is proven: "switching to this code now is better than continuing to search for alternatives."
- Because the cost of further search is part of the theorem, accepted rewrites are "globally optimal — no local maxima" (Schmidhuber's phrasing).

## Key results
Theoretical only; no non-trivial implementation.

## Why it matters for RSI
The canonical formal definition of safe, provably-beneficial RSI; every "Gödel"-named practical system (DGM, HGM, Gödel Agent) defines itself relative to it.

## Limitations
- Proofs of utility improvement in real environments are intractable or undecidable; requires a faithful formal world model.
- Proof-search cost is enormous; "optimality" is only up to the time to find a proof.

## Connections
POWERPLAY (Schmidhuber), DGM (replace proofs with empirical validation), HGM (CMP as a proxy for the GM acceptance criterion), STOP.

## Questions
- Can a weakened, probabilistic acceptance test (e.g. statistical tests on held-out tasks) recover some guarantees?
- Which parts of a practical system should be "axioms" (immutable) — evaluator, utility, sandbox?
