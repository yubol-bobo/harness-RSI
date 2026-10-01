# 00 — The Big Picture: Harness × RSI (start here)

> Tutor note. Written for a newcomer. Read this before any other note; every later note plugs into the map below.
> Main sources: [Weng 2026, *Harness Engineering for Self-Improvement*](../sources/weng-2026-harness-engineering-for-self-improvement.md), [Anthropic 2026, *When AI builds itself*](../sources/anthropic-2026-when-ai-builds-itself.md), [awesome-rsi](../sources/awesome-rsi.md), [awesome-harness-engineering](../sources/awesome-harness-engineering.md).

---

## 1. Two ideas in one sentence each

- **Harness**: everything around the model weights that turns a next-token predictor into a working agent: the loop, the tools, the context and memory management, the permissions, the evaluation. (Weng: "the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results.")
- **Recursive self-improvement (RSI)**: an AI system improves itself, and it also improves the machinery that produces those improvements, so the gains can compound.

**Why the interviewer pairs them:** the most realistic near-term route to RSI is not "the model rewrites its own weights". It is "the model, running inside a harness, improves the harness (and the training pipeline), and that produces a better next model". The harness is the part of the system that is cheap to change, easy to inspect, and written in code. A coding agent can already edit code well.

```
          ┌──────────────────────── the AI system ────────────────────────┐
          │                                                                │
          │   weights (θ)          harness (h)                             │
          │   ─────────            ──────────────────────────────────      │
          │   pretrain/RL          loop · tools · context/memory ·         │
          │                        skills · sub-agents · permissions ·     │
          │                        evaluator · optimizer code              │
          └───────────────▲──────────────────────────▲─────────────────────┘
                          │ model-level RSI           │ harness-level RSI
                          │ (self-training, self-play,│ (prompt/context/workflow/
                          │  RLVR, SEAL, TTT …)       │  harness-code evolution:
                          │                           │  ACE, ADAS, DGM, Meta-Harness…)
                          └──────── auto-research closes both loops ─────────┘
                                   (AI Scientist, AlphaEvolve, Autodata,
                                    Anthropic's automated W2S researcher)
```

---

## 2. Where the RSI idea comes from (history in 60 seconds)

| Year | Idea | One-liner |
|---|---|---|
| 1965 | I. J. Good, "ultraintelligent machine" | A machine that can design better machines → "intelligence explosion". |
| 2003 | Schmidhuber, Gödel Machine | Self-rewrites allowed only when *provably* beneficial. Elegant, and impractical. |
| 2008 | Yudkowsky, "Recursive self-improvement" | Names the specific loop: intelligence improves the machinery that produces intelligence. |
| 2023 | STOP (Zelikman et al.) | An LLM-written "improver" program improves *itself*. Scaffolding-level RSI, demonstrated empirically. |
| 2024–25 | ADAS, AFlow, AlphaEvolve, Darwin Gödel Machine | Agent designs and programs become search spaces; LLMs act as the mutation operator. |
| 2025–26 | ACE, MCE, Meta-Harness, Self-Harness, AHE | The harness itself becomes the optimization target ("harness engineering for self-improvement"). |
| 2026 | Anthropic, "When AI builds itself" | Lab data: >80% of merged code written by Claude; AI does the *doing*, humans keep *taste and direction*. |

---

## 3. Vocabulary that keeps you precise (use these words in the interview)

From awesome-rsi's "Scope & Terminology". These distinctions are the most useful thing to say early in an answer:

| Term | Meaning | Example |
|---|---|---|
| **Self-refinement** | Improves the *current output*. Nothing persists. | Self-Refine, Reflexion within one episode |
| **Persistent self-improvement** | Changes to weights / memory / skills / prompts / harness / code that **carry into the next round** | ACE playbook, Voyager skill library, STaR fine-tuning |
| **Recursive self-improvement** | **The mechanism that produces improvements is itself improved** | STOP (improver improves improver), DGM (agent edits its own agent code), MCE (evolves the context-*engineering* skill) |
| **RSI substrate** | Exposes the agent's own structure as editable, but doesn't by itself form an automatic loop | Extensible harness frameworks |

**Test for "is it really recursive?"** Ask: *is the thing being improved also the thing doing the improving?* If a fixed, human-written optimizer improves a prompt, that is optimization, not RSI. If the optimizer is itself rewritten by the system, it is RSI (possibly bounded).

---

## 4. The ladder of optimization targets (Weng's core framing)

> instruction **prompts** → structured **context** → **workflow** → **harness code** → **optimizer code**

