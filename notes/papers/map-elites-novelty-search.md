# Quality-Diversity foundations: Novelty Search and MAP-Elites

- **Authors:** Lehman & Stanley (novelty search, 2008/2011); Mouret & Clune (MAP-Elites, 2015); Pugh, Soros & Stanley (QD framing, 2016)
- **Year:** 2008–2016
- **Venue:** ALIFE 2008 / Evolutionary Computation 2011; arXiv 1504.04909; Frontiers in Robotics and AI 2016
- **Link:** https://arxiv.org/abs/1504.04909 ; https://www.frontiersin.org/journals/robotics-and-ai/articles/10.3389/frobt.2016.00040/full

## TL;DR
Objectives can be deceptive; searching for novelty or for a *map* of diverse elites often finds better solutions than optimizing the objective directly.

## Method
- Novelty search: score $= \frac1k\sum_{j\le k} d(b(x), b(\mu_j))$ in behaviour space, archive of novel individuals.
- MAP-Elites: discretize behaviour descriptors into cells; keep the best per cell; select parents from occupied cells.

## Key results
Classic deceptive-maze and robotics results (e.g. damage-adaptive robot repertoires) — qualitative here.

## Why it matters for RSI
The theoretical justification for archives in DGM/AlphaEvolve/ShinkaEvolve and the main defence against diversity collapse.

## Limitations
Requires a good behaviour descriptor; high-dimensional descriptor spaces are hard (LLM-era: embeddings or LLM judges as descriptors).

## Connections
AlphaEvolve (MAP-Elites + islands), OpenEvolve, POET, OMNI, QDEvo / VendiEvolve (2026).

## Questions
What is the right behaviour descriptor for a coding-agent harness?
