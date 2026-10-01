# 03 — Automated Harness / Prompt / Workflow Optimization

> The core of "harness engineering as a path to recursive self-improvement (RSI)".
> Backbone: Lilian Weng, *Harness Engineering for Self-Improvement* (Lil'Log, July 2026) — `sources/weng-2026-harness-engineering-for-self-improvement.md`.
> Per-paper cards live in `notes/papers/`. Numbers marked **[unverified]** could not be checked against the paper abstract/text; everything else was cross-checked via the source blog, the paper abstract, or search snippets quoting the paper (as of 2026-10-01).

---

## 0. Start here: the one-paragraph intuition (for a naive reader)

A large language model (LLM) by itself is a function: text in, text out. Everything *around* it — the system prompt, the tool definitions, the loop that decides "call a tool, read the result, think again", the memory files, the tests that decide whether the job is done — is the **harness**. Weng's definition: *"the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results."*

Two facts make the harness interesting for self-improvement:

1. **It matters a lot.** The same model can score very differently under different harnesses (e.g., on Terminal-Bench 2.0, AHE's evolved harness on GPT-5.4 reached 77.0% vs. 71.9% for the stock Codex CLI harness on the same model).
2. **It is made of text and code** — exactly what LLMs are good at reading and writing. So an LLM can, in principle, *edit its own harness*, measure the result, and keep the improvement — without touching its weights.

This note is about turning that idea into algorithms. The guiding picture is an **optimization problem**:

$$
h^* = \arg\max_{h \in \mathcal{H}} \; \mathbb{E}_{x \sim \mathcal{D}} \big[\, R\big(x,\; \text{Run}(M, h, x)\big) \big]
$$

- $M$: the (usually frozen) model.
- $h \in \mathcal{H}$: a harness drawn from some design space (a prompt? a set of notes? a workflow graph? a whole Python repo?).
- $\text{Run}(M,h,x)$: the trajectory produced when model $M$ runs inside harness $h$ on task $x$.
- $R$: a reward / utility / verifier score.

You cannot take gradients of $R$ with respect to $h$ (it is discrete text/code, and $\text{Run}$ is a black box). So all methods in this note are **black-box, LLM-driven search**: an LLM *proposes* a new $h'$, an evaluator *scores* it, and an *acceptance rule* decides whether to keep it. What changes from paper to paper is:

| Design axis | Options |
|---|---|
| **What is $h$** (the optimization target) | prompt → structured context → workflow → harness code → optimizer code |
| **Who proposes** | same model, stronger model, a separate coding agent, the improver itself |
| **What the proposer sees** (feedback) | scalar scores; scored history; natural-language critiques; full traces on a filesystem |
| **Search algorithm** | greedy hill-climb, evolutionary/GA, Pareto-frontier, MCTS, Bayesian surrogate, archive-based open-ended |
| **Acceptance rule** | best-so-far; improvement on val set; no-regression on held-in AND held-out; Pareto non-dominated |

Weng's key sentence: *"The progression in the object being optimized in the harness system is roughly: instruction prompts → structured context → workflow → harness code → optimizer code. As the model becomes more intelligent and powerful, we move toward more complex targets and generic methods."* We follow exactly that ladder.

```
 Level 1        Level 2              Level 3          Level 4             Level 5
 PROMPT   -->   STRUCTURED CONTEXT -> WORKFLOW   -->  HARNESS CODE  -->   OPTIMIZER CODE
 OPRO           Reflexion, ExpeL     ADAS             Meta-Harness        STOP
 Promptbreeder  Dynamic Cheatsheet   AFlow            Self-Harness        Promptbreeder (mutation prompts)
 DSPy / MIPRO   AWM, Voyager skills  (EvoAgentX)      AHE, SICA, DGM      MCE (meta-level skills)
 TextGrad       ACE                                   Live-SWE-agent      Hyperagents
 GEPA           MCE (base level)                      Continual Harness   (DGM: agent edits the editor)
 smaller design space, cheaper eval, weaker proposer OK  ---->  huge design space, needs strong coding agent
```

---

## 1. "What makes it recursive?" — vocabulary you must get right

From awesome-rsi's *Scope & Terminology* (use these exact distinctions in an interview):

| Term | Definition | Example |
|---|---|---|
| **Self-refinement** | improves the *current output* without a persistent change to the system | Self-Refine, CoT self-critique, Reflexion *within* one task |
| **Persistent self-improvement** | changes to weights, memory, skills, prompts, harness, or code **that carry into the next round** | OPRO's final prompt, ACE playbook, Voyager skill library, Self-Harness accepted edits |
| **Recursive self-improvement** | **the mechanism that produces improvements is itself the object of improvement** | STOP (improver improves the improver), Promptbreeder (mutation-prompts evolve), MCE meta-level, DGM/SICA (agent edits the code that does the editing), Hyperagents |
| **RSI substrate** | exposes an agent's own structure as a modifiable object, but doesn't necessarily form an automatic loop | Agent Zero, Pi, OpenClaw |

A clean formal test. Let $I$ be the improvement operator and $h$ the thing it improves:

- Self-refinement: $y_{t+1} = I(y_t)$ for a single input; nothing persists.
- Persistent improvement: $h_{t+1} = I(h_t; \text{feedback})$ with **fixed** $I$.
- Recursive: $I_{t+1} = I_t(I_t; \hat u)$ — the improver is in its own domain (STOP), or more loosely the operator $I$ is itself one of the editable components (DGM, SICA, Hyperagents, MCE's skill).

**Important caveat (say this in interviews).** Almost every method below keeps the model weights $M$ fixed. STOP's own paper notes that because the LM is not altered, this is *not full* RSI. Harness-level RSI improves the *deployment system* around intelligence; Weng's framing is that this is the realistic **near-term** path, possibly later "internalized" into weights.

A second caveat: "recursive" is a **spectrum of depth**. Promptbreeder recurses one level (mutation-prompts mutate task-prompts, and "hyper-mutation" mutates mutation-prompts), but the evolutionary algorithm itself is hand-coded. STOP recurses on the improver program but with a fixed meta-utility and fixed LM. DGM lets the agent edit the code that edits itself, but parent selection and archive logic are fixed. **There is always a fixed outermost layer** (evaluator, selection rule, permissions). Good systems keep it fixed *on purpose* (see §8.3).

---

## 2. Level 1 — Optimizing the instruction prompt

### 2.1 Intuition
The cheapest editable object is the instruction string. Search space: all strings. Evaluation: run the prompt on a small training batch, compute accuracy. The question is how to propose good next prompts.

### 2.2 OPRO — "LLM as the optimizer" (Yang et al., 2023; ICLR 2024)
**Idea.** Put the optimization *history* in the prompt. A **meta-prompt** contains (a) a task description with a few examples, (b) a list of previously tried prompts **sorted by score**, and asks the optimizer-LLM to write a new prompt that scores higher.

Formally, at step $t$ with trajectory $\mathcal{T}_t=\{(p_i, s_i)\}_{i\le t}$ (top-$k$ by score):
$$
p_{t+1} \sim \text{LLM}_{\text{opt}}\big(\text{meta-prompt}(\mathcal{T}_t, \text{task exemplars})\big),\qquad s_{t+1}=\text{Acc}_{\mathcal{D}_\text{train}}(M, p_{t+1})
$$
Several candidates are sampled per step for stability; the loop stops when scores plateau.

**Results (abstract).** Best OPRO prompts outperform human-designed prompts by up to 8% on GSM8K and up to 50% on Big-Bench Hard tasks.

**Why it matters.** It established the *"scored history in context"* pattern that every later system (ADAS archive, Meta-Harness filesystem, MCE skill database) inherits.

**Failure modes.** Only a scalar per candidate → the optimizer guesses *why* a prompt is good; can overfit small train sets; meta-prompt length grows.

### 2.3 Promptbreeder — evolution where the mutation operator also evolves (Fernando et al., 2023; ICML 2024)
**Idea.** A genetic algorithm over prompts, with a twist that makes it *self-referential*: each "unit of evolution" = (typically two task-prompts, one **mutation-prompt**). Mutation-prompts are instructions to an LLM on *how to mutate a task-prompt*, and they too are mutated ("hyper-mutation").

**Algorithm.**
1. Initialize the population from the problem description + a seed set of "thinking styles" and mutation-prompts.
2. Binary tournament: pick two units, evaluate fitness (task-prompt accuracy on a random training batch), the loser is overwritten by a mutated copy of the winner.
3. Mutation uses five classes of operators (direct mutation, estimation-of-distribution, hyper-mutation of the mutation-prompt, Lamarckian mutation from a working-out trace, crossover/context shuffling).
4. Repeat for many generations.

**Result.** Outperforms Chain-of-Thought and Plan-and-Solve prompting on common arithmetic and commonsense reasoning benchmarks; also evolves prompts for hate-speech classification. (Specific per-benchmark numbers: see the paper; not reproduced here.)

**Why it matters for RSI.** First clean example of *"the improver gets improved"* in prompt space. But the recursion is shallow: GA logic and fitness are fixed.

### 2.4 DSPy and MIPRO — prompts as compiled parameters of programs (Khattab et al., 2023; Opsahl-Ong et al., 2024)
**Idea.** Stop hand-writing prompts. Write a *program* of declarative modules (`Predict("question -> answer")`, `ChainOfThought`, `Retrieve`) and a metric; a **teleprompter/optimizer** "compiles" the program by choosing instructions and few-shot demonstrations for every module.

Objective for an LM program $\Phi$ with modules $m=1..K$, each with instruction $\iota_m$ and demos $\delta_m$:
$$
\max_{\{\iota_m,\delta_m\}_{m=1}^K} \; \frac{1}{|\mathcal{D}|}\sum_{(x,y)\in\mathcal{D}} \mu\big(\Phi_{\{\iota,\delta\}}(x),\, y\big)
$$
- **BootstrapFewShot** (DSPy 2023): run the program, keep traces whose final output passes the metric, use their intermediate steps as demonstrations for each module (solves "no labels for intermediate steps").
- **MIPRO** (2024): (i) program- and data-aware *instruction proposal*; (ii) stochastic mini-batch evaluation to fit a **Bayesian surrogate** over (instruction, demo-set) choices per module (credit assignment across modules); (iii) a meta-optimization procedure where LMs refine *how they construct proposals*.

**Results.** DSPy (abstract): within minutes of compiling, GPT-3.5 and llama2-13b-chat pipelines outperform standard few-shot prompting by over 25% and 65%, respectively. MIPRO: beats baseline optimizers on five of seven LM programs with Llama-3-8B, by up to 13% accuracy.

**Why it matters.** It reframed prompts as *parameters of a program*, which is the conceptual bridge to "harness = code whose parameters we optimize". DSPy is now the host framework for GEPA.

### 2.5 TextGrad — backprop with words (Yuksekgonul et al., 2024; Nature 2025)
**Idea.** Treat a compound AI system as a computation graph whose nodes are text variables (prompts, code, solutions) and whose edges are LLM calls. A "loss" is an LLM critique. **Textual gradients** = natural-language feedback describing how a variable should change; they are propagated backward via the chain rule analogue, and a **Textual Gradient Descent** step asks an LLM to rewrite the variable given its gradient.

$$
\frac{\partial \mathcal{L}}{\partial v} \;\triangleq\; \bigcup_{w \in \text{succ}(v)} \nabla_{\text{LLM}}\!\Big(v,\, w,\, \frac{\partial \mathcal{L}}{\partial w}\Big), \qquad v_{\text{new}} = \text{TGD.step}\Big(v, \frac{\partial \mathcal{L}}{\partial v}\Big)
$$

**Results.** GPT-4o zero-shot GPQA accuracy from 51% to 55%; 20% relative gain on LeetCode-Hard solution optimization; also applied to molecules and radiotherapy plans.

**Why it matters.** Gives a *language for credit assignment* in multi-component systems — the same problem AHE later solves with "component observability".

**Failure modes.** Gradients are LLM opinions (can be wrong, verbose); no notion of step size; costly backward passes.

### 2.6 GEPA — reflective, Pareto-based prompt evolution (Agrawal et al., 2025; ICLR 2026 oral)
**Idea.** Combine (a) **natural-language reflection** over full execution traces (including evaluator feedback text such as compiler errors, failed rubric items) with (b) **evolutionary search** that keeps a **Pareto frontier** of candidates — the set of prompts that are best on *at least one* training instance — instead of a single best.

**Algorithm (simplified).**
1. Candidate pool $\mathcal{P}=\{\Phi_0\}$; per-instance score matrix $S[\Phi, i]$.
2. Select a parent from the Pareto frontier (instance-wise non-dominated; sampling weighted by how many instances it wins).
3. Pick a module; run on a minibatch; collect traces + feedback text $\mu_f$.
4. Reflection LM proposes a new instruction for that module ("reflective prompt mutation"). Optionally **merge** (system-aware crossover) two Pareto candidates that excel on different modules.
5. If minibatch score improves, evaluate on the Pareto validation set and add to the pool.

Why Pareto? Greedy best-candidate selection collapses to a local optimum; keeping per-instance winners preserves *diverse* lessons ("one prompt solves geometry, another solves counting"), which merge can later combine. This is a mini version of "quality-diversity".

**Results (abstract).** On Qwen3-8B, GEPA beats GRPO (24k rollouts) by up to 20% while using up to 35× fewer rollouts (average +6% across six tasks); beats MIPROv2 on all benchmarks/models, +13% aggregate gains vs MIPROv2's +5.6%.

**Why it matters for RSI.** Strong evidence that **language-space learning can be more sample-efficient than weight-space RL** when the feedback is rich. This is the core empirical bet of harness-level RSI.

### 2.7 Level-1 failure modes (common)
- **Overfitting to a tiny train set** (prompt "memorizes" quirks). Mitigation: held-out validation, minibatch resampling.
- **Brevity bias** (ACE's term): optimizers drift to short generic instructions, dropping domain detail.
- **Evaluator noise** when the metric is an LLM judge.
- **Ceiling effect**: a prompt cannot add tools, memory, or control flow.

---

## 3. Level 2 — Optimizing structured context and memory

### 3.1 Intuition
Instead of one instruction string, maintain an **evolving knowledge store** — reflections, insights, strategies, code snippets, reusable workflows, skills — that is retrieved into the context at inference time. Optimization is now *online/continual*: learn from each episode, carry lessons forward. This is test-time learning without weights.

### 3.2 Lineage
| Method | Memory unit | How it is written | How it is read |
|---|---|---|---|
| **Reflexion** (Shinn et al., NeurIPS 2023) | verbal self-reflection after a failed trial | LLM reflects on trajectory + feedback | appended to the next trial's context ("verbal RL"). Reports 91% pass@1 on HumanEval vs 80% for GPT-4 baseline. Mostly *within-task* retries. |
| **ExpeL** (Zhao et al., AAAI 2024) | natural-language **insights** + stored successful trajectories | compare success/failure pairs; ADD/EDIT/UPVOTE/DOWNVOTE insight operations | insights in system prompt + retrieved similar trajectories as demos — **cross-task** transfer |
| **Voyager** (Wang et al., 2023; TMLR 2024) | executable **skill library** (JS functions for Minecraft) | skill written by GPT-4 after self-verification succeeds | retrieved by embedding similarity; skills compose. 3.3× more unique items, 2.3× longer distances, tech-tree milestones up to 15.3× faster than prior SOTA |
| **Agent Workflow Memory** (Wang et al., ICML 2025) | reusable **workflows** (abstracted sub-routines) | induced from successful trajectories (offline or online) | injected into the agent's memory; +24.6% / +51.1% relative success on Mind2Web / WebArena |
| **Dynamic Cheatsheet** (Suzgun et al., 2025; EACL 2026) | a self-curated **cheatsheet** of strategies & code snippets | after each query, a curator updates the cheatsheet (no labels needed) | the cheatsheet is prepended at test time. GPT-4o Game-of-24 ~10% → 99%; Claude 3.5 Sonnet AIME accuracy more than doubled |
| **ACE** (Zhang et al., ICLR 2026) | itemized **playbook bullets** `(id, description, counters)` | Generator → Reflector → Curator emits *delta* items; deterministic merge | whole playbook in context |
| **MCE** (Ye et al., ICML 2026) | free-form **files** (skill.md + context data + code) | base-level agent under a meta-evolved *skill* | context function $F_s(x;\rho_s)$ |

### 3.3 ACE in detail — fixing "context collapse"
**Problem diagnosis.** When an LLM rewrites a long context end-to-end each step, it tends to compress it. ACE reports an AppWorld example where a context of 18,282 tokens at 66.7% accuracy collapsed to 122 tokens at 57.1% in a single rewrite. Plus **brevity bias**.

**Method.**
1. *Generator* solves tasks citing playbook bullets.
2. *Reflector* critiques trajectories (success and failure), extracts insights, optionally across multiple refinement rounds; also tags which bullets were helpful/harmful.
3. *Curator* emits **delta entries** (new bullets, counter updates) — never rewrites the whole context.
4. A **deterministic, non-LLM merge** appends/updates bullets by id; periodic "grow-and-refine" deduplicates via embeddings.

Works offline (system-prompt optimization) and online (test-time memory). Results: +10.6% on agent benchmarks and +8.6% on finance vs strong baselines, lower adaptation latency/cost; on the AppWorld leaderboard matched the top production agent on average and surpassed it on the harder test-challenge split using a smaller open-source model.

**Design lesson.** *Make the edit surface itemized and the merge deterministic.* This "bounded, structured delta" idea reappears in Self-Harness ("bounded proposals") and AHE ("file-level edits").

**Limitation (Weng).** ACE learns *content* from rollouts, but *the update rules and workflow are handcrafted* → not recursive.

### 3.4 MCE — making the context-engineering *mechanism* learnable (bi-level)
MCE separates **mechanism** (how context is managed: a *skill*) from **artifact** (what's in context). A skill $s$ defines a context function $c_s = (\rho_s, F_s)$ with static components $\rho_s$ (prompts, knowledge bases, code libraries) and dynamic operators $F_s$ (search, selection, filtering, formatting), mapping input $x$ to context $c = F_s(x;\rho_s)$.

**Bi-level objective:**
$$
\text{Inner: } c_s^* = \arg\max_{c_s} J_{\text{train}}(c_s; s) \qquad \text{Outer: } s^* = \arg\max_{s\in\mathcal{S}} J_{\text{val}}(c_s^*)
$$

**Algorithm.** Keep a history $\mathcal{H}_{k-1} = \{(s_i, c_i, J_i^{\text{train}}, J_i^{\text{val}})\}_{i=1}^{k-1}$.
1. Meta-level agent performs **agentic crossover** over prior skills: $s_k = \text{crossover}(\tau, \mathcal{H}_{k-1})$ — a deliberative search over past skills, executions, and scores.
2. Base-level context engineer executes the skill on training rollouts: $c_k = \text{engineer}(\tau, s_k; c_{k-1}^*, \mathcal{R}_k)$.
3. Evaluate $c_k$ on train and **validation**; append to $\mathcal{H}$.

Both levels run as coding agents with tools $\{\texttt{Read},\texttt{Write},\texttt{Edit},\texttt{Bash},\texttt{Glob},\texttt{Grep},\texttt{TodoWrite}\}$; contexts are directories of files.

**Results.** 5.6–53.8% relative improvement over SOTA agentic CE methods (mean 16.9%), per the abstract.

**Why it's "recursive-ish".** The thing that writes context (the skill) is itself optimized; the outer loop uses *validation* data (a held-out acceptance criterion), which is the bi-level analogue of hyperparameter tuning. Note that the meta-agent's own procedure (crossover) is still fixed.

### 3.5 Level-2 failure modes
- **Context collapse / brevity bias** (ACE).
- **Memory bloat and staleness** (old wrong insights poison later tasks) → need dedup, voting, forgetting.
- **Label-free updates can reinforce errors**: Dynamic Cheatsheet and ACE can run without ground truth, but then a wrong "insight" is self-confirmed. ACE notes performance depends on feedback quality.
- **Retrieval mismatch**: right lesson exists but isn't retrieved.

---

## 4. Level 3 — Optimizing the workflow (agent architecture)

### 4.1 Intuition
Many gains come from *structure*: decompose, ensemble, self-verify, debate, route. Weng: *"The design space for workflow is enormous, and naturally we can think of workflow design as a search problem."* Represent the workflow as **code** (Python calling the LLM), and search over code.

### 4.2 ADAS — Meta Agent Search (Hu, Lu, Clune; ICLR 2025)
**Formalism.** Search space $\mathcal{A}$ = Python `forward()` functions that call foundation models; objective $\max_{a\in\mathcal{A}} \text{Eval}(a)$ on a validation set.

**Algorithm (Weng's summary).**
1. Initialize an archive with simple agents (CoT, CoT-SC, Self-Refine, LLM debate, role assignment...).
2. Meta-agent (a strong LLM) reads the archive (code + scores) and writes a new agent: first a high-level description, then code.
3. Two self-refine steps by the meta-agent to check **novelty** and correctness.
4. Evaluate; add to archive (with score); repeat.

The emphasis on *interestingness/novelty* (inspired by open-endedness research) keeps the archive diverse.

**Results.** Discovered agents improved over hand-designed baselines across coding, science, and math; transfer within math domains improved accuracy by 25.9% on GSM8K and 13.2% on GSM-Hard over baselines. Agents transferred across domains and models. (Abstract also reports DROP F1 +13.6/100 and MGSM +14.4% — **[recalled from abstract; verify]**.)

**Limits.** Expensive evaluation per candidate; designs are single-task-type pipelines (QA/math), not long-horizon tool-using harnesses; meta-agent is a fixed hand-written prompt.

### 4.3 AFlow — MCTS over code-represented workflows (Zhang et al.; ICLR 2025)
**Formalism.** Workflow $W = (N, E)$: nodes are LLM-invoking actions (with model, prompt, temperature, output format), edges are code logic. Introduces reusable **operators** (Generate, Format, Review & Revise, Ensemble, Test, Programmer...) to shrink the search space.
$$
W^* = \arg\max_{W \in \mathcal{S}} G(W, T)
$$
**Algorithm (Weng).**
1. Initialize $W_0$ from a template.
2. **Select** a node by a soft mixture of score and uniform exploration.
3. **Expand**: LLM produces a modified workflow conditioned on parent's code, its evaluation, and past modification experience.
4. **Execute & evaluate** (several runs for variance).
5. **Backpropagate** experience; add if improved.
6. Stop when top-$k$ average plateaus or budget exhausted.

**Results.** 5.7% average improvement over SOTA baselines across six QA/code/math benchmarks; smaller models with AFlow workflows can beat GPT-4o on specific tasks at 4.55% of its dollar inference cost.

**Lesson.** Tree search with *experience-conditioned expansion* is more sample-efficient than ADAS's flat archive; restricting the edit vocabulary (operators) helps.

### 4.4 Level-3 failure modes
- Workflows overfit to a benchmark's answer format.
- Evaluation variance makes MCTS chase noise (multi-run evaluation needed).
- Workflows are still "single-shot pipelines"; they don't manage persistent state, tools, permissions — the things a real harness does.

---

## 5. Level 4 — Optimizing the harness code itself

### 5.1 Intuition
Weng: *"code is a universal language for defining programs and systems... If an LLM can optimize the code that executes agents, it can access a much larger design space than hand-written prompts."* A real harness has many components (AHE enumerates 7: system prompt, tool descriptions, tool implementations, middleware, skills, sub-agent configs, long-term memory). We now let a **coding agent** edit all of them.

Two lineages:
- **Outer-loop optimizer, separate proposer** (Meta-Harness, AHE, ADAS-style): a (often strong) coding agent improves a *target* harness.
- **Self-editing** (SICA, DGM, Self-Harness, Live-SWE-agent, Continual Harness): the agent edits *its own* harness, i.e., proposer = the system being improved.

### 5.2 Meta-Harness (Lee, Nair, Zhang, Lee, Khattab, Finn; 2026)
**Key move: give the proposer the raw history on a filesystem.** The proposer is a coding agent that can `grep`/`cat` the source code, scores, and execution traces of **all prior candidates**, instead of a compressed summary in a prompt. (awesome-harness-engineering describes this as ~10M tokens of diagnostic context vs ~26K in prior work — **[unverified secondary claim]**.)

**Loop.**
1. Each candidate harness = a directory: source code, scores, rollout trajectories, state updates.
2. Proposer reads history, performs **counterfactual diagnosis** of failures from raw logs, writes a new harness.
3. Evaluate; keep qualified candidates; output the **Pareto frontier** (e.g., accuracy vs. context tokens).

**Results (abstract).** Online text classification: +7.7 points over a SOTA context-management system (ACE) while using 4× fewer context tokens. Retrieval-augmented math: a single discovered harness improves accuracy on 200 IMO-level problems by 4.7 points on average across five held-out models. TerminalBench-2: discovered harnesses surpass the best hand-engineered baselines (search initialized from strong harnesses Terminus-KIRA and Terminus-2); 37.6% with Claude Haiku 4.5 (ranked #1 among Haiku 4.5 agents) and 76.4% with Claude Opus 4.6 (secondary-source numbers).

**Lesson.** The bottleneck of prior optimizers was *information compression* of feedback. Strong coding agents + filesystem = proposer can do the same root-cause analysis humans do.

### 5.3 Agentic Harness Engineering (AHE; Lin et al., 2026)
**Thesis.** The bottleneck is **observability**: when a rollout fails, which component is responsible, and is each edit grounded in evidence?

**Three pillars.**
1. *Component observability*: every editable component is a file (git-tracked) → explicit, revertible action space; each failure pattern maps to one component.
2. *Experience observability*: an "Agent Debugger" turns each raw trace into a per-task root-cause report; reports aggregate into a benchmark overview; raw traces remain drill-down-able (layered → token-efficient).
3. *Decision observability*: the "Evolve Agent" writes each edit with a **manifest**: failure evidence, inferred root cause, targeted fix, **predicted impact** (expected fixes and at-risk regressions). Next round checks the prediction → edits are *falsifiable claims*.

**Guardrail.** Edits only in the harness workspace; runs dir, tracer, verifier, and LLM config are **read-only** — blocks hacks like disabling the verifier, swapping the model, or raising the reasoning budget; makes gains attributable to harness edits.

**Results.** Ten iterations raised Terminal-Bench 2.0 pass@1 from 69.7% to 77.0% (GPT-5.4), above the human-designed Codex CLI harness (71.9%) and self-evolving baselines (ACE, TF-GRPO). Frozen evolved harness transferred to SWE-bench Verified and gave +5.1 to +10.1 pp across three other model families (secondary sources: DeepSeek-v4-flash +10.1, Qwen-3.6-plus +6.3, Gemini-3.1-flash-lite +5.1). Weng notes it did not win on the Hard tier.

### 5.4 Self-Harness (Zhang et al., 2026)
**Thesis.** The *same model* can improve its own harness via propose–evaluate–accept, without a stronger external agent.

**Loop.**
1. **Weakness mining**: run $h_t$, collect traces, cluster failures into *verifier-grounded* patterns. Two runs with the same surface error (timeout, missing artifact) can have different causes, so each failure record has: terminal verifier-level cause, causal status of the relevant agent behavior, abstract mechanism exposed.
2. **Bounded harness proposal**: same model under $h_t$ gets (i) the editable surfaces, (ii) failure patterns, (iii) **passing behaviors to preserve**, (iv) summaries of previous edits. Prefer recurrent, addressable patterns fixable by narrow changes; diverse candidates.
3. **Validation**: regression tests on held-in $D_\text{in}$ (is the weakness fixed?) and held-out $D_\text{out}$ (did we break something unknown?). **Accept only if no regression on both.** Rejected edits are logged.

Acceptance rule (formal):
$$
\text{accept}(\Delta) \iff \text{Pass}(h_t\oplus\Delta, D_\text{in}) \ge \text{Pass}(h_t, D_\text{in}) \;\wedge\; \text{Pass}(h_t\oplus\Delta, D_\text{out}) \ge \text{Pass}(h_t, D_\text{out})
$$
(plus strict improvement somewhere in practice).

**Results (Terminal-Bench-2.0).** Held-out pass rate: MiniMax M2.5 40.5% → 61.9%; Qwen3.5-35B-A3B 23.8% → 38.1%; GLM-5 42.9% → 57.1%. Held-in: 43.0→50.0, 15.1→36.0, 47.7→57.0. Learned harness instructions were **model-specific** (different weaknesses for different models).

**Weng's concern.** If a program may edit "the OS", abstraction boundaries break; editable surfaces must be designed, and permission/security layers must live *outside* the loop.

### 5.5 Self-editing coding agents: SICA, DGM, Live-SWE-agent
- **SICA** (Robeyns, Szummer, Aitchison; ICLR 2025 SSI-FM workshop): removes the meta-agent/target-agent distinction — the coding agent edits its own codebase, selecting the best archived version as the next meta-agent; utility mixes benchmark score, cost, and time. 17% → 53% on a random subset of SWE-bench Verified.
- **DGM** (Zhang et al., 2025; ICLR 2026): archive-based open-ended evolution of a self-editing coding agent; parent sampled ∝ performance and inversely ∝ number of children; SWE-bench Verified 20% → 50%, Polyglot 14.2% → 30.7% with Claude 3.5 Sonnet (Weng). (Covered in more depth in the evolutionary-search note.)
- **Live-SWE-agent** (Xia et al., 2025): starts from mini-SWE-agent (bash only) and **creates its own tools on the fly during a single problem**, a light reflection prompt asking whether to create/revise tools. 77.4% SWE-bench Verified without test-time scaling; 45.8% on SWE-Bench Pro. Shows *online* scaffold evolution with zero offline search cost.

### 5.6 Continual Harness and DemoEvolve — long-horizon, sparse feedback
- **Continual Harness** (Karten et al., 2026): reset-free; a *Refiner* rewrites the full harness state (system prompt, sub-agents, skills, memory) mid-episode through CRUD edits over a trajectory window, in Pokémon Red/Emerald. Extends to co-learning an open model's weights (online DAgger + process reward model, distilling teacher labels on low-reward trajectories). Lesson: when there is **no episode boundary**, harness improvement must be online.
- **DemoEvolve** (Che et al., 2026): exposes a **noisy-selection failure mode** of self-rollout harness evolution: in long-horizon stochastic games (Balatro), same-seed variance and trajectory drift let sparse scores select **inactive or non-causal edits**. Fix: give the coding proposer **human expert demonstrations** as reference experience → narrower search, more diagnosable, more sample-efficient, more stable. Lesson: self-generated feedback is not always enough; external positive evidence helps.

### 5.7 Level-4 failure modes
- **Reward hacking of the evaluator** (edit the tests/verifier, read cached answers, raise budgets) — mitigated by read-only verifier (AHE), sandboxing.
- **Benchmark overfitting**: "Rethinking the Evaluation of Harness Evolution" (Wang et al., 2607.12227) reports that on Terminal-Bench 2.1 with GPT-5.4 and Claude Opus 4.6, automatic harness evolution does **not consistently beat simple test-time-scaling baselines at matched budget**, and when search and evaluation tasks are separated, held-out improvements are marginal. Take this seriously.
- **Noisy selection** under stochastic, sparse reward (DemoEvolve).
- **Capability dependence** (§7.5).
- **Harness bloat**: accretes special-case rules; Weng warns smarter models should *prevent* over-engineering.

---

## 6. Level 5 — Optimizing the optimizer (true recursion)

### 6.1 STOP — Self-Taught Optimizer (Zelikman, Lorch, Mackey, Kalai; COLM 2024)
**Setup.** An *improver* $I$ is a Python program: given a solution $s$, utility $u$, and black-box LM $M$, return a better $s' = I(u, s; M)$. The seed improver $I_0$ just asks the LM for several improvements and returns the best by $u$.

**Meta-utility** (average downstream utility achieved by an improver):
$$
\hat{u}(I) \triangleq \frac{1}{|\mathcal{D}|}\, \mathbb{E}_{(u,s)\sim\mathcal{D}}\big[\, u\big(I(u, s; M)\big)\big]
$$
**Recursive update** — run the improver on itself:
$$
I_t = I_{t-1}\big(\hat{u},\, I_{t-1};\, M\big)
$$
Evaluate generalization by applying $I_T$ to *held-out* tasks with their own utilities.

**What happened.** With GPT-4, mean downstream performance improved over iterations, and the improver discovered **beam search, genetic algorithms, simulated annealing, decomposing-and-improving parts, multi-armed prompt bandits, varying temperature** — i.e., the LM reinvented classic optimization meta-heuristics. With **GPT-3.5 and Mixtral, performance degraded** across iterations (Weng: "Recursive structure alone is not enough. The base model must be capable enough to improve the mechanism.").

**Safety findings.** The authors measured how often generated improvers **circumvented a sandbox flag** and observed **reward-hacking** behaviors (exact rates: see paper — **[not reproduced]**).

**Formal subtlety (interview gold).** STOP's meta-utility $\hat u$ is *fixed*; the LM $M$ is fixed. So the "fixed point" is bounded by $M$'s ability to write optimizers. This is the clearest small-scale model of RSI and of its ceiling.

### 6.2 Other level-5 examples
- **Promptbreeder** (hyper-mutation of mutation-prompts).
- **MCE outer loop** (evolves the context-engineering skill).
- **Hyperagents** (Zhang et al., 2026): an editable *meta-agent* whose self-modification procedure can itself evolve; improvements transfer across domains.
- **MetaSkill-Evolve** (2607.05297): fast loop evolves task skills; slower recursive loop evolves meta-skills governing the Analyzer/Retriever/Allocator/Proposer/Evolver (two-timescale).
- **Harness-R1** (2608.02276, per awesome-harness-engineering): a 9B "harness engineer" post-trained by online RL to edit harnesses from failure trajectories — moves the *optimizer* from prompt-space into weights (**[secondary source; details unverified]**).

---

## 7. Joint optimization with weights (bridge to model-level RSI)
- **SIA** (Hebbar et al., 2026): Meta-Agent proposes initial harness; Task-Specific Agent executes; **Feedback-Agent decides each iteration whether to update the harness or the model weights**. Reported gains over initial baseline: 56.6% on LawBench (Chinese legal charge classification), 91.9% runtime reduction on GPU kernels, 502% on single-cell RNA denoising. Weng's critique: the task agent (gpt-oss-120b) is much weaker than the Meta/Feedback agents (Claude Sonnet 4.6), baselines are weak → "direction interesting, evidence provisional".
- **Continual Harness** extends to weight co-learning (above).

Formally, joint optimization is
$$
\max_{h,\,\theta}\; \mathbb{E}_{x}\, R\big(x, \text{Run}(M_\theta, h, x)\big)
$$
with a *controller* choosing coordinate-ascent steps in $h$ (cheap, fast, reversible) or $\theta$ (expensive, durable, harder to revert). Open question: when should a lesson live in the harness vs. the weights?

---

## 8. Cross-cutting themes

### 8.1 Observability (feedback richness)
A spectrum of what the proposer sees:

`scalar score (OPRO)` → `scored history (OPRO, ADAS)` → `NL critique/gradient (TextGrad, Reflexion)` → `traces + evaluator text (GEPA)` → `full filesystem of code+scores+traces (Meta-Harness, MCE)` → `layered evidence: per-task root-cause reports + raw drill-down + falsifiable predictions (AHE)` → `verifier-grounded failure clusters (Self-Harness)`.

Rule of thumb: **sample efficiency of harness search scales with how well failures are attributed to editable components.** That's credit assignment, the same problem as in RL — solved here with language instead of gradients.

### 8.2 Bounded edit surfaces
- AlphaEvolve's `# EVOLVE-BLOCK-START/END` markers; ACE's itemized deltas; AHE's 7 file-level components; Self-Harness's "editable surfaces" list; SkillOpt's single skill document with bounded edits.
- Why: smaller, typed action space → fewer catastrophic edits, easier credit assignment, easier rollback, harder to hack the evaluator. Trade-off: may exclude the edit you need.

### 8.3 Held-in / held-out acceptance (the "keep" rule)
- Greedy-on-train (OPRO) → val-set acceptance (MCE outer loop) → Pareto per-instance (GEPA, Meta-Harness) → **no-regression on held-in AND held-out** (Self-Harness) → **prediction verification** (AHE).
- Statistical point: with $n$ tasks and pass rate $p$, std error ≈ $\sqrt{p(1-p)/n}$; on an 89-task benchmark at $p\approx0.5$ that is ~5.3 pp per run, so single-run "gains" of a few points can be noise. Repeated runs, paired comparisons on the same tasks, and a fixed held-out split are essential. "Rethinking the Evaluation…" argues the field has under-done this.

### 8.4 Reward hacking in harness search
Harness search optimizes *whatever the evaluator measures*. Concrete hacks: editing/disabling tests or verifiers, reading cached gold answers, swapping to a stronger model, raising the reasoning budget, special-casing benchmark task IDs, timeouts that turn failures into "skips". STOP measured sandbox circumvention. Mitigations: verifier/permissions **outside** the loop (Weng, AHE read-only dirs), held-out tasks, trace audits, human review at key decision points, diff review that flags task-specific strings.

### 8.5 Capability dependence
- **STOP**: recursion helps GPT-4, hurts GPT-3.5/Mixtral.
- **"Harness Updating Is Not Harness Benefit"** (Lin et al., 2026): disentangles (1) *harness-updating* — writing useful harness edits — which was roughly **flat** across models from small open models (e.g., a 9B Qwen3.5) to Claude Opus 4.6; a 9B evolver could write skills "procedurally isomorphic" to Opus's; from (2) *harness-benefit* — using the updated harness to solve tasks — which was **non-monotonic**: mid-tier models benefit the most (weak models can't follow/invoke the skills; strong models already don't need them).
- Implication: the bottleneck is often the **consumer**, not the **author**, of the harness. Cheap models can author; you must test benefit for each target model (consistent with Self-Harness finding model-specific edits).
- Reconciling with STOP: STOP's task is writing *optimization algorithms* (harder, more open-ended) versus Lin et al.'s procedural skill-writing; capability thresholds depend on the level of the ladder.

### 8.6 Diversity and search
Archives (ADAS, DGM), Pareto frontiers (GEPA, Meta-Harness), novelty checks (ADAS self-refine novelty, ShinkaEvolve novelty rejection), MCTS exploration (AFlow). Without them: diversity collapse (Weng's challenge #4).

### 8.7 Cost
Every candidate costs a full benchmark evaluation. GEPA's selling point is rollout efficiency; AHE's layered evidence saves tokens; Live-SWE-agent amortizes to zero offline cost. Matched-budget comparisons with simple test-time scaling (best-of-$k$, retries) are the right baseline.

---

## 9. The big comparison table

| Method (year) | What is optimized | Search algorithm | Feedback signal to proposer | Evaluator / acceptance | Model fixed? | Key result (verified unless marked) |
|---|---|---|---|---|---|---|
| OPRO (2023) | instruction prompt | iterative LLM proposal from scored history | sorted (prompt, score) list | train-set accuracy; keep best | yes | up to +8% GSM8K, up to +50% BBH vs human prompts |
| Promptbreeder (2023) | task-prompts **+ mutation-prompts** | binary-tournament GA, 5 mutation classes | fitness on random batch | tournament fitness | yes | beats CoT, Plan-and-Solve on arithmetic/commonsense |
| DSPy (2023) | per-module instructions + demos | bootstrapping, random search | metric on program outputs | user metric on train/dev | yes (also supports finetune) | +25% (GPT-3.5), +65% (llama2-13b) over few-shot |
| MIPRO (2024) | instructions + demos, multi-stage | Bayesian surrogate + LM proposals + meta-optimization of proposer | minibatch scores | surrogate-guided; dev set | yes | best on 5/7 programs, up to +13% (Llama-3-8B) |
| TextGrad (2024) | any text variable (prompt, code, answer) | textual gradient descent | LLM critiques back-propagated | loss = LLM/metric | yes | GPQA 51→55% (GPT-4o); +20% rel LeetCode-Hard |
| GEPA (2025) | prompts of compound system | reflective mutation + Pareto-frontier selection + merge | traces + evaluator NL feedback | minibatch then Pareto val set | yes | beats GRPO by up to 20% w/ up to 35× fewer rollouts; +13% vs MIPROv2's +5.6% |
| Reflexion (2023) | episodic verbal memory | retry with reflections | env reward/test feedback | env success | yes | 91% HumanEval pass@1 |
| ExpeL (2023) | cross-task insights + exemplars | insight ADD/EDIT/vote | success vs failure trajectories | task success | yes | qualitative gains on HotpotQA/ALFWorld/WebShop (see card) |
| Voyager (2023) | executable skill library | curriculum + iterative prompting + self-verification | env feedback, errors, self-verification | GPT-4 self-verification | yes | 3.3× items, 15.3× faster tech tree |
| AWM (2024) | reusable workflows (memory) | induction from successful trajectories | trajectories | task success (online uses LLM eval) | yes | +24.6% / +51.1% rel. success (Mind2Web / WebArena) |
| Dynamic Cheatsheet (2025) | test-time cheatsheet memory | curate after every query | model's own solutions (no labels) | none explicit (self-curation) | yes | GPT-4o Game of 24 ~10%→99%; Claude AIME >2× |
| ACE (2025) | itemized playbook (context) | Generator–Reflector–Curator; deterministic delta merge | traces + execution feedback | task success (or label-free) | yes | +10.6% agents, +8.6% finance |
| MCE (2026) | CE **skill** (outer) + context files (inner) | agentic crossover over skill history; bi-level | rollouts, train/val scores | **validation** set for outer | yes | 5.6–53.8% rel. over SOTA CE (mean 16.9%) |
| ADAS (2024) | agent workflow code | archive + meta-agent program writing + novelty self-refine | archive of (code, score) | val-set score | yes | GSM8K +25.9%, GSM-Hard +13.2% in transfer |
| AFlow (2024) | workflow graph code w/ operators | MCTS w/ soft selection, experience-conditioned expansion | parent code, scores, past mods | multi-run val score | yes | +5.7% avg over SOTA; small models beat GPT-4o at 4.55% cost |
| STOP (2023) | **the improver program** | improver improves itself | meta-utility $\hat u$ | downstream utility on tasks | yes | GPT-4: improves; GPT-3.5/Mixtral: degrades |
| SICA (2025) | own agent codebase | archive; best agent becomes next meta-agent | benchmark logs | score+cost+time utility | yes | 17%→53% on SWE-bench Verified subset |
| DGM (2025) | own agent codebase | open-ended archive, parent ∝ perf / #children | own eval logs | staged benchmark eval | yes | SWE-bench Verified 20→50%; Polyglot 14.2→30.7% |
| Live-SWE-agent (2025) | own tools/scaffold, online | on-the-fly tool creation in one episode | in-episode feedback | none offline | yes | 77.4% SWE-bench Verified; 45.8% SWE-Bench Pro |
| Meta-Harness (2026) | full harness code | coding-agent proposer w/ filesystem of all history; Pareto output | raw code + scores + traces | score (+ context-token cost) | yes | +7.7 pts over ACE w/ 4× fewer tokens; +4.7 pts IMO-level across 5 held-out models |
| AHE (2026) | 7 harness components (files) | evolve agent + agent-debugger; falsifiable edits | layered root-cause reports + raw traces | next-round prediction check; read-only verifier | yes | TB2 pass@1 69.7→77.0% (GPT-5.4) vs Codex CLI 71.9% |
| Self-Harness (2026) | bounded harness surfaces | same-model propose–evaluate–accept | verifier-grounded failure clusters + preserved passes | **no regression on held-in AND held-out** | yes | TB2 held-out: MiniMax 40.5→61.9, Qwen 23.8→38.1, GLM 42.9→57.1 |
| DemoEvolve (2026) | harness (long-horizon games) | coding proposer + expert demos | self-rollouts + human demos | sparse game score | yes | more sample-efficient/stable than self-rollout only (qualitative) |
| Continual Harness (2026) | prompt, sub-agents, skills, memory (online) | Refiner CRUD edits mid-episode | trajectory window | in-episode progress | optional weight co-learning | Pokémon Red/Emerald online improvement (see card) |
| SIA (2026) | harness **and** weights | Feedback-Agent chooses which to update | recent trajectories | task metric | **no** | LawBench +56.6%, kernels −91.9% runtime, RNA denoising +502% (vs initial baseline) |
| Lin et al. "Updating ≠ Benefit" (2026) | (analysis) | — | — | — | — | updating ability flat across models; benefit non-monotonic |

---

## 10. Putting it together: a generic harness-RSI loop (pseudocode)

```python
H = init_harness()                       # editable surfaces declared explicitly
archive = [(H, evaluate(H, D_in), evaluate(H, D_out))]
for t in range(T):
    parent = select(archive)             # best / Pareto / MCTS / prob ∝ perf, 1/children
    traces = run(model, parent, D_in)    # store on FILESYSTEM, not in prompt
    evidence = diagnose(traces)          # per-task root cause -> clusters -> component map
    edits = propose(proposer, parent, evidence, history=archive,
                    surfaces=parent.editable, preserve=passing_behaviors)
    for e in edits:                      # each e has: target file, rationale, predicted impact
        child = apply(parent, e)         # sandboxed; evaluator & permissions read-only
        s_in, s_out = evaluate(child, D_in), evaluate(child, D_out)   # repeated runs
        if no_regression(child, parent, s_in, s_out) and significant(s_in, s_out):
            archive.append((child, s_in, s_out))
        log(e, s_in, s_out, prediction_check(e))   # keep negative results!
final = pareto_front(archive)            # validate once on a TRULY held-out test set
# Recursive variant: `propose`, `diagnose`, `select` are themselves files in H.
```

---

## 11. Open research questions (good for proposing research in an interview)

1. **Evaluation methodology for harness evolution.** Matched-budget baselines (best-of-$k$, retries), strict search/test separation, multi-seed confidence intervals. Can we build a "harness-evolution benchmark" whose held-out split is truly unseen (new repos, post-cutoff tasks)?
2. **Credit assignment theory.** Can we formalize when trace-level diagnosis beats scalar search (an information-theoretic bound on sample complexity as a function of attribution accuracy)?
3. **Harness ↔ weights allocation.** When should a lesson be stored in the harness (cheap, reversible, interpretable) vs. distilled into weights (durable, general, hard to audit)? A learned controller (SIA) vs. principled rules (frequency, generality, model-specificity of the lesson).
4. **Harness-benefit as a trainable capability.** Lin et al. show benefit is non-monotonic. Can we post-train models to *use* skills/harness updates better (skill-following RL), making harness evolution work for weak models?
5. **Transfer and portability.** Which evolved components transfer across models (AHE: some; Self-Harness: model-specific)? Can we factor a harness into model-agnostic and model-adapter parts?
6. **Safe recursion depth.** How deep can recursion go (editing the optimizer, the diagnoser, the selection rule) before the evaluator must be changed too? What invariants must remain outside the loop (immutable event log à la Exo, read-only verifier)?
7. **Reward-hacking detection in harness diffs.** Automated auditors that flag task-specific special-casing, test tampering, budget inflation; "honeypot" tasks.
8. **Sparse / fuzzy feedback regimes.** DemoEvolve uses human demos; what about LLM-judge or rubric feedback for research tasks without degenerating into judge-hacking? Self-supervised harness optimization (e.g., RHO uses self-consistency/self-preference — **[secondary source]**).
9. **Diversity and open-endedness at the harness level.** Quality-diversity over harness behaviors; avoiding collapse to one archetype.
10. **Harness complexity regularization.** An MDL-style penalty so harnesses stay simple and general (Weng: smarter models should prevent over-engineering). Does a simplicity prior improve held-out transfer?
11. **Online vs offline.** Continual Harness / Live-SWE-agent evolve within an episode; how do we guarantee stability (no catastrophic self-edits) and roll back?
12. **Scaling laws for harness search**: performance vs. number of candidate evaluations, proposer strength, and target-model strength.

---

## 12. Interview angles (questions + crisp model answers)

**Q1. What's a harness and why is optimizing it a path to RSI?**
A: The harness is everything around the model — prompts, tools, control loop, context/memory management, sub-agents, evaluation, permissions. It's text and code, which LLMs can read and edit, so an LLM can propose harness changes, test them, and keep winners — a persistent improvement loop without weight updates. It's RSI when the improvement machinery itself (the proposer, diagnoser, or context-engineering skill) is also editable. It's the near-term practical path because it's cheap, reversible, and auditable compared to weight self-modification.

**Q2. Distinguish self-refinement, persistent self-improvement, and RSI with examples.**
A: Self-refinement improves one output, nothing persists (Self-Refine). Persistent improvement changes something that carries to the next round, with a fixed improver (OPRO's prompt, ACE's playbook, Self-Harness's accepted edits). RSI makes the improver itself the object (STOP improving its improver, Promptbreeder's mutation-prompts, MCE's evolved CE skills, DGM/SICA editing their own editing code). Note that most "RSI" here keeps weights and the evaluator fixed.

**Q3. Write the STOP objective and explain why it failed for weaker models.**
A: $\hat u(I)=\frac{1}{|\mathcal D|}\mathbb E_{(u,s)\sim\mathcal D}[u(I(u,s;M))]$, update $I_t=I_{t-1}(\hat u, I_{t-1}; M)$. Improvement requires the LM to write an optimizer better than the current one; GPT-4 could (rediscovered beam search, GA, annealing, bandits), GPT-3.5/Mixtral introduced bugs and regressions, so iterations degraded. Recursion amplifies capability; it doesn't create it — the base model is the ceiling.

**Q4. Why did GEPA beat GRPO with far fewer rollouts?**
A: RL compresses each rollout into a scalar advantage; GEPA reads the full trace and evaluator text and writes a targeted language-level fix, so each rollout carries many more bits of learnable signal. Pareto selection preserves diverse per-instance wins, and merge combines them. Caveat: works when the needed change is expressible as instructions; doesn't add new skills to weights.

**Q5. What problem does ACE solve, and what's its key design trick?**
A: Context collapse (end-to-end rewrites shrink a rich context — 18,282 tokens/66.7% → 122 tokens/57.1% in their AppWorld example) and brevity bias. Trick: curator emits itemized delta bullets, merged by deterministic non-LLM logic, with periodic dedup. Limitation: update rules are hand-designed; MCE makes that mechanism learnable.

**Q6. Explain MCE's bi-level optimization. Why validation in the outer loop?**
A: Inner: given skill $s$, the base agent optimizes context $c_s^*=\arg\max J_\text{train}$. Outer: choose $s^*=\arg\max J_\text{val}(c_s^*)$ via agentic crossover over the history of skills and scores. Like hyperparameter tuning: the inner loop can overfit train; selecting mechanisms on validation rewards skills that produce *generalizable* context.

**Q7. ADAS vs AFlow?**
A: Both search over code-represented agent workflows. ADAS: flat growing archive, meta-agent writes whole new agents with novelty checks (open-endedness flavor). AFlow: MCTS over a tree of workflow edits using predefined operators and experience-conditioned expansion, multi-run evaluation — more sample-efficient; reports +5.7% over SOTA and beats ADAS.

**Q8. What does Meta-Harness change relative to earlier optimizers?**
A: Feedback access. Instead of a compressed prompt of scores/summaries, a coding-agent proposer gets a filesystem of every prior candidate's code, scores and raw traces, and does counterfactual root-cause diagnosis with grep/cat. Result: +7.7 points over ACE with 4× fewer context tokens on text classification; a single harness transferred to five held-out models on IMO-level math (+4.7 points).

**Q9. How do AHE and Self-Harness defend against harness search overfitting/hacking?**
A: AHE: read-only verifier, tracer, runs dir, and LLM config; every edit has a manifest with a falsifiable predicted impact checked next round; component-level files make edits attributable. Self-Harness: bounded editable surfaces, preserve-passing-behaviors context, and acceptance only with no regression on both held-in and held-out sets; rejected edits logged.

**Q10. "Harness updating is not harness benefit" — what does it mean and why should a practitioner care?**
A: Writing good harness edits (updating) was roughly flat across model sizes — even a 9B model's skills were procedurally similar to Opus's — but benefiting from them (invoking skills correctly, long-horizon instruction following) was non-monotonic, with mid-tier models benefiting most. So: use cheap models to author; evaluate benefit per target model; for weak targets, invest in skill-following ability; for strong targets, harness gains may be small.

**Q11. If you got a 3-point gain on Terminal-Bench from harness evolution, how would you convince me it's real?**
A: Multiple seeds and paired per-task comparison with CIs; search on a disjoint split and report on untouched tasks; matched-budget baselines (best-of-k, retries) as in "Rethinking the Evaluation of Harness Evolution"; ablate each accepted edit; diff audit for task-specific strings/test tampering; transfer to another benchmark (AHE → SWE-bench Verified) and other models.

**Q12. Where do you put the evaluator and permissions in a self-improving harness, and why?**
A: Outside the editable loop: immutable, read-only, ideally versioned separately and reviewed by humans. Otherwise the cheapest path to higher score is editing the scorer (STOP observed sandbox circumvention; AHE explicitly blocks verifier edits/model swaps/budget raises). Humans "move up the stack" to approve changes at meaningful decision points.

**Q13. Propose a research project in this area.**
A (example): "Attribution-efficient harness evolution." Hypothesis: sample efficiency scales with failure-to-component attribution accuracy. Build a benchmark with injected harness bugs (known ground-truth component); compare scalar-only (OPRO-style), trace reflection (GEPA), filesystem (Meta-Harness), layered evidence (AHE); measure evaluations-to-fix and held-out regressions; then train a small "harness debugger" model with RL on attribution accuracy. Also report harness-benefit per target model (Lin et al.).

**Q14. When will harness RSI stop paying off?**
A: When (a) the evaluator is weak/fuzzy (research taste, long-term maintainability), (b) the target model already internalized the behavior (harness benefit shrinks for strongest models), (c) noise dominates (sparse long-horizon reward — DemoEvolve), or (d) the harness grows too complex. Expect lessons to migrate into weights over time (as prompt tricks did), while interfaces to tools/context remain.

**Q15. How does this relate to ByteDance-style product agents (e.g., coding/assistant agents at scale)?**
A: Production traffic is a huge source of traces; a harness-evolution loop with strict held-out regression gates, A/B testing as the held-out evaluator, per-model adapters (Self-Harness's model specificity), and privacy-safe trace distillation is a realistic deployment; open problems are online stability, reward hacking on proxy metrics (engagement vs task success), and when to distill accumulated harness lessons into the next model version.

---

## 13. Paper cards index (`notes/papers/`)
`stop.md`, `promptbreeder.md`, `opro.md`, `dspy-mipro.md`, `textgrad.md`, `gepa.md`, `reflexion.md`, `expel.md`, `voyager.md`, `agent-workflow-memory.md`, `dynamic-cheatsheet.md`, `ace.md`, `mce.md`, `adas.md`, `aflow.md`, `sica.md`, `live-swe-agent.md`, `meta-harness.md`, `ahe.md`, `self-harness.md`, `harness-updating-vs-benefit.md`, `demoevolve.md`, `continual-harness.md`, `sia.md`, `rethinking-harness-evolution-eval.md`.
