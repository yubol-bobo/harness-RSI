# OpenAI — Harness Engineering (Codex, zero human-written code)

- **Title:** Harness engineering: leveraging Codex in an agent-first world
- **Authors:** Ryan Lopopolo (OpenAI)
- **Year:** Feb 11, 2026
- **Link:** https://openai.com/index/harness-engineering/
- **Status:** **NOT read directly** (openai.com blocked). Facts come from search-result snippets quoting the post and secondary summaries; numbers cross-checked across ≥2 snippets where marked.

**One-line TL;DR:** A small team shipped an internal beta product in ~5 months where **every line** (app, tests, CI, docs, observability, tooling, even AGENTS.md) was written by Codex. The engineers' job became designing the environment: "Humans steer. Agents execute."

**Problem:** How do you get reliable, maintainable software when agents write everything and humans can't review at that throughput?

**Method (practices):**
- **AGENTS.md as a map, not an encyclopedia**: a short TOC pointing into a structured `docs/` directory (progressive disclosure).
- **Agent legibility**: UI, logs, metrics and performance made queryable by the agent. Chrome DevTools Protocol for DOM snapshots, screenshots and videos; the app is bootable per git worktree; ephemeral per-task observability via LogQL/PromQL.
- **Mechanically enforced architecture**: layered dependency rules (reported as Types → Config → Repo → Service → Runtime → UI) enforced by custom linters and structural tests whose error messages teach the fix.
- **Entropy management**: "golden principles" plus recurring background agents for cleanup, doc-gardening and quality grading.
- Merge philosophy adapted to agent throughput.

**Key results (secondary sources):** ~**1M lines of code**; ~**1,500 PRs**; started with **3 engineers** → ~**3.5 PRs/engineer/day**; throughput increased as the team grew to **7**; estimated **~1/10th** of the time to hand-write.

**Why it matters for harness/RSI:** It shows that harness engineering extends to the **repository and organization as the agent's environment**, and that sensors (linters/tests) plus guides (docs) let agents self-correct. It is an existence proof of large-scale "AI builds software" in a lab, a precursor to "AI builds AI".

**Limitations:** Internal product, not public. Quality and maintainability are self-reported. I could not verify details.

**My questions:** What fraction of human time went to harness work vs review? How does code quality (bugs, churn) compare with human-written baselines over a longer horizon?
