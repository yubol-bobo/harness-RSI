# POET: Paired Open-Ended Trailblazer

- **Authors:** Rui Wang, Joel Lehman, Jeff Clune, Kenneth O. Stanley (Uber AI Labs)
- **Year:** 2019 (arXiv 1901.01753)
- **Venue:** GECCO 2019
- **Link:** https://arxiv.org/abs/1901.01753

## TL;DR
Co-evolve environments and the agents that solve them, with goal-switching transfer between pairs, endlessly generating harder challenges and solutions.

## Method
Population of (environment, agent) pairs; mutate environments subject to a minimal criterion (not too easy/hard); optimize agents with evolution strategies; periodically transfer agents across environments.

## Key results
Solves challenging 2D bipedal-walker terrains that direct optimization from scratch fails on (qualitative; verified at abstract level).

## Why it matters for RSI
Shows the "stepping stones" principle: capabilities learned on other problems unlock hard ones; the curriculum itself is generated — AI-GA pillar 3.

## Limitations
Hand-designed environment encoding bounds open-endedness (Enhanced POET addresses partly).

## Connections
MAP-Elites, novelty search, OMNI, AI-GAs, DGM archive.

## Questions
What is the LLM-era analogue of POET's environment generator for agent harnesses?
