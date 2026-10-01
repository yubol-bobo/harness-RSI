# Anthropic: "When AI builds itself" (Anthropic Institute)

- **Who / when:** Marina Favaro & Jack Clark (Anthropic Institute). Data through May 2026, update note dated **18 Sep 2026**. URL: [anthropic.com/institute/recursive-self-improvement](https://www.anthropic.com/institute/recursive-self-improvement). (awesome-rsi labels it 2025, but the content is clearly 2026.) Full text: [`sources/anthropic-2026-when-ai-builds-itself.md`](../../sources/anthropic-2026-when-ai-builds-itself.md).
- **One-line:** a frontier lab publishes internal evidence that AI is already accelerating its own development. Execution is largely automated. Judgment and goal-choosing are the remaining human edge. It lays out three futures.

## Numbers (with the essay's own caveats)
| Metric | Value | Caveat |
|---|---|---|
| Merged code authored by Claude | >80% (May 2026) | Conservative attribution. Leadership says 90%+. |
| Code / engineer / day | 8x (Q2 2026 vs 2024) | LoC overstates productivity. |
| Self-reported uplift | ~4x median (n=130, Mar 2026) | True uplift "somewhat lower". METR finds overestimation. |
| Open-ended task success | 76% (May 2026), +50 pp in 6 mo | Claude-judged. |
| Training-code speedup task | 3x (Opus 4, May 2025) → ~52x (Mythos Preview, Apr 2026). Human ~4x in 4–8 h. | Depends on the slack in the starting code. |
| Automated W2S research | 97% vs 23% gap recovered, ~800 h, ~$18k | Didn't transfer to production. Humans set the problem. |
| Research steering | 51% (Opus 4.5) → 64% (Mythos Preview) vs human | Selected moments (n=129). Control set ~20%. |
| Retro code review | Would catch ~1/3 of past incident bugs | — |
| API-error cleanup | 800+ fixes, 1000x error reduction (vs ~4 human-years) | Anecdote |

## Arguments
- **Engineering vs research. Doing vs choosing.** The human role is narrowing to taste and judgment.
- **"What if we're wrong?"** Most progress is incremental perspiration, which is automatable. Even without taste, acceleration compounds.
- **Three scenarios:** (1) stall + diffusion (unlikely per Anthropic); (2) compounding efficiency with humans steering (likely), capped by **Amdahl's law**, with code review already a bottleneck; (3) full RSI, paced by compute, with an uncertain alignment outcome.
- **Policy:** wants the *option* to slow or pause. Would pause if frontier peers verifiably did too. Verification is harder than in arms control.

## How to use it in an interview
Quote the numbers *with* their caveats. That shows calibration. Pair them with the RSP determination that the models still don't produce a "sustained doubling in the pace of our AI progress" (see note 09 §1.2).
