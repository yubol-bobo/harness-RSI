# Harness × RSI: a learning repo

Personal study notes for a **TikTok / ByteDance PhD Research Scientist interview**. The hint was: *"你可以多准备下 harness 和 rsi 相关的内容"*. In English: prepare more on **harness engineering** and **recursive self-improvement (RSI)**.

The notes are written for a newcomer: intuition first, then formalism, then interview angles.

## 🗺️ Start here

1. **[notes/00-big-picture.md](notes/00-big-picture.md)**: the map, the vocabulary, the universal loop anatomy, and a 1-paragraph elevator answer.
2. **[Lilian Weng, *Harness Engineering for Self-Improvement* (Jul 2026)](sources/weng-2026-harness-engineering-for-self-improvement.md)**: the backbone source.
3. Then work through the notes in order.

## 📚 Notes

| # | Topic | File |
|---|---|---|
| 00 | Big picture, glossary, reading order | [notes/00-big-picture.md](notes/00-big-picture.md) |
| 01 | Harness engineering foundations (loop, tools, skills, MCP, permissions, coding-agent harnesses) | [notes/01-harness-engineering-foundations.md](notes/01-harness-engineering-foundations.md) |
| 02 | Context engineering & memory | [notes/02-context-engineering-and-memory.md](notes/02-context-engineering-and-memory.md) |
| 03 | **Harness optimization**: prompt → context → workflow → harness code → optimizer (ACE, MCE, ADAS, AFlow, STOP, Meta-Harness, Self-Harness, AHE …) | [notes/03-harness-optimization.md](notes/03-harness-optimization.md) |
| 04 | Evolutionary search & self-modifying agents (AlphaEvolve, ShinkaEvolve, DGM, Hyperagents, open-endedness) | [notes/04-evolutionary-search-and-self-modifying-agents.md](notes/04-evolutionary-search-and-self-modifying-agents.md) |
| 05 | Model-level self-improvement (STaR, ReST-EM, SPIN, self-rewarding, Absolute Zero, SEAL, limits) | [notes/05-model-level-self-improvement.md](notes/05-model-level-self-improvement.md) |
| 06 | Automated AI research (AI Scientist, ScientistOne, Autodata, failure modes) | [notes/06-automated-ai-research.md](notes/06-automated-ai-research.md) |
| 07 | Benchmarks & evals for self-improvement / AI R&D | [notes/07-benchmarks-and-evals.md](notes/07-benchmarks-and-evals.md) |
| 08 | Safety & theory of RSI (Goodhart, reward hacking, Gödel/Löb, control) | [notes/08-safety-and-theory-of-rsi.md](notes/08-safety-and-theory-of-rsi.md) |
| 09 | Frontier labs & forecasts | [notes/09-frontier-labs-and-forecasts.md](notes/09-frontier-labs-and-forecasts.md) |
| 📝 | 110 per-paper study cards | [notes/papers/README.md](notes/papers/README.md) |
| 💡 | **Tutor log**: sparks & insights from our sessions | [notes/tutor-log.md](notes/tutor-log.md) |

## 🎯 Interview prep

- [interview/question-bank.md](interview/question-bank.md): consolidated Q&A drawn from all notes.
- [interview/bytedance-seed-context.md](interview/bytedance-seed-context.md): ByteDance Seed's related work and talking points.

## 📄 Sources & papers

- `sources/`: verbatim copies of the seed resources (Weng blog, awesome-rsi, awesome-harness-engineering, Anthropic essay).
- [papers/INDEX.md](papers/INDEX.md): ~240 arXiv papers, tiered. ⭐ marks papers with a study card.
  - **B0**: ByteDance Seed work and must-read 2026 papers (HarnessDev, Aspire, S³Gym, …)
  - **P0**: cited by Weng
  - **P1**: awesome-rsi
  - **P2**: awesome-harness
- `scripts/fetch_papers.sh [B0|P0|P1|P2|all]` (default B0 + P0): downloads PDFs to `papers/pdf/` and extracts text to `papers/txt/`.

> ⚠️ The cloud sandbox where this repo was built blocks arxiv.org, so most PDFs are **not downloaded yet**. The exception is AlphaEvolve, fetched from DeepMind's storage into `papers/pdf/P0/`. Run the script locally, or allow `arxiv.org` in the environment's network settings, and run it again.

## ✅ Verification status

The notes were built from web search and the sources above. Most papers could not be opened directly because arxiv.org was blocked in the sandbox. Numbers are tagged:
- **[v]** or no tag: checked against an abstract or primary source
- **[unverified]**, **[secondary]** or **(reported)**: not yet checked against the paper

Re-check any number you plan to say out loud in the interview once the PDFs are downloaded.
