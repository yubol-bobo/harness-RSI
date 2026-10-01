# Harness Design for Long-Running Application Development

- **Title:** Harness design for long-running application development
- **Authors:** Prithvi Rajasekaran (Anthropic Labs)
- **Year:** Mar 24, 2026
- **Link:** https://www.anthropic.com/engineering/harness-design-long-running-apps
- **Status:** read in full

**One-line TL;DR:** A GAN-inspired **planner–generator–evaluator** harness with sprint contracts and a Playwright-driven skeptical QA agent builds working multi-hour apps. Then **ablate** the harness as models improve, because "every component in a harness encodes an assumption about what the model can't do on its own."

**Problem:** (1) Coherence loss and **context anxiety** (Sonnet 4.5 wraps up early near its perceived limit). (2) **Self-evaluation leniency**: agents praise their own mediocre work.

**Method:**
- Frontend experiment: 4 criteria (design quality, originality, craft, functionality), weighted toward design and originality; evaluator calibrated with few-shot score breakdowns; 5–15 iterations, up to 4 h.
- Full-stack: **Planner** (1–4 sentence prompt → ambitious high-level spec), **Generator** (sprints, one feature at a time, git), **Evaluator** (Playwright MCP, hard per-criterion thresholds). **Sprint contracts** negotiated before coding. All communication via files. Context resets for Sonnet 4.5.
- v2 (Opus 4.6): remove sprints, keep planner, evaluator as a single end pass, drop context resets (Opus 4.5 removed context anxiety; SDK auto-compaction is enough).

**Key results:**
- Retro game maker: **solo 20 min / $9** (core game broken) vs **full harness 6 h / $200** (playable). Spec: 16 features over 10 sprints; Sprint 3 had 27 criteria.
- DAW with v2 harness: **3 h 50 min, $124.70**. QA still caught display-only features and stubbed recording.
- "Out of the box, Claude is a poor QA agent." It took several rounds of prompt tuning from log reading.

**Why it matters for harness/RSI:** Separating generator from evaluator is the same structural move as keeping evaluators outside a self-improvement loop. The "assumptions expire" principle explains why harness search must be *continual*. "The space of interesting harness combinations doesn't shrink as models improve. Instead, it moves."

**Limitations:** Anecdotal (a few prompts, n≈1 per config). Cost is high. Subjective quality judged by the author. The evaluator is still an LLM lenient to LLM outputs.

**My questions:** Can the evaluator-tuning loop (read logs → fix QA prompt) be automated, as in AHE? What predicts *where* the evaluator boundary sits relative to model capability?
