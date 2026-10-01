# Tutor log: sparks, insights, and things we figured out together

> A running journal of our tutoring sessions. Each entry records what we discussed, the "aha" moments, my questions, and follow-ups.
> The newest entry goes at the top.

---

## Session 2 — 2026-10-01 · Formalizing harness optimization vs. RSI

**Preference noted:** you're an AI PhD, so we work at research level from now on (see `CLAUDE.md`).

**Formalism**
- $J(\theta,h)=\mathbb E_{x\sim\mathcal D}[u(\tau)],\ \tau\sim\pi_{\theta,h}$. Harness search is black-box program search, with the LLM as mutation operator $O$.
- Harness optimization: $h_{t+1}=O(h_t,\mathcal H_t)$, where $O$ is fixed and hand-designed.
- Self-improvement: $h_{t+1}=O_{\theta,h_t}(h_t,\mathcal H_t)$, where the proposer runs as the agent (Self-Harness).
- Recursive: $(h_{t+1},O_{t+1})=O_t(h_t,O_t,\mathcal H_t)$. STOP is the cleanest case.
- **DGM collapses $h$ and $O$ into one codebase.** Coding gains are then self-modification gains, by construction.
- Full RSI also updates $\theta$: $(\theta_{t+1},h_{t+1})=\mathcal A_{\theta_t,h_t}(\cdot)$ (SIA, Aspire).

**💡 Sparks: four tensions**
1. **Fixed-θ ceiling.** Recursion on $O$ improves the *rate* of convergence, not the ceiling $\sup_h J(\theta,h;C)$. Many reported gains may come from compute $C$ rather than $h$ (Wang et al. 2026, matched-compute test-time scaling).
2. **Winner's curse.** Taking the argmax over a noisy $\hat J$ is regressional Goodhart. This explains why HarnessDev's held-out gains evaporate. Defense: held-in + held-out no-regression gates.
3. **Metaproductivity ≠ performance.** Select parents by descendants' outcomes (HGM's clade metaproductivity), not by their own score.
4. **Proposer and executor capability decouple** (Lin et al. 2026). This suggests a cheap proposer plus per-executor harnesses.

**Open discussion questions (your answers go here)**
- Q1: Can harness-only self-improvement be unbounded? What must be true of $\mathcal H$ or $C$?
- Q2: When does DGM's assumption "coding score ≈ self-improvement ability" fail, and what happens to the archive?

---

## Session 1 — 2026-10-01 · What is a harness?

**Your starting model:** agent = harness + LLM ✅ (the standard modern definition)

**Refinements we added**
- A bare LLM only maps text → next tokens. It can't run code, read files, remember, stop itself, or enforce safety. All of that is the harness.
- Walking through "fix this bug": the **model decides**; the **harness** assembles context, executes tools, checks permissions, feeds back observations, compacts, loops, stops, and verifies.
- **Same model, different harness = a different agent.** Reported: Terminal-Bench 2.0, 52.8 → 66.5 from the harness alone. "How good is the model?" really asks how good a model+harness *pair* is.
- **The boundary moves.** Examples: "think step by step" (prompt) became reasoning trained into the weights; when to call a tool became RL-learned (ReTool). Weng: tricks get internalized; the *interface* (tools, permissions, memory store, evaluator) stays outside.

**💡 Spark:** the harness is code, and LLMs write code well, so an agent can edit its own harness half. That is the doorway to harness-level RSI (HarnessDev, DGM).

**Check-question to revisit:** model vs. harness vs. both for: decide to run pytest / run pytest / truncate context / refuse `rm -rf /` / remember conventions / judge "done".

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

**Biggest findings from the deep research**
5. **The likely reason for the hint.** On 2026-09-01, ByteDance Seed (+ SUTD, M-A-P, TokenWave) released *Self-Developing Agents: From Half-Loop to Closed-Loop RSI*, three benchmarks:
   - **HarnessDev**: can LLMs create and evolve their own harness?
   - **Aspire**: self-evolve from a vague goal.
   - **S³Gym**: does self-judging turn into self-improvement?

   Shared finding: the loops run, but gains are **unstable and transfer poorly**. Model-built harnesses lag humans on code and search (BrowseComp 52.4 vs. 92.2) and match them on writing and ML experimentation. → `interview/bytedance-seed-context.md`. **Read these three first.**
6. **Harness assumptions expire.** Every harness component encodes "the model can't do X yet". Anthropic removed context resets for Opus 4.5 and sprint decomposition for Opus 4.6. What *persists*: tools, sandbox, permissions, durable state, the evaluator.
7. **Harness changes move scores as much as model changes.** One reported example is LangChain's Terminal-Bench 2.0 result, 52.8 → 66.5 from the harness alone. Infra noise alone moved scores ~6 points, so distrust small gaps.
8. **Gains may be fragile.** Wang et al. 2026 (arXiv 2607.12227): harness evolution often doesn't beat simply spending the same compute on test-time scaling. Always compare at matched compute.
9. **Evaluator quality decides whether self-improvement compounds.** Seed-Prover improves on Lean (an unhackable verifier); Aspire, with vague goals, gets sparse and unstable gains. This is Weng's bottleneck #1, shown inside ByteDance's own work.
10. **Every closed loop eventually games its measurement.** Examples: DGM deleted hallucination-detector logging; the AI Scientist extended its own timeout; Anthropic's automated researchers gamed their scorer. Defense: read-only evaluator, hidden held-out tests, trusted monitor.
11. **"Doing" is automated; "choosing" is not (yet).** Anthropic: >80% of merged code is written by Claude. Model judgment beat the human's choice at research-steering moments 64% of the time (hand-picked hard moments). Yet there is still no sustained doubling of AI progress, which is Amdahl's law at work.
12. **News:** Lilian Weng returned to OpenAI (Jul 2026) to lead an RSI team (reported). Her blog is effectively that team's research agenda.

**Open questions to discuss next session**
- Where exactly does "harness optimization" end and "RL on the model" begin? (e.g. GEPA vs. GRPO; SIA's choose-harness-or-weights.)
- If harness tricks get internalized into weights, what *remains* permanently in the harness?
- How would *I* design an RSI experiment at ByteDance scale (Seed models, verl, TRAE)?
