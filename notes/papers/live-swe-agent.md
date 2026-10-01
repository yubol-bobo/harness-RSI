# Live-SWE-agent — Can Software Engineering Agents Self-Evolve on the Fly?

- **Authors:** Chunqiu Steven Xia, Zhe Wang, Yan Yang, Yuxiang Wei, Lingming Zhang (UIUC)
- **Year / Venue:** 2025 (arXiv Nov 2025) / preprint
- **Link:** https://arxiv.org/abs/2511.13646
- **Ladder level:** 4 (online scaffold/tool evolution)

## TL;DR
Start from a minimal bash-only scaffold (mini-SWE-agent) and let the agent create and refine its own tools *during* each problem it solves — no offline search.

## Problem
DGM/SICA-style self-improvement needs costly offline evolution and may overfit a benchmark. Can the agent instead evolve its scaffold online, per task?

## Method
1. Minimal scaffold: LLM + bash.
2. Prompt the agent that it may create custom tools (scripts) and, after steps, briefly reflect on whether a new tool or tool revision would help.
3. Tools are created as files and used immediately within the same episode.

## Key results (abstract)
- 77.4% solve rate on SWE-bench Verified without test-time scaling (best open result at the time per the authors).
- 45.8% on SWE-Bench Pro (best known at the time).

## Why it matters for RSI
Demonstrates zero-offline-cost, per-episode harness evolution; shows that with strong models, "the model can build its own harness on demand" — a counterpoint to heavy outer-loop search.

## Limitations
- Improvements don't persist across tasks by default (closer to in-episode refinement; persistence would need a tool library).
- Depends heavily on frontier model capability.

## Connections
Voyager (skill creation), SICA/DGM (offline self-editing), Continual Harness (online, reset-free), Self-Harness.

## Questions to think about
1. Under awesome-rsi's terms, is Live-SWE-agent self-refinement or persistent self-improvement? What change would make it persistent?
2. When does online tool creation beat an offline-optimized harness?
