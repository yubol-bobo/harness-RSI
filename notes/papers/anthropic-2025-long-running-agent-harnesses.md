# Effective Harnesses for Long-Running Agents

- **Title:** Effective harnesses for long-running agents
- **Authors:** Justin Young (Anthropic)
- **Year:** Nov 26, 2025
- **Link:** https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents (code: anthropics/claude-quickstarts `autonomous-coding`)
- **Status:** read in full

**One-line TL;DR:** To make progress across many context windows, use an **initializer agent** (feature list, `init.sh`, progress file, git repo) and then a **coding agent** that does one feature per session, verifies end-to-end, and leaves a clean state.

**Problem:** Even Opus 4.5 on the Agent SDK with compaction fails to build a production web app from a one-line prompt. Failures: one-shotting (running out of context mid-feature), premature victory, marking features done without e2e tests, time wasted figuring out how to run the app.

**Method:**
- Initializer writes `feature_list.json` (**200+ features**, all `"passes": false`), `init.sh`, `claude-progress.txt`, initial commit.
- Coding agent each session: `pwd` → read progress + git log → run init.sh + smoke test (Puppeteer MCP) → pick one failing feature → implement → test like a user → flip `passes` → commit + update progress.
- JSON over Markdown because the model is "less likely to inappropriately change or overwrite JSON files"; strong prohibition on editing tests.
- Both "agents" share the same system prompt, tools, and harness. Only the initial user prompt differs.

**Key results:** Qualitative. Browser-automation testing "dramatically improved performance". Remaining issue: Puppeteer can't see native alert modals.

**Why it matters for harness/RSI:** The canonical pattern of **externalized state + version control as memory** (Weng Pattern 2). The same structure (log, keep/revert via git) appears in autoresearch and harness-evolution loops.

**Limitations:** Single domain (full-stack web). No quantitative comparison. The open question of single vs specialized multi-agent is left explicit.

**My questions:** How much of this is model-specific? (Later post: context resets dropped for Opus 4.5.) Can the feature list itself be adversarially weak, e.g. a too-easy spec that lets the agent declare victory?
