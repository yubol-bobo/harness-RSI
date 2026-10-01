# Forethought: software intelligence explosion (Eth & Davidson; Davidson & Houlden)

- **Papers:**
  1. Daniel Eth & Tom Davidson, "**Will AI R&D Automation Cause a Software Intelligence Explosion?**", Forethought, **26 Mar 2025** ([link](https://forethought.org/research/will-ai-r-and-d-automation-cause-a-software-intelligence-explosion)).
  2. Tom Davidson & Tom Houlden, "**How quick and big would a software intelligence explosion be?**", Forethought, 2025 ([link](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be)).
- **Counterpoint paper:** Parker Whitfill & Cheryl Wu, "**Will Compute Bottlenecks Prevent an Intelligence Explosion?**", arXiv [2507.23181](https://arxiv.org/abs/2507.23181), 2025.

## Core concepts
- **ASARA**: AI Systems for AI R&D Automation, AI that can fully automate AI research.
- **Software intelligence explosion (SIE):** after ASARA, AI improves *software* (architectures, training methods, data, scaffolding) fast enough that progress accelerates **without more hardware**.
- **Returns to software R&D, r:** how many doublings of software efficiency you get per doubling of cumulative research input. If AI labor scales with software efficiency, **r > 1 ⇒ accelerating (hyperbolic) progress**. r < 1 ⇒ it fizzles. Eth & Davidson use empirical data (e.g. Epoch estimates of algorithmic-efficiency growth vs. research-input growth) and argue r is likely above 1 [exact estimate unverified].

## Davidson & Houlden's quantitative model
- **~60%**: the SIE compresses >3 years of AI progress into <1 year.
- **~20%**: it compresses >10 years into <1 year.
- Initial speed-up versus 2020–24 software progress: **2–32x, median 8x**.
- Headroom: **6–16 OOMs** of efficiency gains before effective limits.
- Illustration: from 30,000 top-expert-level AIs at 30x human speed to 30 million superintelligent researchers at 120x.
- Authors: the model is "extremely basic"; don't put much faith in the specific numbers.

## Counterarguments
- **Compute bottleneck (Whitfill & Wu):** model research as CES(labor, compute). Using a 2014–2024 panel (OpenAI, DeepMind, Anthropic, DeepSeek), the baseline spec says compute and labor are **substitutes** (no hard bottleneck). The "frontier experiments" spec says **complements** (bottleneck). Unresolved.
- **Amdahl's law** (Anthropic): the un-automated fraction (taste, review, experiment wall-clock) caps speedups.
- **Epoch-style skepticism:** algorithmic progress is compute-dependent, and parallelization has limits.

## Interview hooks
- Derive r > 1 from dS/dt ∝ R^λ S^(1−β) with R ∝ S: the exponent is λ + 1 − β > 1 ⇔ λ/β > 1.
- Lab thresholds track the same quantity: Anthropic's "doubling the rate of aggregate AI progress" and OpenAI's "generational improvement in 1/5 the time".
