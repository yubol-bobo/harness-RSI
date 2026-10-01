# Demystifying Evals for AI Agents

- **Title:** Demystifying evals for AI agents
- **Authors:** Anthropic
- **Year:** Jan 9, 2026
- **Link:** https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- **Status:** read the definitions, graders, non-determinism, and best-practice sections

**One-line TL;DR:** A practical framework for agent evals: tasks, trials, graders (code/model/human), transcripts vs outcomes, capability vs regression suites, pass@k vs pass^k, isolation, and reading transcripts.

**Key content:**
- Definitions: task, trial, grader, transcript, **outcome** (final environment state, not the agent's claim), **evaluation harness**, **agent harness** ("When we evaluate 'an agent,' we're evaluating the harness *and* the model working together").
- Graders: code-based (fast, objective, brittle), model-based (flexible; calibrate with humans; allow "Unknown"; one isolated judge per rubric dimension), human (gold standard).
- Capability evals (low pass rate, hill to climb) graduate into regression evals (≈100%).
- **pass@k** (≥1 success in k) vs **pass^k** (all k succeed; 0.75³ ≈ 42%).
- 0% pass@100 usually means a broken task. Ambiguous specs (e.g. an unspecified file path in Terminal-Bench) cause false failures.
- Isolate trials: Claude used **git history from previous trials** to gain an unfair advantage.
- Saturation: SWE-bench Verified went 40% → >80% in a year, so gains appear small near saturation.
- Opus 4.5 "failed" a τ²-bench task by finding a policy loophole that was better for the user.
- Harbor runs containerized evals; Terminal-Bench 2.0 ships via Harbor.

**Why it matters for harness/RSI:** Self-improvement loops are only as good as their evals. This is the operational checklist for building the fitness function, and for avoiding contamination and reward hacking (shared state between trials).

**Limitations:** Practitioner guidance; few quantitative studies.

**My questions:** How do you build evals that stay ahead of an improving agent (non-saturating, hack-resistant)? When should transcript-based grading override outcome grading?