Each rung is a bigger search space and needs a more capable model. The common thread is that **code is a universal language**: once the harness is code, a coding agent can search the same design space human engineers use.

| Rung | What is edited | Representative work | Notes file |
|---|---|---|---|
| 1. Prompt | instruction text | OPRO, Promptbreeder, GEPA, DSPy | [03](03-harness-optimization.md) |
| 2. Context | structured playbook / memory | ACE, Dynamic Cheatsheet, MCE | [02](02-context-engineering-and-memory.md), [03](03-harness-optimization.md) |
| 3. Workflow | graph of LLM calls | ADAS, AFlow | [03](03-harness-optimization.md) |
| 4. Harness code | the agent's own source | DGM, SICA, Meta-Harness, Self-Harness, AHE | [03](03-harness-optimization.md), [04](04-evolutionary-search-and-self-modifying-agents.md) |
| 5. Optimizer code | the improver itself | STOP, MCE's meta-level, Hyperagents | [03](03-harness-optimization.md), [04](04-evolutionary-search-and-self-modifying-agents.md) |
| (+) Weights | θ | STaR, ReST-EM, SPIN, Absolute Zero, SEAL; joint: SIA, Continual Harness | [05](05-model-level-self-improvement.md) |

---

## 5. The universal anatomy of a self-improvement loop

Almost every paper in this area is an instance of this loop. If you can map a new paper onto it in 30 seconds, you understand the paper.

```
   ┌──────────────┐  propose edit Δ   ┌──────────────┐  run on tasks  ┌──────────────┐
   │   PROPOSER    │ ───────────────▶ │  CANDIDATE   │ ─────────────▶ │  EVALUATOR    │
   │ (LLM / agent; │                  │  h' = h ⊕ Δ  │                │ (tests, judge,│
   │  maybe itself)│                  └──────────────┘                │  benchmark)   │
   └──────▲───────┘                                                   └──────┬───────┘
          │  reads: traces, failures, scores, history                          │ score, traces
          │                                                                    ▼
   ┌──────┴────────────────────────────────────────────┐          ┌──────────────────┐
   │ ARCHIVE / MEMORY (file system): past candidates,   │ ◀─────── │ ACCEPTANCE RULE   │
   │ scores, traces, diffs, "what was tried"             │          │ (greedy, Pareto,  │
   └────────────────────────────────────────────────────┘          │ no-regression on  │
                                                                   │ held-in+held-out) │
                                                                   └──────────────────┘
```

Six design knobs. Interview answers become sharp if you name them:

