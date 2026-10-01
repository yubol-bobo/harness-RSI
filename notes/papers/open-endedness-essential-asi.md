# Position: Open-Endedness is Essential for Artificial Superhuman Intelligence

- **Authors:** Edward Hughes, Michael Dennis, Jack Parker-Holder, Feryal Behbahani, Aditi Mavalankar, Yuge Shi, Tom Schaul, Tim Rocktäschel (Google DeepMind)
- **Year:** 2024
- **Venue:** ICML 2024 (position paper; PMLR v235)
- **Link:** https://arxiv.org/abs/2406.04268

## TL;DR
Defines open-endedness relative to an **observer** via **novelty** and **learnability**, and argues foundation models + open-ended algorithms make ASI-relevant open-endedness achievable — and necessary.

## Problem
"Open-ended" was vague; scaling static datasets may plateau.

## Method (conceptual)
System produces artefacts $X_t$; observer predicts future artefacts from history. Novel = artefacts keep becoming less predictable; learnable = more history makes them more predictable. (Exact quantifiers: see paper **[paraphrased]**.)

## Key results
Conceptual; surveys paths (RL, self-improvement, task generation, evolution) and safety implications.

## Why it matters for RSI
Gives a yardstick for "endless" self-improvement vs. plateauing optimization; flags safety (unpredictability by design).

## Limitations
Observer-relative definition is hard to operationalize; no algorithm.

## Connections
OMNI, POET, AI-GAs, DGM, novelty search.

## Questions
Who is the observer for a self-improving lab-scale system — humans, or the system itself?
