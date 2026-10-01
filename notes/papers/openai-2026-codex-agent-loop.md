# OpenAI — Unrolling the Codex Agent Loop

- **Title:** Unrolling the Codex agent loop
- **Authors:** Michael Bolin (OpenAI)
- **Year:** Jan 23, 2026
- **Link:** https://openai.com/index/unrolling-the-codex-agent-loop/
- **Status:** **NOT read directly** (blocked). Based on search snippets and third-party deep dives; treat details as approximate.

**One-line TL;DR:** A walkthrough of the Codex CLI loop (user input → prompt assembly → Responses API inference → tool calls → results appended → repeat) in which **prompt structure and caching are first-class performance surfaces**.

**Content (as reported):**
- Codex CLI drives the loop through the **Responses API**. Each turn resends the conversation, which would be quadratic without caching.
- **Exact-prefix prompt caching**: the old prompt must be a byte-identical prefix of the new one. Up to ~90% input-cost reduction is cited by secondary sources.
- A cache-hit bug was fixed by making **MCP tool ordering deterministic**.
- **Compaction**: above an `auto_compact_limit`, Codex calls a `/responses/compact` endpoint that returns a replacement history containing a compaction item with **opaque encrypted content**.
- Weng reproduces its simplified loop diagram (tools' responses affect the next generation).

**Why it matters for harness/RSI:** It is the OpenAI counterpart to Anthropic's context-engineering guidance. The cache-prefix discipline constrains *any* harness edit, including automated ones (a harness optimizer that reorders tools could silently 10× cost).

**Limitations:** Secondary sourcing; Codex internals evolve quickly.

**My questions:** How does encrypted, model-side compaction compare with plain-text summaries in quality and debuggability? Does it lock users into one model's latent format?
