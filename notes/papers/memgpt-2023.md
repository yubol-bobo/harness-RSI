# MemGPT (Letta)

- **Title:** MemGPT: Towards LLMs as Operating Systems
- **Authors:** Charles Packer, Sarah Wooders, Kevin Lin, Vivian Fang, Shishir G. Patil, Ion Stoica, Joseph E. Gonzalez (UC Berkeley)
- **Year:** Oct 2023 (project renamed Letta, Sep 2024)
- **Link:** https://arxiv.org/abs/2310.08560
- **Status:** via search summaries plus background knowledge; author list from memory (unverified)

**One-line TL;DR:** Treat the context window as RAM and external storage as disk. The LLM manages its own memory by **paging** information in and out with function calls (**virtual context management**).

**Method:** Main context = system instructions + editable working context ("core memory") + FIFO message queue. External context = recall storage (searchable full history) + archival storage (vector-searchable documents). Memory-pressure warnings (interrupt-like) prompt the model to save before eviction. Function chaining via heartbeat-style continuation.

**Key results:** Better consistency in long multi-session chat and the ability to handle documents beyond the window *(specific numbers unverified)*.

**Why it matters for harness/RSI:** The origin of the **OS analogy** for agent memory (echoed by Weng and Managed Agents) and of **agent-controlled memory**. Modern coding agents implement the same idea with plain files and bash.

**Limitations:** Designed for weaker 2023 models; bespoke memory functions; overhead of the model managing memory.

**My questions:** With strong file-manipulating models, are bespoke memory tiers still useful (e.g. for latency), or is "just files" enough?
