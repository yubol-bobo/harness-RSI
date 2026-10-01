# Effective Context Engineering for AI Agents

- **Title:** Effective context engineering for AI agents
- **Authors:** Anthropic Applied AI team: Prithvi Rajasekaran, Ethan Dixon, Carly Ryan, Jeremy Hadfield (+ contributors)
- **Year:** Sep 29, 2025
- **Link:** https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Status:** read in full

**One-line TL;DR:** Context is a finite "attention budget" with diminishing returns. Good context engineering means finding "the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

**Problem:** Agents in loops accumulate tokens; models degrade as context grows (context rot). Prompt engineering alone doesn't cover tools, history, retrieved data, or memory.

**Method / content:**
- Why: n² attention relationships, training on mostly shorter sequences, and position interpolation together give a performance *gradient*, not a cliff.
- Anatomy: system prompts at the "right altitude"; minimal, non-overlapping tools; diverse canonical examples.
- **Just-in-time retrieval** via identifiers plus tools; progressive disclosure; **hybrid** (CLAUDE.md up front, glob/grep at runtime).
- Long-horizon techniques: **compaction** (Claude Code keeps decisions, bugs, details + 5 most recent files; tune recall first, then precision; **tool-result clearing** as the lightest form), **structured note-taking** (NOTES.md, to-do lists, memory tool; Claude-plays-Pokémon), **sub-agent architectures** (return 1–2k-token summaries).
- Choosing: compaction for conversational flow, note-taking for milestone-driven iterative work, multi-agent for parallel research.

**Key results:** Mostly qualitative. Refers to the memory tool and context-editing launch (numbers are in the companion "Managing context" post: +29% / +39% / −84% tokens).

**Why it matters for harness/RSI:** It names the discipline and gives the governing principle. Context is the first persistent, learnable state outside weights (ACE, MCE build on this). It also predicts that "smarter models require less prescriptive engineering."

**Limitations:** Few quantitative ablations. Doesn't treat KV-cache economics (covered by Manus and later Anthropic posts).

**My questions:** How do you measure compaction quality offline? What is the optimal hybrid split between up-front and JIT context per task type?
