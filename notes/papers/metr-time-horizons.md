# METR: Measuring AI Ability to Complete Long Tasks (time horizons)

- **Who / when:** Thomas Kwa, Ben West, et al. (METR). arXiv [2503.14499](https://arxiv.org/abs/2503.14499), Mar 2025 (NeurIPS 2025). Live tracker: [metr.org/time-horizons](https://metr.org/time-horizons/).
- **One-line:** measure AI capability in units of **how long the task takes a skilled human**. Find the task length at which the agent succeeds 50% of the time.

## Method
1. A suite of software / research-engineering tasks (HCAST, RE-Bench, SWAA) with **human completion-time baselines**.
2. For each model, fit P(success) as a logistic function of log(human time).
3. The **50% time horizon** is where the curve crosses 0.5. An 80% horizon is also reported (much shorter, same trend per Anthropic's footnote).
4. Plot the horizon against model release date, and fit an exponential to get the **doubling time**.

## Results
- 2019–2025: horizon **doubled about every 7 months**.
- 2024 onward: faster, **~4 months** (Anthropic essay). One fit through Feb 2026 gives ~105 days [secondary].
- Anthropic's essay: Claude Opus 3 ~4 min (Mar 2024) → Sonnet 3.7 ~1.5 h (2025) → Opus 4.6 ~12 h (2026).
- **Claude Mythos Preview (early version, Mar 2026): ≥16 h, 95% CI 8.5–55 h**, "at the upper end of what we can measure without new tasks" ([METR](https://x.com/METR_Evals/status/2052896621760004602)).

## Caveats
- **Ceiling:** very few tasks longer than 16 h (reportedly 5 of ~228), so the CIs are wide. New, longer tasks are needed.
- Tasks are cleaner and more self-contained ("less messy") than real work. Software-heavy.
- Human baselines vary. A 50% success rate is not deployable reliability.
- Extrapolation assumes the exponential continues. Anthropic's scenario 1 is that it bends.

## Why it matters for RSI
It is the **rate** metric everyone cites. Automating AI research needs agents that sustain progress over days or weeks. Anthropic extrapolates "days this year, weeks in 2027". Also the basis of the AI 2027 / AI Futures timelines models.
