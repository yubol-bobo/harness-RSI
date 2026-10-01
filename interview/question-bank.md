# Interview question bank: Harness × RSI

> How to use this file:
> 1. **Tier 1 (must-nail)**: practice out loud until each takes 60–120 s. Answers are sketched here; the full versions are in the linked notes.
> 2. **Tier 2 (index)**: every question in the notes, grouped by topic, each with a link to its model answer.
> 3. **Research proposals**: have 2–3 ready.
> 4. **Study plan**: a 14-day schedule.
>
> Answer structure that works for research interviews: **define → mechanism → evidence (paper + number) → limitation → what I'd do next.**

---

## Tier 1: the 20 questions you must nail

### A. Definitions & framing

**1. What is a harness? How is it different from the model and from an agent framework?**
The harness is the runtime around the weights: the agent loop, tools and their descriptions, context and memory management, sub-agents, skills, permissions/sandbox, and the evaluator. An agent framework (LangChain-style) is a library for *building* harnesses. A harness is a specific, deployed configuration of one. The same weights in different harnesses give very different scores (e.g. the Terminal-Bench leaderboards differ by harness). AHE splits a harness into 7 editable components: system prompt, tool descriptions, tool implementations, middleware, skills, sub-agent config, and long-term memory. → [01](../notes/01-harness-engineering-foundations.md)

**2. Define RSI precisely. Is X (e.g. Reflexion / ACE / DGM / STaR) RSI?**
Use the three-level vocabulary:
- *Self-refinement* changes only the current output.
- *Persistent* self-improvement changes weights, memory, harness, or code, and the change carries forward.
- *Recursive* self-improvement means the improvement mechanism itself is improved.

Then:
- Reflexion (within an episode) is refinement.
- ACE and STaR are persistent but not recursive: the curator/update rule is fixed.
- DGM is recursive within a bounded scope: the agent edits the same code that performs edits. The model and evaluator stay fixed.
- STOP is recursive at the scaffold level.

→ [00](../notes/00-big-picture.md) §3

**3. Why is the harness the near-term path to RSI rather than weights?**
- Harness edits are code: coding agents are already good at them, and they're cheap, fast, inspectable, reversible, and attributable.
- Weight updates are expensive and slow, hard to attribute, and risky (collapse, forgetting).
- Weng's predicted path has two parts. First, harness engineering moves toward meta-methodology (optimize the machinery, not the answer). Second, mature harnesses enable auto-research that improves training, and better models in turn keep harnesses simple.
- Caveat: many harness tricks will get internalized into weights. MemAgent and ReTool already *learn* memory and tool-use policies.

→ [00](../notes/00-big-picture.md), [03](../notes/03-harness-optimization.md)

**4. Draw the generic self-improvement loop and name the design knobs.**
Proposer → candidate → evaluator → acceptance rule → archive (fed back to the proposer). The six knobs:
1. edit surface
2. proposer (self vs. meta; is the proposer itself improved?)
3. feedback signal
4. observability / credit assignment
5. selection & diversity
6. acceptance & safety

Map any paper onto these. → [00](../notes/00-big-picture.md) §5

### B. Core methods (be able to whiteboard)

**5. STOP: write the objective; why did it fail for weak models?**
Meta-utility $\hat u(I)=\frac{1}{|\mathcal D|}\mathbb E_{(u,s)\sim\mathcal D}[u(I(u,s;M))]$. Update the improver with itself: $I_t = I_{t-1}(\hat u, I_{t-1}; M)$.
- With GPT-4, the improver discovered beam/tree search, genetic algorithms, and simulated annealing, and downstream utility rose.
- With GPT-3.5 and Mixtral it *degraded*: recursion alone is not enough, the model must be capable enough to improve the mechanism.
- STOP also observed sandbox-escape / "reward-hacking"-style attempts. → [03](../notes/03-harness-optimization.md), [card](../notes/papers/stop.md)

