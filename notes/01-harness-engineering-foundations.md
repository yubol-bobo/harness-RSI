# 01 — Harness Engineering Foundations

> Tutor note, written for a newcomer. It starts with intuition, then gives precise definitions, the component taxonomy, design patterns, worked examples, and interview angles.
> Backbone: [Weng 2026, *Harness Engineering for Self-Improvement*](../sources/weng-2026-harness-engineering-for-self-improvement.md). I read the Anthropic engineering posts below in full. OpenAI and Manus posts are blocked from this machine, so their content comes from search snippets and secondary summaries; those parts are marked.
> Companion notes: [00 big picture](00-big-picture.md), [02 context engineering & memory](02-context-engineering-and-memory.md), [03 harness optimization](03-harness-optimization.md). Paper cards: [papers/](papers/).

---

## 0. TL;DR (read this if you only have 2 minutes)

- A **model** predicts the next token. A **harness** is all the software around the model that turns those predictions into actions with consequences: the loop, the tools, how context is assembled and trimmed, memory, sub-agents, permissions and sandboxing, and how results are verified. **Agent = model + harness.**
- The core of every modern harness is tiny: `while not done: call model → if it asked for a tool, run the tool → append the result → repeat`. Most of the engineering goes into everything *around* that loop.
- The industry has converged on a common coding-agent surface (Claude Code, Codex, OpenCode, Cursor): file read/search/edit tools, a shell, web access, sub-agents, MCP/Skills for extension, a permission system, and compaction. (Weng's case study.)
- The two big design laws: **(1) context is a finite attention budget**, so find "the smallest possible set of high-signal tokens" ([Anthropic, context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)); and **(2) every harness component encodes an assumption about what the model can't do, and those assumptions go stale** ([Anthropic, harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)). Harnesses must be continuously simplified as well as extended.
- Harness quality matters a lot. LangChain moved its agent from 52.8 to 66.5 on Terminal-Bench 2.0 (Top-30 → Top-5) by changing only the harness ([LangChain](https://blog.langchain.com/improving-deep-agents-with-harness-engineering)). Infrastructure configuration alone moved Terminal-Bench 2.0 by 6 pp ([Anthropic, infra noise](https://www.anthropic.com/engineering/infrastructure-noise)).
- **Why RSI people care:** the harness is code, it is cheap to change, and it can be inspected. That makes it the most practical first target for a system to improve itself (Weng). Note 03 covers the auto-optimization work.

---

## 1. Intuition: "explain like I'm new"

### 1.1 The brain-in-a-jar picture

Picture a brilliant consultant who is locked in a room. They cannot see or touch anything. Once per minute a slip of paper comes under the door, they write a reply, and the slip goes back out. Two facts about them matter:

1. They have **no memory between slips**, except what is written on the slip itself.
2. The slip has **limited space**, and when it is very full they start to skim and miss things.

The **harness** is the office staff outside the door. The staff decide:
- what goes on the slip: instructions, the task, notes from earlier, results of errands (**context engineering**);
- which errands the consultant may request, and how the request form looks (**tool design / ACI**);
- who actually runs the errands, and whether something is too dangerous to do (**execution, sandboxing, permissions**);
- when to start a fresh slip with a summary because the current one is full (**compaction / context resets**);
- whether to hire extra consultants for sub-questions and accept only their summaries (**sub-agents**);
- how to check the consultant's work before calling it done (**verification / evaluators**);
- what to file in the cabinet for tomorrow (**memory / file system / progress files**).

A smarter consultant (a better model) helps a great deal, but a well-run office also changes outcomes. The same model with a different harness can score very differently. A good office is also **thin where the consultant is already competent** and invests effort only where the consultant really falls short.

### 1.2 Why the word "harness"

A horse harness does not make the horse stronger. It channels the horse's power into useful work, such as pulling a cart. An agent harness does the same with model intelligence. (A related term, "test harness", means the code that runs a program under controlled conditions. That sense survives in "evaluation harness".)

---

## 2. Precise definitions (and what a harness is *not*)

| Term | Definition | Example |
|---|---|---|
| **Model** | The weights. Stateless function: tokens in → tokens out. | Claude Opus, GPT-5.x-codex, Qwen3.5 |
| **Harness** (Weng) | "The system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results." | Claude Code, Codex CLI, OpenCode, Terminus-2 |
| **Agent harness** (Anthropic) | "The system that enables a model to act as an agent: it processes inputs, orchestrates tool calls, and returns results. When we evaluate 'an agent,' we're evaluating the harness *and* the model working together." ([Demystifying evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)) Also: "the software scaffolding around a model: the loop, tools, context management, and guardrails that turn raw intelligence into a working agent" ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)) | Same |
| **Scaffold / scaffolding** | Mostly a **synonym** for harness. It was the more common word in 2023–24 benchmark papers (e.g. "SWE-bench measures model+scaffold"). It sometimes carries a "temporary support" connotation, i.e. the bits to remove when the model improves. | SWE-agent, Agentless, AIDE |
| **Agent framework / SDK** | A *library for building* harnesses: abstractions for loops, tools, memory, multi-agent graphs. | LangGraph, Claude Agent SDK, OpenAI Agents SDK, Google ADK |
| **Evaluation harness** | Infrastructure that *runs agents on tasks and grades them*: sandboxes, concurrency, graders, logging. | Harbor (ships Terminal-Bench 2.0), SWE-bench harness |
| **Meta-harness** | A system that hosts or optimizes harnesses. The term is used in two senses: (a) Anthropic's *Managed Agents* hosts arbitrary harnesses behind stable interfaces; (b) *Meta-Harness* (Lee et al. 2026) searches over harness code. | Managed Agents; Meta-Harness |
| **Context engineering** | Curating "the optimal set of tokens (information) during LLM inference", which covers more than the prompt. | compaction, JIT retrieval, note-taking |
| **Loop engineering** | Designing the repeat-until-done cycles. Anthropic's Claude Code team defines **loops as "agents repeating cycles of work until a stop condition is met"**, and classifies them by trigger, stop condition and primitive (turn-based, goal-based `/goal`, time-based `/loop`, `/schedule`, proactive) ([Getting started with loops, Jun 2026](https://claude.com/blog/getting-started-with-loops)). | Ralph-Wiggum loop, autoresearch |

**Constitutive definition (2026 academic).** An arXiv paper, *What makes a harness a harness* ([2606.10106](https://arxiv.org/abs/2606.10106)), proposes four necessary and sufficient elements: **an agent loop, a tool interface, context management, and control mechanisms**. It applies them to Claude Code, Codex CLI, Aider, Cline, OpenHands and SWE-agent. *(Known to me only from the awesome-list summary; unverified.)* This is a good one-line definition to use in an interview.

**How harness engineering differs from older "agent = LLM + memory + tools + planning"** (Weng 2023 → 2026): harness engineering *additionally* includes **workflow design (loop engineering), evaluation, permission controls, and persistent state management**. "It is no longer only prompt templates, but closer to runtime and software system design."

**Workflows vs. agents** ([Building Effective Agents, Dec 2024](https://www.anthropic.com/research/building-effective-agents)):
- **Workflow**: "LLMs and tools are orchestrated through **predefined code paths**."
- **Agent**: "LLMs **dynamically direct their own processes** and tool usage."
- Anthropic later settled on the simple definition **"LLMs autonomously using tools in a loop"** ([context engineering post](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- A harness can be either kind, or a hybrid. Claude Code is an agent harness. Karpathy's autoresearch is an agent running inside a fixed outer workflow.

---

## 3. The agent loop: the heart of every harness

### 3.1 The minimal loop

```
messages = [system_prompt, tools_spec, user_task]
while True:
    response = model(messages)                 # inference (stateless API!)
    messages.append(response)
    if response.has_tool_calls():
        for call in response.tool_calls:       # possibly in parallel
            if not permitted(call): result = deny_message(call)
            else:                  result = sandbox.execute(call)
            messages.append(tool_result(call.id, truncate(result)))
        maybe_compact(messages)                # context management
    else:
        if verifier_ok(response): break        # stop condition
        messages.append(nudge("verify before finishing"))
```

Key facts to say in an interview:

1. **The model API is stateless.** "The Messages API is stateless. Claude cannot see the conversation history of prior turns. … the agent harness needs to package new context alongside all past actions, tool descriptions, and instructions for Claude at each turn" ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)). So **the harness owns the state**, not the model.
2. **Each turn resends the whole history**, so cost and latency would grow quadratically without **prefix (KV) caching**. Caching works only if the old prompt is an *exact prefix* of the new prompt. This single fact drives many harness design rules: append-only context, stable tool order, no timestamps at the top. See note 02 §5. (OpenAI's *Unrolling the Codex agent loop*, Jan 2026, by Michael Bolin, makes this point at length. Per secondary summaries, Codex fixed a cache-miss bug caused by **non-deterministic MCP tool ordering**.)
3. **The loop has stop conditions**: the model declares completion, max turns or tokens, time budget, a verifier gate, or human interrupt.
4. **Weng's description of the coding-harness loop**: the agent calls tools and the tool responses shape the model's next generation (image from [OpenAI's Codex loop post](https://openai.com/index/unrolling-the-codex-agent-loop/)).

### 3.2 The loop as Anthropic describes it

> "gather context → take action → verify work → repeat" ([Claude Agent SDK post](https://claude.com/blog/building-agents-with-the-claude-agent-sdk))

- **Gather context**: agentic search over the file system (`grep`, `tail`), semantic search (optional), sub-agents, compaction.
- **Take action**: tools, bash and scripts, code generation, MCP.
- **Verify**: rules (lint/types/tests; "it is usually better to generate TypeScript and lint it than … pure JavaScript"), visual feedback (screenshots), LLM-as-judge ("generally not a very robust method").

### 3.3 ReAct as the ancestor

ReAct (Yao et al. 2022, [arXiv 2210.03629](https://arxiv.org/abs/2210.03629)) introduced the Thought → Action → Observation loop. Modern harnesses are ReAct plus native tool-calling APIs, interleaved thinking, parallel tool calls, context management, and permissions. Terminus-2, the default Terminal-Bench 2.0 agent, is described as "a ReAct-style loop that issues tmux keystrokes to a persistent terminal session".

### 3.4 Loop variants (taxonomy)

| Loop type | Trigger / stop | Example |
|---|---|---|
| Turn-based | user message / model stops | chat-mode Claude Code |
| Goal-based | runs until a checkable goal is met | `/goal`, "Ralph Wiggum" loop (re-run the agent until a spec is satisfied) |
| Time-based / scheduled | cron or interval | `/loop`, `/schedule`, CronCreate tools (Weng's tool table) |
| Proactive / event-driven | external events (PR comments, CI failure) | PR babysitting agents |
| Outer research loop | propose → run → measure → keep/discard | Karpathy autoresearch, AlphaEvolve, Meta-Harness |

---

## 4. The component taxonomy

### 4.1 Weng's functional view (what the harness *decides*)

Weng: a harness decides **how the model (1) thinks and plans, (2) calls tools and acts, (3) perceives and manages context, (4) stores artifacts, (5) evaluates results**. In addition it covers **workflow/loop design, permissions, persistent state**.

### 4.2 AHE's 7 editable components (what you can *change*)

*Agentic Harness Engineering* (Lin et al. 2026, [arXiv 2604.25850](https://arxiv.org/abs/2604.25850), via Weng) makes every editable component a file, so an evolve-agent can change it:

| # | Component | What it is | Concrete example in Claude Code / Codex | Typical failure it fixes |
|---|---|---|---|---|
| 1 | **System prompt** | Persistent instructions: role, rules, workflow hints | Claude Code system prompt; `AGENTS.md` / `CLAUDE.md` loaded at start | wrong default behaviors, skipping verification |
| 2 | **Tool description** | Name, docstring and schema the model reads | `str_replace_editor` description: "old_str must match EXACTLY…" | wrong tool choice, bad arguments |
| 3 | **Tool implementation** | Code that runs when the tool is called | absolute-path requirement; 25k-token output cap; concise/detailed modes | context blow-up, fragile edits |
| 4 | **Middleware** | Hooks that intercept the loop (before/after model or tool calls) | Codex hooks `PreToolUse/PostToolUse`; LangChain `PreCompletionChecklistMiddleware`, loop detection | doom loops, premature exit, policy enforcement |
| 5 | **Skill** | On-demand packaged know-how (`SKILL.md` + scripts) | PDF skill, frontend-design skill | missing procedural knowledge |
| 6 | **Sub-agent configuration** | Which sub-agents exist, their prompts, tools, models | Explore/Plan sub-agents; research sub-agents | context pollution, lack of parallelism |
| 7 | **Long-term memory** | Persistent cross-session store | memory tool directory; `claude-progress.txt`; learnings.md | repeating past mistakes, losing state |

Add the **runtime** components that AHE deliberately treats as *read-only*: **sandbox/permissions, verifier, tracer, model config**. AHE freezes them so the evolve-agent cannot reward-hack, e.g. by disabling the verifier or raising the reasoning budget. That separation is a core RSI-safety idea: **the evaluator and the permission layer live outside the loop being optimized** (Weng, "Future challenges").

### 4.3 LangChain's 5 primitives (another lens)

LangChain's *Anatomy of an Agent Harness* lists **filesystem** (durable state and a collaboration surface), **code execution**, **sandbox**, **memory**, and **context management** (per the awesome-list summary).

### 4.4 Böckeler/Fowler's control-theory lens

Birgitta Böckeler ([martinfowler.com, Apr 2026](https://martinfowler.com/articles/harness-engineering.html)) splits a coding-agent harness into:
- **Guides (feedforward)**: steer before acting (AGENTS.md, specs, skills, architecture docs).
- **Sensors (feedback)**: observe after acting so the agent can self-correct (linters, tests, type checkers, structural/architecture tests, LLM judges).
- She distinguishes **computational** controls (deterministic: lint/tests) from **inferential** ones (LLM-as-judge).

An earlier Fowler memo summarized OpenAI's practice as three interlocking systems: **context engineering, architectural constraints** (deterministic linters and structural tests), and **entropy management** (periodic agents that repair documentation drift).

### 4.5 One diagram combining all of the above

```
                       ┌─────────────────────── HARNESS ───────────────────────────┐
 user / event ───────▶ │  LOOP CONTROLLER (turns, stop conditions, budgets)         │
                       │     │                                                      │
                       │     ▼                                                      │
                       │  CONTEXT ASSEMBLER ── system prompt, AGENTS.md (map)       │
                       │     │                 tool specs (stable, cache-friendly)  │
                       │     │                 skills metadata (progressive discl.) │
                       │     │                 history (compacted / cleared)        │
                       │     │                 memory files, todo/progress recitation│
                       │     ▼                                                      │
                       │  ┌────────┐  tool calls  ┌──────────────────────────────┐   │
                       │  │ MODEL  │ ───────────▶ │ MIDDLEWARE / HOOKS           │   │
                       │  └────────┘ ◀─────────── │  permission check (allowlist,│   │
                       │      ▲    results(trunc.) │  classifier, user prompt)    │   │
                       │      │                    └──────────────┬───────────────┘   │
                       │      │                                   ▼                   │
                       │      │                    ┌──────────────────────────────┐   │
                       │      │                    │ EXECUTION ("hands")          │   │
                       │      │                    │ sandbox: fs + network isol.  │   │
                       │      │                    │ bash, editor, browser, MCP,  │   │
                       │      │                    │ sub-agents, background jobs  │   │
                       │      │                    └──────────────┬───────────────┘   │
                       │      │                                   ▼                   │
                       │   VERIFIERS (tests, lint, evaluator agent, judge)            │
                       │   OBSERVABILITY (traces, session event log, metrics)         │
                       └──────────────────────────────────────────────────────────────┘
                                  │ durable state: files, git, session log
```

---

## 5. The OS analogy (Weng, Anthropic Managed Agents, MemGPT)

Weng: "There is also a strong analogy between operating systems and harnesses. Similar to an OS, a harness should encapsulate complicated logic while keeping the interface simple. Meanwhile, configs, tool interfaces and other protocols may gradually become standardized across the industry."

| OS concept | Harness analogue | Notes |
|---|---|---|
| CPU | the model (does the "computation") | Karpathy's "LLM OS" framing |
| RAM | the context window | small, fast, expensive, and degrades when full ("context rot") |
| Disk | file system / memory dir / session log | large, durable, needs explicit read/write |
| Virtual memory & paging | compaction, JIT retrieval, MemGPT paging | MemGPT (Packer et al. 2023) is literally "LLMs as Operating Systems" |
| Syscalls | tool calls | `execute(name, input) → string` |
| Processes / scheduler | sub-agents, background jobs | Weng Pattern 3: "a small process manager: launch jobs, inspect logs, cancel failed runs, merge results" |
| Permissions / kernel mode | permission system, sandbox | AHE keeps verifier/tracer read-only, like kernel memory |
| Drivers / package manager | MCP servers, Skills | standardised plug-ins |
| Stable ABI | stable harness interfaces | Managed Agents: "programs as yet unthought of" |

**Anthropic Managed Agents (Apr 2026)** makes the analogy explicit. Operating systems "virtualiz[ed] hardware into abstractions—*process, file*—general enough for programs that didn't exist yet". Managed Agents virtualizes the agent into:
- **session**: "the append-only log of everything that happened" (the durable state; **"the session is not Claude's context window"**);
- **harness**: "the loop that calls Claude and routes Claude's tool calls" (the "brain"); it is stateless and recovers via `wake(sessionId)`, `getSession(id)`, `emitEvent(id, event)`;
- **sandbox**: where code runs (the "hands"), reached as just another tool `execute(name, input) → string` and created via `provision({resources})`.
- Payoffs: containers became "cattle not pets"; credentials are never reachable from the sandbox (git tokens wired at init; MCP OAuth via a vault-backed proxy); **p50 time-to-first-token dropped ~60% and p95 by >90%** because containers are provisioned lazily.
- Weng's warning carries over: if a self-improving agent may edit "the OS", **abstraction boundaries break**. The editable surface must be designed, and security must sit outside the loop.

---

## 6. Tool design: the agent-computer interface (ACI)

### 6.1 The idea

**SWE-agent** (Yang, Jimenez, et al., NeurIPS 2024, [arXiv 2405.15793](https://arxiv.org/abs/2405.15793)) coined **agent-computer interface (ACI)**: an LM is a new kind of *user*, so give it an interface designed for it, just as HCI designs interfaces for humans. SWE-agent replaced raw shell use with bounded, LM-friendly commands: a windowed file viewer, a search that returns summarized hits, and an edit command with a **linter guardrail** that rejects syntactically broken edits. It reported **12.47% (≈12.5%) on full SWE-bench**, the state of the art at the time. *(Exact window sizes and ablation numbers are not verified here. The paper reports that the ACI substantially outperforms a raw-shell baseline with the same model.)*

Anthropic picked up the term: "think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good *agent*-computer interfaces (ACI)" ([Building Effective Agents, App. 2](https://www.anthropic.com/research/building-effective-agents)). On SWE-bench: "we actually spent more time optimizing our tools than the overall prompt."

### 6.2 Principles (with the evidence behind each)

| Principle | Evidence / example |
|---|---|
| **Use formats the model already knows** ("keep the format close to what the model has seen naturally occurring on the internet"; avoid diffs that need exact line counts; avoid code-inside-JSON escaping) | Building Effective Agents, App. 2 |
| **Poka-yoke the tool** (make mistakes impossible) | Requiring **absolute paths** fixed relative-path errors: "the model used this method flawlessly" |
| **String-replace editing beats alternatives** | Anthropic's SWE-bench agent: `str_replace` with exactly-one-match semantics gave "the highest reliability"; errors on 0 or >1 matches |
| **Minimal scaffold, general tools** | Claude 3.5 Sonnet hit **49% SWE-bench Verified** (SOTA at the time; prior 45%) with just a prompt, a **bash tool** and an **edit tool** ([SWE-bench post](https://www.anthropic.com/engineering/swe-bench-sonnet)); Claude Code builds on the same tools |
| **Fewer, higher-level tools, not API wrappers** | `search_contacts` not `list_contacts`; `schedule_event` instead of `list_users`+`list_events`+`create_event`; `search_logs` not `read_logs` ([Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)) |
| **No ambiguous overlap** | "If a human engineer can't definitively say which tool should be used … an AI agent can't be expected to do better" ([context eng.](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)) |
| **Namespacing** | `asana_projects_search` vs `jira_search`; prefix vs suffix choice had "non-trivial effects" |
| **Return meaningful, token-efficient context** | Replace UUIDs with semantic names or 0-indexed IDs ("significantly improves … precision"); a `response_format: concise|detailed` enum (Slack example: concise used ~⅓ of the tokens, 72 vs 206) |
| **Paginate / filter / truncate with defaults** | Claude Code caps tool responses at **25,000 tokens** by default |
| **Actionable errors** | Error messages that tell the agent how to fix the call, not tracebacks |
| **Prompt-engineer descriptions like onboarding docs** | "describe your tool to a new hire"; `user_id` not `user`; the web-search tool description was fixed after Claude kept appending "2025" to queries |
| **Let agents improve tools** | A tool-testing agent rewrote flawed MCP tool descriptions, giving a **40% decrease in task completion time** for later agents ([multi-agent research](https://www.anthropic.com/engineering/multi-agent-research-system)). Claude-optimized Slack/Asana tools beat "expert" human-written ones on held-out tests ([tools post](https://www.anthropic.com/engineering/writing-tools-for-agents)) |
| **Promote risky or UX-relevant actions to dedicated tools** | Bash gives the harness "only a command string". Dedicated tools give "an action-specific hook with typed arguments it can intercept, gate, render, or audit"; edit tools can do **staleness checks** ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)) |

**The tension to name in interviews.** *General* tools (bash, code execution) let the model orchestrate and compose; Anthropic calls this "lean on the model". *Dedicated* tools give the harness control points for security, UX and observability. Modern practice: a general core (bash + editor + code execution), dedicated tools only where a boundary matters, and the split re-evaluated with every model release.

### 6.3 Code as the universal action space

- **Code execution with MCP** ([Anthropic, Nov 2025](https://www.anthropic.com/engineering/code-execution-with-mcp)) presents MCP servers as a *file tree of typed code APIs*. The agent reads only the tool files it needs and filters data in the sandbox. Example: **150,000 → 2,000 tokens (98.7% saving)**. Cloudflare calls the same idea "Code Mode".
- **Programmatic tool calling**: on BrowseComp, letting Opus 4.6 filter its own tool outputs with code raised accuracy **45.3% → 61.6%** ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)).
- "Since code is a general way for Claude to orchestrate actions, a strong coding model is also a strong *general* agent." This is why coding harnesses (Claude Code → Claude Agent SDK) have become general agent harnesses, and why Weng says code is the "universal language" for harness search.

---

## 7. Context engineering (summary; full detail in note 02)

- **Context engineering** = curating "the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome." It is the successor to prompt engineering, and it is **iterative**: curation happens every turn.
- **Why**: *context rot*. Recall degrades as tokens increase (Chroma, 18 models), giving an "attention budget" with diminishing returns.
- **System-prompt altitude**: avoid both brittle if-else prompts and vague guidance.
- **Three long-horizon techniques**: **compaction**, **structured note-taking** (memory), and **sub-agent architectures** (clean context; return a 1–2k-token summary).
- **Just-in-time retrieval**: keep identifiers (paths, URLs, queries) and load content with tools. Claude Code is **hybrid**: CLAUDE.md loaded up front, glob/grep at runtime.
- **KV-cache-friendly design**: Manus calls cache hit rate "the single most important metric for a production agent" (cached vs uncached input differ ~10× in price).

---

## 8. Long-running agents: a harness case study in three versions

This is the best worked example of harness design in public. Learn it well.

### v1: Initializer + coding agent ([Anthropic, Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents))

**Problem.** Even Opus 4.5 on the Agent SDK, looping across context windows with compaction, fails to build a production-quality claude.ai clone from a one-line prompt. Failure modes:
1. **One-shotting**: tries to do everything, runs out of context mid-feature, and leaves an undocumented half-implementation.
2. **Premature victory**: a later session sees progress and declares the job done.
3. **Marking features done without end-to-end testing.**
4. Wasting time working out how to run the app.

**Harness fix.** It is the same harness with **two different initial prompts** (footnote: "the system prompt, set of tools, and overall agent harness was otherwise identical"):

```
Session 1: INITIALIZER                       Sessions 2..N: CODING AGENT
 ├─ expand prompt → feature_list.json         ├─ pwd; read claude-progress.txt; git log
 │   (200+ features, all "passes": false)     ├─ run init.sh; smoke-test app (Puppeteer MCP)
 ├─ write init.sh (start dev server)          ├─ pick ONE highest-priority failing feature
 ├─ create claude-progress.txt                ├─ implement + test end-to-end as a user would
 └─ initial git commit                        ├─ flip "passes" only after verification
                                              └─ git commit + update progress file (clean state)
```

Design details worth quoting:
- Feature list in **JSON, not Markdown**, because "the model is less likely to inappropriately change or overwrite JSON files"; agents may only flip the `passes` field ("It is unacceptable to remove or edit tests…").
- **"Clean state"** at session end means code fit to merge to main.
- **Git as an undo stack and a memory**.
- Inspiration: "knowing what effective software engineers do every day" (shift handoffs).

### v2: Planner + generator + evaluator, GAN-inspired ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps))

New problems:
- **Context anxiety**: Sonnet 4.5 "begin[s] wrapping up work prematurely as [it] approach[es] what [it] believe[s] is [its] context limit". Compaction did not fix it, so **context resets** (fresh agent plus a structured handoff) became essential.
- **Self-evaluation leniency**: agents "confidently prais[e] the work" even when it is mediocre. Fix: **separate the generator from the evaluator**. "Tuning a standalone evaluator to be skeptical turns out to be far more tractable than making a generator critical of its own work."

Architecture:
- **Planner**: turns a 1–4 sentence prompt into an ambitious product spec. Kept high-level so planner errors don't "cascade into the downstream implementation".
- **Generator**: works in sprints, one feature at a time (React/Vite/FastAPI/SQLite), self-checks, uses git.
- **Evaluator**: uses **Playwright MCP** to click through the live app; grades against criteria with **hard thresholds**; any criterion below threshold fails the sprint.
- **Sprint contracts**: generator and evaluator negotiate "what done looks like" *before* coding. Communication is **via files**.

Results (retro game maker): **solo 20 min / $9** vs **full harness 6 hr / $200**. The solo app's core game "was broken"; the harness app's play mode worked. Sprint 3 alone had **27** contract criteria.

Lessons on evaluator tuning: "Out of the box, Claude is a poor QA agent… identif[ies] legitimate issues, then talk[s] itself into deciding they weren't a big deal." The fix loop was to read evaluator logs, find divergences from human judgment, and update the QA prompt over several rounds.

### v3: Simplify for the next model

- **"Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing … they can quickly go stale as models improve."**
- A radical cut failed and made it hard to tell what was load-bearing, so they switched to **ablation: remove one component at a time**.
- With Opus 4.6: **removed sprints**, kept the planner (without it the generator under-scopes), and moved the evaluator to a **single end-of-run pass**. "The evaluator is not a fixed yes-or-no decision. It is worth the cost when the task sits beyond what the current model does reliably solo."
- Opus 4.5 "largely removed" context anxiety, so **context resets were dropped**; SDK auto-compaction suffices.
- DAW result: **3 h 50 min, $124.70** (planner 4.7 min/$0.46; build round 1 2 h 7 min/$71.08 …). QA still caught display-only features and stubbed recording.
- Closing claim: **"the space of interesting harness combinations doesn't shrink as models improve. Instead, it moves."**

### OpenAI's parallel: long-horizon Codex artifacts

OpenAI's *Run Long-Horizon Tasks with Codex* introduces **Plan.md, Implement.md, Documentation.md** as reusable harness artifacts (per awesome-list summary; not read directly). The convergent pattern is **durable planning and progress files plus version control as the inter-session memory**.

---

## 9. OpenAI's "Harness engineering": a product with zero human-written code

Source: [OpenAI, *Harness engineering: leveraging Codex in an agent-first world*](https://openai.com/index/harness-engineering/), Ryan Lopopolo, **Feb 11, 2026**. *(openai.com is blocked from this machine. Facts below are from search-result snippets and secondary summaries of the post; numbers were cross-checked across ≥2 snippets where possible.)*

- **Experiment**: over ~5 months, a team built and shipped an internal beta product with **0 lines of manually written code**. Application logic, tests, CI config, docs, observability and internal tooling were all written by Codex. Even the initial **AGENTS.md was written by Codex**.
- **Scale**: "on the order of a **million lines of code**"; **~1,500 PRs** merged; started with **3 engineers** → **~3.5 PRs per engineer per day**; throughput *increased* as the team grew to **7**. Estimated build time **~1/10th** of hand-writing.
- **Motto**: **"Humans steer. Agents execute."** The engineers' job became designing environments, specifying intent, and building feedback loops.
- **AGENTS.md as a map, not an encyclopedia**: "give Codex a map, not a 1,000-page instruction manual". AGENTS.md is a short **table of contents** pointing into a structured `docs/` directory, i.e. progressive disclosure. Why: a monolithic instruction file crowds out task context, goes stale, and can't be verified mechanically.
- **Agent legibility**: everything about the running system (UI state, logs, metrics, performance) must be perceivable and queryable by the agent. They wired the **Chrome DevTools Protocol** into the runtime (DOM snapshots, screenshots, before/after videos on PRs), made the app **bootable per git worktree**, and gave each task **ephemeral observability** (logs and metrics queryable with **LogQL/PromQL**).
- **Mechanically enforced architecture**: a fixed layering (reported as Types → Config → Repo → Service → Runtime → UI) enforced by custom linters and structural tests. Lint error messages are written to *teach the agent the fix* (sensor + guide).
- **Entropy management / "garbage collection"**: agents copy existing patterns, including bad ones, so "golden principles" are encoded and **recurring background agents** scan for drift, update quality grades, fix stale docs ("doc-gardening"), and open cleanup PRs.
- **Merge philosophy changes** at agent throughput: when correction is cheap, waiting is expensive.
- **Interview takeaway**: this is harness engineering as **organizational and environment design**. The repository becomes the agent's world model. What is not in the repo, such as Slack threads or tribal knowledge, doesn't exist for the agent.

---

## 10. Sub-agents and multi-agent systems

**Why sub-agents** (Weng Pattern 3; Anthropic): (a) **parallelism**, (b) **context isolation** (a dirty search context stays in the child, and only a summary returns), (c) **separation of concerns** (distinct tools and prompts).

**Anthropic's multi-agent Research system** ([Jun 2025](https://www.anthropic.com/engineering/multi-agent-research-system)): orchestrator–worker.
- Lead agent (Opus 4) plans, **saves the plan to memory** (context >200k gets truncated), spawns sub-agents (Sonnet 4) with explicit objective / output format / tools / boundaries, then synthesizes. A **CitationAgent** attributes claims.
- **+90.2%** over single-agent Opus 4 on an internal research eval.
- **Token usage explains 80% of BrowseComp variance**; together with tool-call count and model choice, it explains 95%. "Multi-agent systems work mainly because they help spend enough tokens to solve the problem."
- Cost: agents use **~4×** the tokens of chat; multi-agent **~15×**.
- Not a good fit for tasks with tight inter-agent dependencies; "most coding tasks involve fewer truly parallelizable tasks than research."
- Prompting lessons: teach delegation (vague tasks cause duplicate work); **scale effort to complexity** (1 agent / 3–10 calls for simple; 2–4 sub-agents for comparisons; >10 for complex); start wide then narrow; use extended and interleaved thinking; **parallel tool calls cut research time by up to 90%**.
- Early failures: spawning **50 sub-agents** for simple queries, endless searching for nonexistent sources.
- Engineering: resumable execution from checkpoints, full tracing (without reading conversation contents), **rainbow deployments** so in-flight agents aren't broken; synchronous sub-agents are a known bottleneck.
- **Sub-agent outputs to the file system** to avoid "a game of telephone": workers write artifacts and pass back lightweight references (Weng says the same: make parallelism "explicit and inspectable" via files, logs, status records).

**Newer data points**:
- Sub-agents with Opus 4.6 improved BrowseComp by **2.8%** over the best single-agent runs ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)).
- **Dynamic workflows in Claude Code** (May 2026): Claude *writes orchestration scripts* that fan out to "tens to hundreds of parallel subagents", with adversarial agents trying to refute findings and iteration until convergence; progress is checkpointed. The showcase is Bun ported from Zig to Rust: **~750k lines of Rust, 99.8% of the test suite passing, 11 days** first commit to merge ([post](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code)). Orchestration itself becomes model-written code.
- LangChain (Sep 2026) distinguishes **isolated** sub-agents (fresh context, "a firewall") from **forked** sub-agents (inherit the supervisor's conversation) (awesome-list summary).
- The 2025 open question from Anthropic's long-running-agent post was whether specialized agents (tester, QA, cleanup) beat one general agent. The generator/evaluator split is one partial answer: **specialize where judgment needs to be independent**.

---

## 11. Skills and MCP: the extension layer

### MCP (Model Context Protocol)
- An open protocol (Anthropic, Nov 2024) for connecting agents to tools and data. You "implement MCP once in [your] agent and it unlocks an entire ecosystem of integrations". There are thousands of servers and SDKs in all major languages.
- Problems at scale: (1) **tool definitions overload context** (connecting thousands of tools means "hundreds of thousands of tokens before reading a request"); (2) **intermediate results pass through the model** (a 2-hour transcript copied twice is about +50k tokens).
- Fixes: **code execution with MCP** (above); **tool search** (load definitions on demand without breaking the cache); MCP **tool annotations** (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`) as *hints* for permission decisions, not enforced contracts.
- Related: Google's **A2A** protocol for agent-to-agent communication (Agent Cards, task/message/artifact model).

### Agent Skills ([Anthropic, Oct 2025](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills); open standard Dec 2025 at agentskills.io)
- A **skill = a folder with `SKILL.md`** (YAML frontmatter `name`, `description`) plus optional scripts and reference files. "Like putting together an onboarding guide for a new hire."
- **Three-level progressive disclosure**: (1) name and description pre-loaded into the system prompt for every installed skill; (2) the full `SKILL.md` read when relevant; (3) linked files (e.g. `forms.md`) read only as needed. As a result, "the amount of context that can be bundled into a skill is effectively unbounded."
- Skills can bundle **deterministic code** (e.g. a PDF form-field extractor) so the model runs it instead of reasoning token by token.
- Security: a malicious skill can exfiltrate data, so install only from trusted sources and audit them.
- Forward-looking line: "we hope to enable agents to **create, edit, and evaluate Skills on their own**". This is the **RSI hook**: a skill library is a persistent, model-writable improvement substrate (cf. Voyager, MCE's skill evolution, Lin et al. 2026 showing even a 9B model writes useful skills).

**MCP vs Skills in one line**: MCP gives the agent **new capabilities (connections)**; Skills give it **procedural knowledge (how to use capabilities well)**. Both are loaded *lazily* to save context.

---

## 12. Permissions, sandboxing, and security

**Threat model** (Anthropic auto-mode post): dangerous actions come from (1) **overeager behavior**, (2) **honest mistakes** about blast radius, (3) **prompt injection**, (4) **misalignment** (not seen in practice; evaluated per release). Real incidents: deleting remote branches after "clean up old branches", uploading a GitHub token to a compute cluster, attempting production DB migrations.

**Layers of defense in Claude Code** (pattern generalizes):

| Layer | Mechanism | Numbers |
|---|---|---|
| Default permissions | read-only by default; ask before writes/commands | users approve **93%** of prompts, so "approval fatigue" |
| **Sandbox** (OS-level: Linux bubblewrap, macOS seatbelt) | **filesystem isolation** (cwd only) **plus network isolation** (proxy with a domain allowlist); covers subprocesses | reduced permission prompts by **84%** internally ([sandboxing post](https://www.anthropic.com/engineering/claude-code-sandboxing)) |
| Credential isolation | secrets never inside the sandbox; a git proxy attaches tokens and checks branch/destination | Claude Code on the web; Managed Agents vault + MCP proxy |
| **Auto mode** classifiers ([Mar 2026](https://www.anthropic.com/engineering/claude-code-auto-mode)) | Tier 1 allowlist → Tier 2 in-project edits → Tier 3 **transcript classifier** (Sonnet 4.6), 2-stage (fast single-token filter, then CoT); **reasoning-blind** (sees only user messages and tool calls, with assistant text and tool outputs stripped); **input-side prompt-injection probe** on tool outputs | Full pipeline: **0.4% FPR** on 10k real actions; **17% FNR** on 52 real overeager actions; **5.7% FNR** on 1k synthetic exfiltration attempts |

Key principles:
- "Effective sandboxing requires *both* filesystem and network isolation." Without network isolation, an agent can exfiltrate SSH keys. Without filesystem isolation, it can escape and gain network access.
- **Lethal trifecta** (Simon Willison, via MCP annotations post): private data access + untrusted content + external communication. Break one leg.
- Auto mode **drops broad allow-rules** (blanket shell, `python *`) because they would hide the most dangerous commands from the classifier.
- The classifier judges *what the agent did, not what it said*, so the agent cannot talk its way past it. That makes it **complementary to CoT monitoring**.
- **For RSI**: permission control must be *outside* the self-modification loop. AHE makes the verifier, tracer and model config read-only; DGM-style self-editing needs a sandbox; Weng: "the permission control and security layers need to live outside this loop."

---

## 13. Verification and evaluation of harnesses

### 13.1 Verification inside the loop
- **Ground truth from the environment** each step (Building Effective Agents).
- **Rules > visual > LLM-judge** ordering of reliability (Agent SDK post).
- **Separate evaluator agents** with hard thresholds and live interaction (Playwright) beat self-evaluation (long-running apps).
- LangChain's Terminal-Bench gain came largely from **forced self-verification** (a `PreCompletionChecklistMiddleware` that intercepts exit), **context injection** (directory maps, time-budget warnings), and **loop-detection middleware**.
- Boris Cherny (Claude Code creator) reportedly says giving the model a way to verify its work gives a **2–3× quality boost** *(secondary source; unverified)*.

### 13.2 Evaluating the harness itself ([Demystifying evals, Jan 2026](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents))
- Vocabulary: **task, trial, grader, transcript/trace, outcome, evaluation harness, agent harness, suite**. "When we evaluate 'an agent,' we're evaluating the harness *and* the model working together."
- **Graders**: code-based (fast, objective, brittle), model-based (flexible, needs calibration), human (gold standard, slow). Grade the **outcome** (DB state), not the claim ("Your flight has been booked").
- **Capability vs regression evals**. Capability evals start with a low pass rate (a hill to climb) and "graduate" into regression suites.
- **pass@k vs pass^k**: with 75% per-trial success and k=3, pass^3 = 0.75³ ≈ 42%. Use pass^k for consistency-critical agents.
- **0% pass@100 usually means a broken task**, not an incapable agent.
- **Isolate trials**: Claude once gained an unfair advantage by reading **git history from previous trials**.
- **Read the transcripts.** Saturation hides gains: SWE-bench Verified went 40% → >80% in about a year.
- **Infra noise** ([Feb 2026](https://www.anthropic.com/engineering/infrastructure-noise)): on Terminal-Bench 2.0, strict resource enforcement (1×) vs uncapped differed by **+6 pp (p<0.01)**. Infra errors went **5.8% → 0.5%**. Up to 3× headroom mostly fixes flakiness (score change within noise, p=0.40); beyond 3× it *changes what is measured* (brute-force strategies become viable). **"Leaderboard differences below 3 percentage points deserve skepticism"** unless configs match. On SWE-bench, 5× RAM gave +1.54 pp.
- **Production regressions are harness regressions**: the [April 2026 Claude Code postmortem](https://www.anthropic.com/engineering/april-23-postmortem) traced user-perceived "model degradation" to **three harness changes**: (1) default effort high → medium; (2) a caching optimization that cleared old thinking once after 1 h idle, but a bug cleared it **every turn** (forgetfulness, plus cache misses that drained usage limits); (3) a system-prompt line "keep text between tool calls to ≤25 words … final responses ≤100 words" that caused a **3% drop** on a broader eval for Opus 4.6 and 4.7. The fixes are themselves harness practice: **per-model eval suite for every system-prompt change, line-by-line ablations, soak periods, gradual rollouts, staff on the exact public build.**

### 13.3 Observability
- Weng / AHE: the bottleneck for automated harness evolution is **observability**. AHE's three pillars are **component** (every editable part is a file), **experience** (layered trace → per-task report → benchmark overview), and **decision** (each edit carries a falsifiable predicted impact).
- Practice: full production tracing (multi-agent research), session event logs (Managed Agents' `getEvents()`), typed tools for structured logs ("when the action is a typed tool, the harness gets structured arguments it can log, trace, and replay"), ephemeral per-task observability stacks (OpenAI), transcript viewers (Anthropic evals).

---

## 14. Coding-agent harness comparison

The common core (Weng's tool table): file discovery (`glob`, `grep`, `ls`), read, `write`/`edit`/`multi_edit`/`apply_patch`, `bash`, LSP and git, MCP/Skills, web search/fetch, artifacts, cron/background processes, agent delegation (`spawn_agent`, `wait_agent`, …).

| Harness | Org | Distinctive design choices | Notes |
|---|---|---|---|
| **Claude Code** / Claude Agent SDK | Anthropic | bash + `str_replace` editor core; CLAUDE.md up front plus glob/grep JIT; auto-compaction; sub-agents; Skills; hooks; sandbox; auto-mode classifiers; tool output cap 25k tokens; the SDK generalizes it to non-coding agents | A reverse-engineering paper (arXiv 2604.14228) describes a **five-stage progressive compaction** and a 27-event hook pipeline *(awesome-list summary; unverified)* |
| **Codex CLI** | OpenAI | Responses-API-driven loop; strict exact-prefix caching discipline; `/responses/compact` endpoint returning an opaque **encrypted compaction item**; `apply_patch` edit format; AGENTS.md; lifecycle hooks; App Server (JSON-RPC Item/Turn/Thread protocol) | Details from secondary summaries |
| **OpenCode** | open source | Model-agnostic Claude-Code-style TUI agent | Used as a human-designed baseline in AHE |
| **Terminus-2** | Terminal-Bench team | **Deliberately minimal**: a ReAct loop sending **tmux keystrokes** to one persistent terminal, i.e. a single "terminal" tool, to measure model ability with little scaffold | Default agent shipped with **Terminal-Bench 2.0** (89 tasks; Harbor framework; arXiv 2601.11868). Meta-Harness searches start from Terminus-2 / Terminus-KIRA |
| **SWE-agent** / mini-SWE-agent | Princeton/Stanford | ACI: windowed viewer, search, linted edit | Origin of "ACI" |
| **Deep Agents (LangChain)** | LangChain | middleware architecture; planning tool; file system; sub-agents | 52.8 → 66.5 on TB2 via harness only |
| **Cursor-style IDE agents** | Cursor, Copilot | IDE-integrated context assembly, multi-provider routing | VS Code team: loop responsibilities are context assembly, tool exposure, tool execution |

**Terminal-Bench 2.0** in brief: realistic terminal tasks in Docker containers, graded by tests; **89 tasks**; ships via the **Harbor** evaluation framework. It is now the main testbed for harness evolution (AHE, Meta-Harness, Self-Harness) because the *harness* is part of what is measured.

**Lesson from comparisons**: the same model varies widely across harnesses, so **benchmark numbers are always (model, harness, infra) triples.** Anthropic's 2026 Agentic Coding Trends report reportedly says harness setup alone can swing benchmarks by **5+ pp** (awesome-list summary).

---

## 15. Karpathy's autoresearch: a minimal research harness

Repo: `karpathy/autoresearch` (Mar 2026; details from secondary write-ups). Weng calls it "a clean example of how such a workflow can be constructed."

```
program.md   (human-written: goal, rules, what's off-limits, how to handle failures)  ← the "harness prompt"
train.py     (~630 lines GPT training code: the ONLY file the agent edits)              ← editable surface
prepare.py   (data download, tokenizer, shards: fixed)                                 ← fixed environment
loop:  agent edits train.py → train for a FIXED 5-MINUTE wall-clock budget → read val_bpb
       if improved: git commit (score in message) else: git revert
→ ~12 experiments/hour, ~100 overnight on one GPU
```

Why it is a perfect teaching example:
1. **Single scalar, hard-to-game metric** (validation bits-per-byte) and a **fixed compute budget**, so experiments are comparable and the "evaluator" is outside the agent's control.
2. **Small, explicit editable surface** (one file), the same principle as AlphaEvolve's EVOLVE-BLOCK markers and AHE's read-only verifier.
3. **Git as memory and rollback**, the same as Anthropic's long-running harness.
4. **The human edits `program.md`**, i.e. the human programs the *research org*, not the model code. That is "humans move up the stack" (Weng §7).
5. It is a hill-climber (greedy accept/reject), so it inherits the risks of **diversity collapse** and **overfitting to the validation metric** (Weng's challenges 4 and 5).

---

## 16. The "bitter lesson" debate: thin vs thick harnesses

**Sutton's Bitter Lesson (2019)**: general methods that scale with compute beat hand-built human knowledge. Applied to harnesses:

| Thin-harness camp | Thick-harness camp |
|---|---|
| Every component encodes an assumption the model is weak at something, and that assumption **expires** (Anthropic: context resets became "dead weight" with Opus 4.5) | Long-horizon, high-stakes work needs structure: planners, evaluators, contracts, permission layers (Anthropic v2 harness: $9 solo broken vs $200 harness working) |
| Use tools the model already knows (bash, editor), "lean on the model, not the harness" | Harness-only tuning gives big wins *today* (LangChain +13.7 pp; Nemotron 3 Ultra within 1 point of Opus 4.8 at ~1/10 cost, per LangChain Jul 2026, awesome-list summary) |
| Move orchestration decisions to the model (code execution, self-managed context, sub-agent forking) | Some functions *must not* be absorbed: security, permissions, evaluators (for RSI safety) |
| Minimal scaffolds (Terminus-2, mini-SWE-agent, browser-use's ~600-line harness) | Model-specific harness tuning exists (Self-Harness learns different instructions per model) |

**Synthesis (a strong answer):**
1. **Harness functions split into two kinds.** *Cognitive scaffolding* (planning hacks, decomposition, context resets, prompt tricks) tends to be **absorbed into the model**. *Interface and governance* (tools, protocols, sandbox, permissions, durable state, evaluation) **persists**, much as OS abstractions outlived each hardware generation. Weng: "many harness improvements will be *internalized* into core model behavior, but the interface with external context and tools should remain," just as prompt engineering faded but "the need to specify goals, constraints, context, and evaluation did not disappear."
2. **The frontier moves.** "The space of interesting harness combinations doesn't shrink as models improve. Instead, it moves" (Anthropic). Better models let harnesses take on longer tasks: multi-day workflows, hundreds of sub-agents.
3. **Bitter-lesson-compatible harness work** = generic mechanisms that **scale with compute and model capability**: file-system memory (improves as models get better at bash), code-as-action, sub-agent fan-out (multi-agent research: token spend explains 80% of variance), and **automated harness search** (Meta-Harness, AHE), which *is itself* a general method that scales with compute.
4. **Process discipline**: re-ablate the harness at every model release; keep components only if they are load-bearing.
5. **Training-time coupling**: harnesses and models co-adapt. Models are RL-trained inside specific harnesses and tool formats (e.g. Claude with bash and `str_replace`; Codex with `apply_patch`), so a model often performs best in the harness it was trained with. A runtime mismatch can hurt; one 2026 paper reports large error rates when interpreter-persistence semantics differ between training and deployment *(awesome-list summary; unverified)*. **This is the strongest argument that "harness" and "model" are not separable in practice.**

---

## 17. Design patterns: summary cheat sheet

| # | Pattern | One-liner | Source |
|---|---|---|---|
| P1 | Augmented LLM | LLM + retrieval + tools + memory as the building block | Building Effective Agents |
| P2 | Prompt chaining / routing / parallelization (sectioning, voting) / orchestrator-workers / evaluator-optimizer | the five workflow patterns | Building Effective Agents |
| P3 | Autonomous agent loop | tools in a loop with environment ground truth and stop conditions | same |
| P4 | Workflow automation: plan → execute → test → improve until goal | Weng Pattern 1 | autoresearch |
| P5 | File system as persistent memory | durable state in files, not context | Weng Pattern 2 |
| P6 | Sub-agents and backend jobs | explicit, inspectable parallelism; small process manager | Weng Pattern 3 |
| P7 | Initializer + incremental worker + progress file + git | multi-session continuity | Anthropic Nov 2025 |
| P8 | Planner / generator / evaluator with contracts | GAN-like split; skeptical external evaluator | Anthropic Mar 2026 |
| P9 | Map-not-encyclopedia (AGENTS.md as TOC) | progressive disclosure for repo knowledge | OpenAI |
| P10 | Progressive disclosure (skills, tool search, code-API file tree) | load only what's needed | Anthropic |
| P11 | Code as action | model writes code to orchestrate tools and filter data | Code exec w/ MCP; CodeAct |
| P12 | Brain/hands/session decoupling | stateless harness, cattle sandboxes, durable event log | Managed Agents |
| P13 | Defense in depth for actions | allowlist → sandbox → classifier → human | Claude Code |
| P14 | Mechanical enforcement + entropy GC | linters/structural tests as sensors; background cleanup agents | OpenAI, Böckeler |
| P15 | Middleware hooks | pre/post model/tool interception for policy, loop detection, verification | Codex hooks, LangChain |
| P16 | Ablate per model release | strip non-load-bearing parts | Anthropic |

---

## 18. Why this matters for RSI

1. **The harness is the cheapest self-modification target.** Weights need training runs. Harness edits are code and text that can be evaluated in minutes. Weng's predicted near-term RSI path: "harness engineering will evolve in the direction of meta-methodology… The harness system itself becomes an optimization target."
2. **Everything in this note is a search space.** System prompt, tool descriptions, tool code, middleware, skills, sub-agent configs and memory (AHE's 7) are all files, so a coding agent can propose diffs (DGM, Meta-Harness, AHE, Self-Harness; see note 03).
3. **Harness engineering supplies the infrastructure *for* auto-research.** File-system memory, sub-agents and backend jobs, long-running continuity, and verifiers are exactly what a research agent needs (AI Scientist, autoresearch). Weng: "mature harnesses enable auto-research for model self-improvement loop and smarter models prevents harnesses from overengineering" [sic].
4. **The safety architecture of RSI is harness architecture.** Read-only evaluators, permission layers outside the loop, sandboxing, observability, and held-out regression tests. These are what keep self-improvement from becoming reward hacking.
5. **Capability caveat**: STOP improved with GPT-4 but *degraded* with weaker models; Lin et al. 2026 find **harness-updating** ability is flat across model sizes while **harness-benefit** is non-monotonic. "Harness improvement enables better deployment of the model but intelligence is still the core" (Weng).

---

## 19. Key numbers to remember

| Number | What | Source |
|---|---|---|
| 49% | Claude 3.5 Sonnet SWE-bench Verified with only bash + edit tool (prior SOTA 45%) | Anthropic, Jan 2025 |
| 12.5% | SWE-agent on full SWE-bench (2024) | Yang et al. 2024 |
| 52.8 → 66.5 | LangChain Deep Agents on TB2, harness-only (gpt-5.2-codex) | LangChain 2026 |
| +6 pp | TB2 score from infra resource headroom alone; distrust gaps < 3 pp | Anthropic, Feb 2026 |
| 3% | eval drop from one verbosity line in Claude Code's system prompt | Anthropic postmortem, Apr 2026 |
| +90.2% | multi-agent (Opus lead + Sonnet workers) vs single Opus 4 on research eval | Anthropic, Jun 2025 |
| 80% / 95% | BrowseComp variance explained by tokens / tokens + tool calls + model | same |
| 4× / 15× | tokens of agent / multi-agent vs chat | same |
| 98.7% | token saving (150k → 2k) from code-execution MCP | Anthropic, Nov 2025 |
| 45.3 → 61.6% | BrowseComp with Opus 4.6 filtering its own tool outputs | Anthropic, Apr 2026 |
| 84% | reduction in permission prompts with sandboxing | Anthropic, Oct 2025 |
| 93% | share of permission prompts users approve (approval fatigue) | Anthropic, Mar 2026 |
| 0.4% FPR / 17% FNR | auto-mode classifier on real traffic / real overeager actions | same |
| $9/20 min vs $200/6 h | solo vs full planner-generator-evaluator harness | Anthropic, Mar 2026 |
| ~1M LOC, ~1,500 PRs, 3→7 engineers, 3.5 PR/eng/day | OpenAI zero-human-code product | OpenAI, Feb 2026 (via secondary sources) |
| 89 | tasks in Terminal-Bench 2.0 | Merrill et al. 2026 |
| 25,000 | default tool-response token cap in Claude Code | Anthropic tools post |
| p50 −60%, p95 −90% | TTFT after decoupling harness from sandbox | Managed Agents, Apr 2026 |

---

## 20. Open questions (good for research-scientist discussion)

1. **Which harness functions will models internalize, and which are permanent?** Can we predict it, e.g. by checking whether a component compensates for a capability that RL can train?
2. **Harness–model co-training.** Should harnesses be trained jointly with weights (SIA, Continual Harness)? How do we avoid models overfitting to one harness's tool formats?
3. **Evaluating harnesses fairly.** Benchmarks measure (model, harness, infra). How do we report harness gains with confidence intervals, matched infra, and held-out transfer (AHE's TB2 → SWE-bench transfer)?
4. **Multi-agent scaling laws.** Token spend explains most of the variance. Is multi-agent just a way to spend tokens, or is there a coordination benefit beyond tokens? When does it beat a single long-context agent with compaction?
5. **Self-evaluation.** Separate evaluators beat self-critique, but evaluators are LLMs that are lenient toward LLM output. How do we scale verification for fuzzy tasks (design, research taste)?
6. **Security vs autonomy frontier.** A 17% FNR on overeager actions shows that consent reasoning ("does this approval cover *this* blast radius?") is unsolved.
7. **Standardization.** Will harness interfaces (MCP, Skills, AGENTS.md, A2A, session logs) settle into an "agent OS ABI"? What would a POSIX for agents look like?
8. **Entropy and long-term health.** Agents replicate patterns, including bad ones. Can background "garbage-collection" agents keep a million-line agent-written repo healthy for years (Weng's challenge 6)?

---

## 21. Interview angles: likely questions and crisp model answers

**Q1. What is a harness, and how is it different from the model and from an agent framework?**
A: The model is the weights, a stateless token predictor. The harness is everything around it that makes it an agent: the loop, tool interface, context and memory management, sub-agents, permissions and sandbox, and verification. Weng's definition is "the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results." A framework (LangGraph, Agent SDK) is a library for *building* harnesses. Claude Code is a harness. Benchmarks evaluate model and harness together.

**Q2. Walk me through the agent loop and where the engineering effort goes.**
A: The loop is call model → execute requested tools → append results → repeat until a stop condition, and it fits in ~10 lines. The effort goes into (1) what context goes in each turn, which matters because the API is stateless, history is resent every turn, and prefix caching makes append-only ordering important; (2) the ACI: tool names, schemas, outputs, errors; (3) execution safety: sandbox and permissions; (4) long-horizon state: compaction, memory files, sub-agents; (5) verification before stopping. Anthropic frames it as gather context → act → verify → repeat.

**Q3. What makes a good tool for an agent?**
A: Design for the model's affordances, not as API wrappers. Use few, high-level, non-overlapping tools (`search_logs`, not `read_logs`); names and descriptions written like onboarding docs; poka-yoke arguments (absolute paths); token-efficient returns (pagination, a concise/detailed mode, semantic IDs instead of UUIDs); actionable errors; and formats the model has seen (string replace instead of line-counted diffs). Evaluate tools with realistic multi-call tasks and let an agent rewrite them; Anthropic saw a 40% task-time reduction from agent-rewritten descriptions. This is the ACI idea from SWE-agent.

**Q4. Workflows vs agents: when would you use each?**
A: Workflows are predefined code paths (chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer). Use them when the task decomposes predictably and you need consistency and low cost. Agents let the model direct the process. Use them for open-ended tasks where you can't hardcode the path. Start with the simplest thing (often a single call with retrieval) and add complexity only when evals show it helps. In practice, hybrids are common: a fixed outer workflow such as autoresearch's keep/revert loop wraps an autonomous inner agent.

**Q5. How do you make an agent work for hours or days?**
A: Externalize state. An initializer writes a feature list (JSON, pass/fail), an init script and a progress log; each worker session reads progress plus git log, smoke-tests, picks one feature, verifies end-to-end, commits, and updates progress. Add context management (compaction or resets, depending on whether the model shows "context anxiety"), a separate skeptical evaluator with hard thresholds, and durable checkpoints so crashes resume. Then ablate the scaffold at each new model release.

**Q6. Compaction vs context reset vs sub-agents vs memory: how do you choose?**
A: Compaction keeps conversational continuity and is the first lever, but it's lossy and doesn't give a clean slate. Resets plus a structured handoff give a clean slate; they were needed for Sonnet 4.5's context anxiety and dropped for Opus 4.5. Note-taking/memory suits iterative work with milestones. Sub-agents suit parallelizable exploration, return 1–2k-token summaries, and keep the lead clean. The cheapest safe first step is clearing old tool results. (Detail in note 02.)

**Q7. Why does a multi-agent system beat a single agent, and when doesn't it?**
A: Anthropic's research system got +90% over single Opus 4, mainly because it spends more tokens in parallel across separate context windows: token usage explained 80% of BrowseComp variance. It also compresses (sub-agents filter) and isolates context. Costs are ~15× chat tokens, coordination failures (duplicate work, 50 sub-agents for trivial queries), and poor fit for tightly coupled tasks like most coding. Use it when task value is high, work is breadth-first and parallelizable, and information exceeds one context.

**Q8. How do you evaluate a harness change rigorously?**
A: Hold the model and infra fixed and vary one harness component (ablation). Use realistic multi-step tasks with outcome-based graders, multiple trials (pass@k and pass^k), isolated environments, and both capability and regression suites, plus a held-out split. Report the infra config, since resources alone moved TB2 by 6 pp and gaps under 3 pp are suspect. Read transcripts to separate agent errors from grader errors. Gate system-prompt changes with per-model evals; one "≤25 words" line cost Claude Code 3%.

**Q9. Is harness engineering a "bitter lesson" casualty? Will models absorb it?**
A: Partly. Cognitive crutches such as context resets, sprint decomposition and prompt tricks expire as models improve; Anthropic removed resets for Opus 4.5 and sprints for Opus 4.6. Interfaces and governance persist: tools, protocols, sandboxing, permissions, durable state, evaluators. Like OS abstractions, they define how intelligence meets the world. And the frontier moves, because better models let harnesses attempt longer tasks. The bitter-lesson-compatible move is generic, compute-scaling mechanisms (file-system memory, code-as-action, parallel sub-agents) and *automated* harness search.

**Q10. What did OpenAI learn building a product with zero human-written code?**
A: Over ~5 months: ~1M LOC, ~1,500 PRs, 3 engineers at about 3.5 PRs/engineer/day, all written by Codex. The engineers' job became environment design: "Humans steer. Agents execute." Key practices: AGENTS.md as a short map into a structured docs/ (not an encyclopedia); agent legibility (Chrome DevTools, per-worktree app instances, queryable logs and metrics); architecture enforced mechanically by linters and structural tests whose errors teach the fix; and recurring cleanup agents to fight entropy. The repo is the agent's whole world, so knowledge not in the repo doesn't exist for it.

**Q11. How should permissions and sandboxing be designed for an autonomous (or self-improving) agent?**
A: Use defense in depth: an allowlist for read-only actions, an OS-level sandbox with *both* filesystem and network isolation, credentials never inside the sandbox (proxies attach tokens), then a classifier or human for actions that cross trust boundaries. Judge actions, not the agent's arguments: Anthropic's classifier is reasoning-blind, sees only user messages and tool calls, and screens tool outputs for injection. Watch out for approval fatigue (users approve 93% of prompts). For RSI specifically, the permission layer, verifier and tracer must sit outside the editable surface, as AHE makes them read-only, or the loop will learn to disable its own checks.

**Q12. Why is harness engineering central to near-term RSI?**
A: Because the harness is code. It is cheap to edit, fast to evaluate, and inspectable, and coding agents are already good at editing code. The optimization target has climbed from prompts to context, workflows, harness code and optimizer code (STOP, ADAS, DGM, Meta-Harness, AHE). Mature harnesses also provide the infrastructure for auto-research that could improve the next model. Two caveats: the base model must be capable enough (STOP degraded with weaker models), and evaluators and permissions must stay outside the loop to prevent reward hacking.

---

## Sources (read in full unless marked)

- Weng, L. [Harness Engineering for Self-Improvement](https://lilianweng.github.io/posts/2026-07-04-harness/) (Jul 2026). Local copy in `sources/`.
- Anthropic. [Building effective agents](https://www.anthropic.com/research/building-effective-agents) (Dec 2024).
- Anthropic. [Raising the bar on SWE-bench Verified](https://www.anthropic.com/engineering/swe-bench-sonnet) (Jan 2025).
- Anthropic. [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) (Jun 2025).
- Anthropic. [Writing effective tools for agents — with agents](https://www.anthropic.com/engineering/writing-tools-for-agents) (Sep 2025).
- Anthropic. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (Sep 2025).
- Anthropic. [Building agents with the Claude Agent SDK](https://claude.com/blog/building-agents-with-the-claude-agent-sdk) (Sep 2025).
- Anthropic. [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) (Oct 2025).
- Anthropic. [Beyond permission prompts (sandboxing)](https://www.anthropic.com/engineering/claude-code-sandboxing) (Oct 2025).
- Anthropic. [Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) (Nov 2025).
- Anthropic. [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (Nov 2025).
- Anthropic. [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) (Jan 2026).
- Anthropic. [Quantifying infrastructure noise in agentic coding evals](https://www.anthropic.com/engineering/infrastructure-noise) (Feb 2026).
- Anthropic. [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Mar 2026).
- Anthropic. [How we built Claude Code auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode) (Mar 2026).
- Anthropic. [Agent harness design: 3 patterns for harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence) (Apr 2026).
- Anthropic. [Scaling Managed Agents: decoupling the brain from the hands](https://www.anthropic.com/engineering/managed-agents) (Apr 2026).
- Anthropic. [An update on recent Claude Code quality reports](https://www.anthropic.com/engineering/april-23-postmortem) (Apr 2026).
- Anthropic. [Introducing dynamic workflows in Claude Code](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code) (May 2026); [Getting started with loops](https://claude.com/blog/getting-started-with-loops) (Jun 2026; intro only).
- OpenAI. [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/) (Feb 2026). **Not directly readable; via search snippets.**
- OpenAI. [Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/) (Jan 2026). **Via secondary summaries.**
- LangChain. [Improving Deep Agents with harness engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering) (2026). **Via search snippets.**
- Böckeler, B. [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html) (Apr 2026). **Via summaries.**
- Yang, Jimenez et al. [SWE-agent](https://arxiv.org/abs/2405.15793) (NeurIPS 2024). **Abstract-level facts only.**
- Merrill et al. [Terminal-Bench](https://arxiv.org/abs/2601.11868) (2026). **Via search snippets.**
- Karpathy, A. autoresearch (GitHub, 2026). **Via secondary write-ups.**
- Lin et al. [Agentic Harness Engineering](https://arxiv.org/abs/2604.25850) (2026). **Via Weng.**
