# How We Built Our Multi-Agent Research System

- **Title:** How we built our multi-agent research system
- **Authors:** Jeremy Hadfield, Barry Zhang, Kenneth Lien, Florian Scholz, Jeremy Fox, Daniel Ford (Anthropic)
- **Year:** Jun 13, 2025
- **Link:** https://www.anthropic.com/engineering/multi-agent-research-system
- **Status:** read in full

**One-line TL;DR:** An orchestrator-worker system (Opus lead + parallel Sonnet sub-agents + citation agent) beats a single agent by 90.2% on internal research evals, mostly because it can **spend more tokens in parallel across separate context windows**.

**Problem:** Open-ended research is path-dependent and breadth-heavy. A single sequential agent is slow and context-limited.

**Method:** Lead agent plans and saves the plan to memory (context >200k truncated) → spawns sub-agents with objective, output format, tools, and boundaries → sub-agents search with interleaved thinking → lead synthesizes and may iterate → CitationAgent attributes claims. Prompt heuristics: teach delegation, scale effort to complexity, start wide then narrow, parallel tool calls. Eval: ~20-query start set, single-call LLM judge with rubric (factual accuracy, citation accuracy, completeness, source quality, tool efficiency), plus human testing.

**Key results:**
- **+90.2%** vs single-agent Opus 4 on internal research eval.
- BrowseComp: **token usage explains 80%** of variance; with #tool calls and model choice, **95%**.
- Upgrading to Sonnet 4 > doubling the token budget on Sonnet 3.7.
- Agents use **~4×** chat tokens; multi-agent **~15×**.
- Parallelization cut research time by **up to 90%**.
- Tool-description-rewriting agent: **40%** faster task completion.

**Why it matters for harness/RSI:** Sub-agents as **context isolation + compression**; "let agents improve themselves" (prompt and tool self-improvement); production concerns (resumability, tracing, rainbow deploys) for stateful agents.

**Limitations:** Internal eval not public; coordination is synchronous; poor fit for dependency-heavy tasks like most coding; high cost.

**My questions:** Is the benefit *only* token spend, or is there a coordination effect beyond tokens at fixed budget? How do async sub-agents change the picture?