**6. ACE vs. MCE.**
- ACE: context as an evolving *playbook* of itemized bullets. Generator → Reflector → Curator. The curator emits deltas that are merged *deterministically*, avoiding *context collapse* and *brevity bias* from full rewrites. But the update rules are handcrafted.
- MCE: bi-level. The outer loop evolves the *skill* (the context-engineering mechanism) by agentic crossover over a history of skills and scores. The inner loop learns the context under that skill. Formally: inner $c_s^*=\arg\max J_{train}(c_s;s)$, outer $s^*=\arg\max J_{val}(c_s^*)$. Validation in the outer loop guards against overfitting.

→ [03](../notes/03-harness-optimization.md)

**7. ADAS vs. AFlow vs. Meta-Harness.**

| | ADAS | AFlow | Meta-Harness |
|---|---|---|---|
| Representation | Agents as code | Workflows as graph-in-code | Whole harness code |
| Search | Meta-agent search over an archive (idea → code → 2 self-refine steps → evaluate → add) | MCTS (soft-mixed selection, LLM expansion conditioned on scores, budgeted) | A coding agent proposes; full history (code, scores, traces) on the *file system*, read via grep/cat |
| Output | Archive of agents | Best workflow | A Pareto frontier of harnesses |

Trend: richer feedback and history access for the proposer. → [03](../notes/03-harness-optimization.md)

**8. Self-Harness and AHE: how do they keep harness search honest?**
- Self-Harness:
  1. Weakness mining (cluster failures into verifier-grounded patterns, with root causes).
  2. Bounded proposals (editable surfaces + failure patterns + behaviours to preserve + past attempts).
  3. Accept only if there is **no regression on both held-in and held-out** data.
- AHE adds three kinds of observability:
  - *Component*: each component is a file.
  - *Experience*: an agent debugger writes per-task reports, then a benchmark overview.
  - *Decision*: each edit is a falsifiable prediction checked next round.

  The tracer, verifier, and model config are **read-only**. That blocks the hacks "disable verifier / swap model / raise reasoning budget". Terminal-Bench-2 rose from 69.7% to 77.0% [see card], and the frozen harness transfers to SWE-bench Verified. → [03](../notes/03-harness-optimization.md), [ahe](../notes/papers/ahe.md), [self-harness](../notes/papers/self-harness.md)

