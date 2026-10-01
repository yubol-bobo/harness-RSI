# Agent Harness Design: 3 Patterns for Harnessing Claude's Intelligence

- **Title:** Agent Harness Design: 3 Patterns for Harnessing Claude's Intelligence
- **Authors:** Lance Martin (Anthropic, Claude Platform)
- **Year:** Apr 2, 2026
- **Link:** https://claude.com/blog/harnessing-claudes-intelligence
- **Status:** read in full

**One-line TL;DR:** (1) Use tools the model already knows (bash, text editor), (2) **strip the harness**: ask "what can I stop doing?" and let the model orchestrate, manage, and persist its own context, (3) set boundaries carefully: cache-friendly context and dedicated tools for security, UX and observability.

**Key results / facts:**
- 49% SWE-bench Verified (Claude 3.5 Sonnet) with only bash + text editor. Skills, programmatic tool calling and the memory tool are compositions of these.
- Programmatic tool calling (Opus 4.6 filtering its own outputs): BrowseComp **45.3% → 61.6%**.
- Sub-agents with Opus 4.6: **+2.8%** BrowseComp over the best single-agent runs.
- Compaction on BrowseComp: Sonnet 4.5 flat at **43%**; Opus 4.5 **68%**; Opus 4.6 **84%** (same setup).
- Memory folder on BrowseComp-Plus (Sonnet 4.5): **60.4% → 67.2%**.
- Pokémon memory at 14k steps: Sonnet 3.5 had 31 files and was stuck in the 2nd town; Opus 4.6 had 10 organized files, 3 badges, and a learnings file.
- Cache rules: static first and dynamic last; updates as messages; don't change models (use sub-agents); don't add or remove tools (use tool search); move breakpoints / auto-caching. Cached tokens cost 10% of base.
- Dedicated tools give the harness "an action-specific hook with typed arguments it can intercept, gate, render, or audit."

**Why it matters for harness/RSI:** The clearest vendor statement of the **thin-harness / bitter-lesson** stance, with evidence that context management quality grows with model capability, which supports Weng's claim that context engineering migrates into intelligence.

**Limitations:** Vendor blog; results are mostly on BrowseComp variants; selection of examples favors the thesis.

**My questions:** Which boundaries should *never* be delegated to the model (security, evaluation), and how do we decide that systematically?
