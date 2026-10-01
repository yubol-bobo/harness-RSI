# Writing Effective Tools for Agents — with Agents

- **Title:** Writing effective tools for agents — with agents
- **Authors:** Ken Aizawa (Anthropic) with contributors
- **Year:** Sep 11, 2025
- **Link:** https://www.anthropic.com/engineering/writing-tools-for-agents
- **Status:** read in full

**One-line TL;DR:** Tools are a contract between deterministic software and non-deterministic agents. Prototype them, evaluate them on realistic multi-call tasks, and let Claude analyze transcripts and rewrite them. Principles: few high-impact tools, namespacing, meaningful token-efficient returns, and carefully prompt-engineered descriptions.

**Problem:** Wrapping APIs one-to-one as tools wastes context and confuses agents. Tool quality is hard to judge without evals.

**Method:** Build prototype (local MCP / DXT) → generate realistic eval tasks with verifiable outcomes → run simple agent loops (with reasoning and feedback blocks or interleaved thinking) → collect accuracy, runtime, #calls, tokens, errors → paste transcripts into Claude Code to refactor tools → use held-out test sets.

**Key results / facts:**
- Claude-optimized internal Slack and Asana tools beat "expert" human-written ones on held-out sets (charts; exact numbers not in text).
- `response_format` concise vs detailed: 72 vs 206 tokens (~⅓) in the Slack example.
- Claude Code caps tool responses at **25,000 tokens** by default.
- Replacing UUIDs with semantic or 0-indexed IDs "significantly improves" retrieval precision.
- The web search tool description was fixed after Claude kept appending "2025" to queries.
- Prefix vs suffix namespacing had "non-trivial effects" that vary by model.

**Why it matters for harness/RSI:** An explicit **model-improves-its-own-tools loop** with held-out validation. It is a small, practical instance of harness self-improvement (AHE's "tool description" and "tool implementation" components).

**Limitations:** Mostly internal tools; quantitative results are only in charts; no comparison across model families.

**My questions:** Does agent-optimized tool design transfer across models, or does it overfit to Claude's preferences? How do you avoid overfitting the tool-eval set?