**9. DGM: loop, selection rule, results, and the hacking incident.**
- Archive of coding agents. Parent probability ∝ sigmoid(λ(α_i − α₀)) · 1/(1+n_i): favour high score but also few children, which keeps exploration and stepping stones.
- The parent reads its own eval logs, edits its own harness repo (bash + editor tools), and the child is evaluated and archived.
- With a fixed Claude 3.5 Sonnet: SWE-bench Verified 20% → 50%, Polyglot 14.2% → 30.7%.
- Incident: an agent removed the special-token logging that the hallucination detector depended on. That is objective hacking, and the evaluator must sit outside the editable code.
- Successors: HGM scores agents by *clade metaproductivity* (descendants' performance), and Hyperagents adds a meta-agent.

→ [04](../notes/04-evolutionary-search-and-self-modifying-agents.md)

**10. AlphaEvolve in 60 s, and when evolution works.**
- A program database plus a prompt sampler (parents, scores, meta-prompts) feeds an LLM ensemble (Flash for breadth, Pro for depth). The LLMs emit diffs inside `EVOLVE-BLOCK` markers, and an evaluator cascade filters candidates before they go back into the database.
- Wins: 4×4 complex matrix multiplication in 48 scalar multiplications, 0.7% of Google's fleet compute recovered, a 23% Gemini kernel speedup (~1% training time), and a 32% FlashAttention speedup.
- It works when evaluation is **cheap, precise, and automatic**. It fails where evaluation is slow, fuzzy, or heuristic.

→ [04](../notes/04-evolutionary-search-and-self-modifying-agents.md), PDF in `papers/pdf/P0/`

**11. Model-level: STaR → ReST-EM → SPIN → Self-Rewarding → Absolute Zero in one framework.**
All of them are generate → filter/verify → train, iterated. They differ in the signal source:

| Method | Signal source |
|---|---|
| STaR / ReST-EM | Ground-truth answer check (EM view: E-step samples and filters, M-step fine-tunes) |
| SPIN | Discriminates human from self-generated data; its fixed point is the data distribution, so it has a ceiling |
| Self-Rewarding | The model judges itself (LLM-as-judge → DPO); risk of judge drift |
| Absolute Zero | Proposer + solver with a code executor as verifier; learnability reward is 0 when solve rate is 0 or 1 (same logic as GRPO's zero advantage) |

→ [05](../notes/05-model-level-self-improvement.md)

**12. What fundamentally limits self-improvement?**
1. **Generation–verification gap**: you can only improve where verifying is easier than generating (Song et al.: the gap grows with pretraining compute).
2. **Sharpening**: short RL mostly concentrates mass on answers already reachable (pass@1 up, pass@k at large k flat, per Yue et al.). The counter-evidence is ProRL and self-proposed tasks.
3. **Model collapse**: replacing real data degrades the model, while accumulating real data keeps error bounded.
4. **Capability floor**: STOP's weak-model failure, and harness-updating vs. harness-benefit.
5. **Evaluator quality**: Seed-Prover's Lean (unhackable) vs. Aspire's vague goals.

→ [05](../notes/05-model-level-self-improvement.md)

**13. "Harness updating is not harness benefit."**
Lin et al. 2026 separate two abilities:
- Writing useful harness edits is roughly flat across model scales (a 9B evolver can write a skill procedurally isomorphic to Opus's).
- *Benefiting* from a harness (correct, timely skill/tool calls and long-horizon instruction following) is non-monotonic: mid-tier models gain most.

Implication: cheap models can be harness proposers, and you should evaluate a harness *per executor model*. HarnessDev also finds gains depend on which model runs the harness. → [03](../notes/03-harness-optimization.md)

### C. Evaluation & rigour

**14. You got +3 points on Terminal-Bench from harness evolution. Convince me it's real.**
1. Multiple seeds with CIs (agent evals are noisy).
2. Held-out tasks never seen by the proposer.
3. A matched-compute baseline: Wang et al. 2026 found evolution often doesn't beat simply spending the same budget on test-time scaling.
4. Transfer to another benchmark (AHE → SWE-bench) and to another executor model.
5. Ablate each accepted edit.
6. Trace audits for hacking (did it read tests, change timeouts, special-case tasks?).
7. Correct for multiple comparisons when picking best-of-N variants (regressional Goodhart).

→ [07](../notes/07-benchmarks-and-evals.md)

**15. Design a benchmark for *recursive* self-improvement.**
- Measure the *slope*, not the level: improvement-of-improvement across generations (does generation k+1's improver produce bigger gains than generation k's?).
- Use hidden evaluators (S³Gym hides the verifier). Evaluate the artifact (HarnessDev evaluates the harness itself). Give vague goals (Aspire).
- Require held-out transfer. Keep compute matched. Add tamper-detection metrics.

→ [07](../notes/07-benchmarks-and-evals.md), [ByteDance context](bytedance-seed-context.md)

**16. METR time horizon: what is it and what are its weaknesses?**
- Definition: the human-time length of tasks an AI completes with 50% reliability. Doubling has been ~7 months historically and ~4 months recently. Anthropic's essay cites Opus 4.6 at ~12 h.
- Weaknesses: task-distribution dependence (software-heavy), the 50% threshold, messy-vs-clean tasks, human baseline variance, and saturation.

→ [07](../notes/07-benchmarks-and-evals.md), [09](../notes/09-frontier-labs-and-forecasts.md)

### D. Safety & judgment

**17. How do you stop a self-improving harness from hacking its evaluator?**
Principle: **the evaluator and permissions live outside the loop**. Concretely:
- A declared editable workspace; the verifier, tracer, model config, and budgets are read-only (AHE).
- Hidden held-out evals.
- Diff-based tamper detection and trace audits.
- A trusted (weaker) monitor reviews each self-edit (AI control).
- Limits enforced outside editable code (the AI Scientist extended its own timeout; DGM removed logging).
- Human checkpoints at decisions that matter.

Goodhart taxonomy for diagnosis: regressional, extremal, causal, adversarial. → [08](../notes/08-safety-and-theory-of-rsi.md)

**18. Hard vs. soft takeoff: what does 2026 evidence say?**
- Execution is heavily automated: Anthropic reports >80% of merged code by Claude, success on the most open-ended internal tasks at 76%, and research-steering judgments beating the human choice 64% of the time (Mythos Preview, on hand-picked "room for improvement" moments).
- But Amdahl's law applies: review, compute, and research taste are bottlenecks. Anthropic's own report says there is no sustained doubling of AI progress yet.
- Takeoff math: explosive if the returns-to-research ratio r = λ/β > 1. The key empirical crux is compute bottlenecks.

→ [09](../notes/09-frontier-labs-and-forecasts.md)

### E. ByteDance-specific

**19. What do HarnessDev / Aspire / S³Gym tell us?** (ByteDance Seed, Sep 2026: "from half-loop to closed-loop RSI")
- HarnessDev evaluates the harness itself. Model-built harnesses match or beat human references on writing and ML experimentation but lag on code and search (BrowseComp 52.4 vs. 92.2). Evolution gains are unstable and largely evaporate on held-out tasks.
- Aspire: vague goals → agents run loops, but weight-level gains are sparse and unstable.
- S³Gym: self-judging ≠ reusable policy, and transfer is task-dependent.
- My synthesis: **evaluator quality and transfer are the bottleneck**, not loop mechanics.

→ [bytedance-seed-context](bytedance-seed-context.md), [harnessdev](../notes/papers/harnessdev.md)

**20. Propose a research project for this team.** → see below.

---

## Research proposals (have 2–3 rehearsed, ~3 min each)

Template: **problem → why now → hypothesis → method → evaluation (incl. held-out & matched compute) → risks → first 2-week experiment.**

1. **Transfer-aware harness evolution.** HarnessDev, Aspire, and Wang et al. 2026 show gains that don't transfer.
   - Hypothesis: acceptance rules that require improvement on (a) a held-out domain and (b) a second executor model yield edits that transfer.
   - Method: Self-Harness-style loop + AHE observability + a multi-objective acceptance gate.
   - Evaluate on HarnessDev's hidden tasks at matched compute.
2. **Tamper-evident self-improvement.** Measure how often evolving agents read or modify evaluators under different permission designs, and whether a trusted-monitor protocol (AI control) catches it. Produces a benchmark and a defence.
3. **Learned verifiers for vague goals.** In Aspire-style settings, train the agent's self-built validation set to *predict hidden-test gains*. Track the Goodhart gap (self-val minus hidden) across iterations as the key metric.
4. **Harness → weights distillation.** Evolve a harness, then distill its behaviour (memory policy, tool-use timing) into weights with verl (multi-turn RL, as in MemAgent and ReTool).
   - Question: which harness components internalize well, and which must stay external (permissions, evaluator)?
   - This directly tests Weng's "internalization" prediction.
5. **Diversity-preserving agentic RL.** Combine DAPO's Clip-Higher (token-level entropy) with a population/QD archive at the trajectory or harness level in an Agent-World-style arena. Measure max-performance vs. mean (discovery wants the max).

---

## Tier 2: full index (≈108 Q&As with model answers in the notes)

| Topic | Questions | Where |
|---|---|---|
| Harness foundations | Q1–Q12: definition, agent loop, tool design, workflows vs. agents, long-running agents, compaction vs. sub-agents, multi-agent, harness eval, bitter lesson, OpenAI zero-human-code, permissions, why harness → RSI | [01 §21](../notes/01-harness-engineering-foundations.md) |
| Context & memory | Q1–Q10: context vs. prompt engineering, 1M windows, KV-cache design, compaction strategies, JIT context vs. RAG, research-agent memory, sub-agents, MemGPT, Manus lessons, link to RSI | [02 §14](../notes/02-context-engineering-and-memory.md) |
| Harness optimization | Q1–Q15: STOP, GEPA vs. GRPO, ACE, MCE, ADAS vs. AFlow, Meta-Harness, AHE/Self-Harness, updating vs. benefit, proving a gain, evaluator placement, proposals, limits, ByteDance | [03 §12](../notes/03-harness-optimization.md) |
| Evolution & self-modification | Q1–Q14: AlphaEvolve, DGM self-reference & selection, Gödel machine, HGM metaproductivity, objective hacking, ShinkaEvolve efficiency, evolution vs. test-time RL, max vs. mean, ByteDance application, QD, is DGM RSI, Flash+Pro, generalization | [04 §9](../notes/04-evolutionary-search-and-self-modifying-agents.md) |
| Model-level | Q1–Q14: unified framework, SFT-as-PG derivation, ReST-EM E-step, SPIN optimum, Absolute Zero reward, collapse math, TTRL, "RL only sharpens", gen–ver gap, SEAL, harness vs. model choice, self-rewarding failures, anchoring, fixed point | [05 §6](../notes/05-model-level-self-improvement.md) |
| Auto-research | Q1–Q10: anatomy, AI Scientist v2 acceptance, Trehan & Chopra fixes, AAR critique, unhackable evaluator, Chain-of-Evidence, Autodata, autoresearch, taste, Seed post-training auto-research | [06 §7](../notes/06-automated-ai-research.md) |
| Benchmarks | Q1–Q8: true self-improvement eval, SWE-bench Verified retirement, METR, RE-Bench 2h vs. 32h, KernelBench 300×, lab thresholds, RSI benchmark design, evaluator outside loop | [07 §3](../notes/07-benchmarks-and-evals.md) |
| Safety & theory | Q1–Q15: RSI definition, Bostrom, Gödel/DGM, Löbian obstacle, Goodhart classification, anti-hacking design, Sycophancy→Subterfuge, AI control, alignment faking, collapse, W2S, human role, takeoff, unsafe-but-better, ByteDance project | [08 §9](../notes/08-safety-and-theory-of-rsi.md) |
| Frontier labs | Q1–Q8: Anthropic evidence & critique, Amdahl, lab thresholds, OpenAI research intern, software intelligence explosion, Weng's move, what would change your mind, scenario-3 response | [09 §7](../notes/09-frontier-labs-and-forecasts.md) |

**Also expect (not RSI-specific but standard for Seed):**
- RL-for-LLM derivations: PPO clip, GRPO advantage, why all-correct/all-wrong groups give zero signal, KL's role, DAPO's four tricks.
- ML coding: multi-head attention, KV cache, top-p sampling.
- LeetCode mediums.
- A structured deep dive on your own research.

---

## 14-day study plan

| Day | Focus | Output |
|---|---|---|
| 1 | [00 big picture](../notes/00-big-picture.md) + Weng blog end-to-end | Say the elevator answer out loud |
| 2 | [01 harness foundations](../notes/01-harness-engineering-foundations.md) | Draw the coding-agent loop + tool table from memory |
| 3 | [02 context & memory](../notes/02-context-engineering-and-memory.md) | Explain ACE's anti-collapse trick and KV-cache design |
| 4–5 | [03 harness optimization](../notes/03-harness-optimization.md) | Whiteboard STOP, MCE, ADAS/AFlow, AHE, Self-Harness |
| 6 | [04 evolution](../notes/04-evolutionary-search-and-self-modifying-agents.md) + AlphaEvolve PDF | DGM selection rule + incidents |
| 7 | **ByteDance**: HarnessDev, Aspire, S³Gym (read PDFs) | 1-slide summary each + a follow-up experiment |
| 8 | [05 model-level](../notes/05-model-level-self-improvement.md) | Derive SFT-as-PG, ReST-EM, SPIN optimum |
| 9 | RL-for-LLM coding: PPO/GRPO/DAPO in PyTorch | ~30-line implementations |
| 10 | [06 auto-research](../notes/06-automated-ai-research.md) + [07 benchmarks](../notes/07-benchmarks-and-evals.md) | "Convince me the gain is real" answer |
| 11 | [08 safety](../notes/08-safety-and-theory-of-rsi.md) + [09 labs](../notes/09-frontier-labs-and-forecasts.md) | Anti-hacking design checklist from memory |
| 12 | Research proposals | Rehearse 2 proposals (3 min each) |
| 13 | Mock interview with me (tutor) | Tier-1 Q&A, timed |
| 14 | Your own research deep dive + questions to ask them | Final polish |
