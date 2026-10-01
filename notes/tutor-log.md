# Tutor log: sparks, insights, and things we figured out together

> A running journal of our tutoring sessions. Each entry records what we discussed, the "aha" moments, my questions, and follow-ups.
> The newest entry goes at the top.

---

## Session 0 — 2026-10-01 · Kickoff & deep research

**Goal:** Build the learning repo for the TikTok/ByteDance research-scientist interview. Hint received: "你可以多准备下 harness 和 rsi 相关的内容" (prepare more on harness and RSI).

**What was done**
- Pulled Lilian Weng's *Harness Engineering for Self-Improvement* (Jul 2026), the two awesome lists, and Anthropic's *When AI builds itself* into `sources/`.
- Built `papers/arxiv_ids.tsv` (~220 papers, tiered P0/P1/P2) and `scripts/fetch_papers.sh`.
- Wrote topic notes 00–09 and per-paper cards in `notes/papers/`.

**First sparks (worth remembering)**
1. *Why the harness is the near-term RSI path:* it's code, it's cheap to change, it's inspectable, and coding agents are already strong. Weight-level self-modification is slower, riskier, and harder to attribute.
2. *"Is it really recursive?" test:* is the improver itself inside the loop? A fixed optimizer improving a prompt is optimization. An optimizer that rewrites itself (STOP, MCE meta-level, DGM) is RSI.
3. *Capability dependence is two-dimensional* (Lin et al. 2026): the ability to **write** good harness edits looks flat across model sizes. The ability to **benefit** from a harness is non-monotonic. That's a nice, non-obvious fact to bring up.
4. *The evaluator must live outside the loop.* Every serious system (AHE's read-only verifier, Self-Harness's held-in + held-out acceptance) does this, and the failures (DGM objective hacking) come from violating it.

**Open questions to discuss next session**
- Where exactly does "harness optimization" end and "RL on the model" begin? (e.g. GEPA vs. GRPO; SIA's choose-harness-or-weights.)
- If harness tricks get internalized into weights, what *remains* permanently in the harness?
- How would *I* design an RSI experiment at ByteDance scale (Seed models, verl, TRAE)?
