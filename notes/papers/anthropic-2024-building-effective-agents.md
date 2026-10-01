# Building Effective Agents

- **Title:** Building effective agents
- **Authors:** Erik Schluntz, Barry Zhang (Anthropic)
- **Year:** Dec 2024
- **Link:** https://www.anthropic.com/research/building-effective-agents
- **Status:** read in full

**One-line TL;DR:** The most successful agentic systems use simple, composable patterns instead of heavy frameworks. Separate *workflows* (predefined code paths) from *agents* (LLM directs its own process), and invest in the agent-computer interface (ACI).

**Problem:** Teams over-engineer LLM systems with opaque frameworks and don't know when agents are warranted.

**Method / content:**
- Building block: the **augmented LLM** (retrieval + tools + memory).
- Five workflows: **prompt chaining** (with gates), **routing**, **parallelization** (sectioning / voting), **orchestrator-workers**, **evaluator-optimizer**.
- **Agents**: LLMs using tools in a loop on environment feedback, with stopping conditions (max iterations) and human checkpoints.
- Three principles: **simplicity**, **transparency** (show planning steps), **careful ACI design** (documentation + testing).
- Appendix 2, "prompt engineering your tools": choose formats the model has seen; avoid line-count diffs and code-in-JSON; **poka-yoke** tools; HCI-level effort on ACI.

**Key results / facts:**
- In the SWE-bench agent, "we actually spent more time optimizing our tools than the overall prompt."
- Requiring **absolute file paths** fixed relative-path errors: "the model used this method flawlessly."

**Why it matters for harness/RSI:** It is the canonical vocabulary for agent architectures, and a "start simple, add complexity only when it demonstrably improves outcomes" principle that later becomes the *harness ablation* discipline. Workflow patterns are the search space for ADAS/AFlow-style automated workflow design.

**Limitations:** Qualitative; no benchmark comparisons between patterns. Predates long-horizon harness concerns (compaction, memory, sandboxing). A header note says the tooling landscape has since changed (see Managed Agents).

**My questions:** Which of the five workflows do frontier models now internalize? Can a model choose between workflow and agent mode itself (as in dynamic workflows)?
