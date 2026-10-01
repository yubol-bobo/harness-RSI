# Terminal-Bench 2.0 (+ Terminus-2, Harbor)

- **Title:** Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces
- **Authors:** Mike A. Merrill et al. (large collaboration; 80+ co-authors per search snippet)
- **Year:** arXiv Jan 2026 (2601.11868); TB 2.0 released alongside the Harbor framework in late 2025 *(release date unverified)*
- **Link:** https://arxiv.org/abs/2601.11868 ; https://www.tbench.ai
- **Status:** via search snippets, Anthropic posts, and Weng; paper not read

**One-line TL;DR:** **89** hard, realistic terminal tasks (e.g. building software, training models, scientific computing) in Docker containers, graded by tests. It ships with the **Harbor** evaluation harness and the minimal **Terminus-2** agent (a ReAct loop sending tmux keystrokes to one persistent terminal).

**Why it matters for harness/RSI:** It is *the* testbed for harness engineering and harness evolution: AHE, Meta-Harness (seeded from Terminus-2 / Terminus-KIRA), Self-Harness, and LangChain's Deep Agents (52.8 → 66.5 with harness-only changes). Per-task resource specs are recommended. Anthropic shows that resource enforcement alone shifts scores by up to 6 pp.

**Limitations:** Resource and infra sensitivity; some tasks had ambiguous specs (e.g. unspecified file paths, per Anthropic); finite task count means overfitting risk for harness search, so held-out transfer (e.g. to SWE-bench) is important.

**My questions:** How many harness-evolution gains survive matched infra and multiple seeds? Should harness-search papers report held-out splits of TB2?