1. **Edit surface**: what may change (prompt? one marked code block? the whole repo?). Bounded surfaces are safer and easier to attribute (AlphaEvolve's `EVOLVE-BLOCK`, AHE's 7 components, Self-Harness's "editable surfaces").
2. **Proposer**: who proposes edits, and is it the same model (self) or a stronger one (meta)? Does the proposer itself get improved (recursion)?
3. **Feedback signal**: verifiable (unit tests, runtime, benchmark), learned judge, self-judgment, or human. *Signal quality bounds everything.*
4. **Credit assignment / observability**: can we tell *which* component caused a failure? (AHE: component, experience, and decision observability; Self-Harness: weakness mining.)
5. **Selection & diversity**: greedy hill-climbing vs. archive / tree / MCTS / quality-diversity. Without diversity pressure, populations collapse (DGM's open-ended archive, ShinkaEvolve's novelty rejection).
6. **Acceptance & safety**: held-out regression tests, read-only verifier, permissions *outside* the loop, human checkpoints.

---

## 6. Why now? Four forces

1. **Coding agents got good.** Harnesses are code, so a model that can edit repos can edit its own harness. Anthropic reports >80% of merged code written by Claude (May 2026).
2. **The file system is the memory.** Long-horizon work produces logs, traces, and diffs that exceed any context window. Storing them as files and letting the agent `grep` them scales (Meta-Harness, AHE, MCE all do this).
3. **Verifiable rewards are everywhere in software and ML engineering.** Tests, runtimes, and benchmark scores give cheap, precise fitness signals, which is where evolution and RL work best.
4. **Interfaces are standardizing.** Tool sets (Read / Write / Edit / Bash / Grep / Glob / spawn_agent), MCP, and Skills make harnesses comparable and transplantable, the "OS analogy".

---

## 7. Why it might *not* compound (the honest counterweights)

Weng's seven open challenges, plus lab caveats. These make excellent "what are the limitations?" answers:

1. **Weak and fuzzy evaluators.** Loops work only where measurement is precise; research taste and novelty are not.
2. **Context and memory lifecycle.** Memory grows without bound; it needs curation (ACE's "context collapse" and "brevity bias").
3. **Negative results.** LLMs are trained on a success-biased literature and are bad at abandoning hypotheses.
4. **Diversity collapse.** Evolution and RL exploit known high-reward patterns.
5. **Reward hacking.** The loop optimizes the signal, not the intent (DGM faking tool logs; agents editing tests).
6. **Long-term objectives.** Sandbox rewards miss maintainability and repository health.
7. **Role of humans.** Humans should move *up the stack* (oversight at the right abstraction), not out of the loop.

Plus:

- **Capability dependence.** STOP improved with GPT-4 but *degraded* with GPT-3.5 and Mixtral, so recursion needs a minimum level of intelligence. Lin et al. 2026 split this into *harness-updating* ability (surprisingly flat across model sizes) and *harness-benefit* ability (non-monotonic; middle-tier models gain the most).
- **Amdahl's law.** Speeding up the "doing" moves the bottleneck to review, compute, and direction-setting (Anthropic).

---

## 8. One-paragraph "elevator answer" (practice saying this out loud)

> "I think of RSI as a closed loop with a proposer, an evaluator, an archive, and an acceptance rule. RSI happens when the proposer or the optimizer is itself inside the loop. The near-term path runs through the **harness** rather than the weights. The harness is code, coding agents are already strong, and harness edits are cheap, inspectable, and reversible. The progression goes prompts → context → workflows → harness code → optimizer code: ACE and MCE for context, ADAS and AFlow for workflows, DGM, Meta-Harness, Self-Harness, and AHE for harness code, and STOP for the improver itself. What makes these loops work is a precise evaluator, observability good enough for credit assignment, bounded edit surfaces, diversity in the archive, and a verifier and permission layer that sit *outside* the loop. What limits them is fuzzy evaluation (research taste), reward hacking, diversity collapse, and the fact that the base model still has to be capable enough both to propose useful edits and to benefit from them. Over time I expect many harness tricks to get internalized into the weights, the way prompt tricks were absorbed by instruction tuning. The *interface* to tools, context, and evaluation won't go away, though."

---

## 9. Reading order

1. This file → [Weng's blog (source)](../sources/weng-2026-harness-engineering-for-self-improvement.md), read once end-to-end.
2. [01 Harness foundations](01-harness-engineering-foundations.md) → [02 Context & memory](02-context-engineering-and-memory.md)
3. [03 Harness optimization](03-harness-optimization.md) (the core) → [04 Evolution & self-modifying agents](04-evolutionary-search-and-self-modifying-agents.md)
4. [05 Model-level self-improvement](05-model-level-self-improvement.md)
5. [06 Auto-research](06-automated-ai-research.md) → [07 Benchmarks](07-benchmarks-and-evals.md)
6. [08 Safety & theory](08-safety-and-theory-of-rsi.md) → [09 Frontier labs & forecasts](09-frontier-labs-and-forecasts.md)
7. [Interview prep](../interview/) — question bank + ByteDance Seed context.

## 10. Glossary (quick lookup)

- **Scaffold** ≈ harness (older term, common in 2023–24 papers; "scaffolding").
- **Agent loop**: while not done: model → tool call → observation → model … (ReAct-style).
- **Context engineering**: deciding what goes into the context window at each step (vs. prompt engineering = wording one prompt).
- **Compaction**: summarizing or truncating history so a long run fits in context.
- **Skill**: a reusable, file-based bundle of instructions (+ scripts) loaded on demand.
- **MCP**: Model Context Protocol, a standard interface for exposing tools and data to models.
- **Sub-agent**: a child agent with its own fresh context, used to isolate or parallelize work.
- **Archive**: a stored population of past candidates (enables open-ended search and stepping stones).
- **Pareto frontier**: candidates not dominated on all objectives at once (e.g. accuracy vs. cost).
- **Held-in / held-out**: tasks used to drive edits vs. tasks used only to check for regressions/overfitting.
- **RLVR**: RL with verifiable rewards (unit tests, math answers).
- **Goodhart's law**: "when a measure becomes a target, it ceases to be a good measure."
- **Objective / reward hacking**: optimizing the measured signal in unintended ways.
- **Open-endedness**: continually producing novel *and* learnable artifacts, with no fixed end goal.
- **Time horizon (METR)**: length (in human time) of tasks an AI completes with 50% reliability; it has been doubling every few months.
