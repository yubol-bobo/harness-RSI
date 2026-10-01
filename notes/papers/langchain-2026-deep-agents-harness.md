# LangChain — Improving Deep Agents with Harness Engineering

- **Title:** Improving Deep Agents with harness engineering
- **Authors:** LangChain
- **Year:** 2026
- **Link:** https://blog.langchain.com/improving-deep-agents-with-harness-engineering
- **Status:** via search snippets only (blog blocked)

**One-line TL;DR:** With the model fixed (gpt-5.2-codex), harness-only changes moved deepagents-cli from **52.8 → 66.5** on Terminal-Bench 2.0 (**+13.7 pts**, Top-30 → Top-5).

**Method (as reported):** System prompt emphasizing a self-verification loop (plan → build with tests in mind → verify against spec → fix); a **PreCompletionChecklistMiddleware** that intercepts the agent before exit and forces verification; context injection (directory maps, time-budget warnings); **loop-detection middleware** for doom loops; a "reasoning sandwich" for allocating reasoning effort (details unverified); trace analysis to find failure modes.

**Why it matters for harness/RSI:** A clean, controlled demonstration that the **harness is a large performance lever**, and that the levers are exactly AHE's components (system prompt, middleware, tool/context). It is also a manual version of trace-driven harness evolution.

**Limitations:** Single benchmark, single model; vendor blog; no multi-seed confidence intervals reported in what I saw; risk of benchmark-specific tuning.

**My questions:** Do these gains transfer to other models or benchmarks? How much is due to verification alone?
