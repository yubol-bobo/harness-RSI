# 02 — Context Engineering & Memory

> Tutor note, written for a newcomer. It starts with intuition, then covers mechanisms, numbers, and interview angles.
> Prerequisite: [01 harness foundations](01-harness-engineering-foundations.md) (§3 agent loop, §5 OS analogy). Follow-up: [03 harness optimization](03-harness-optimization.md) covers ACE/MCE, which *learn* context automatically.
> I read the Anthropic posts in full. Manus and Chroma content comes from search snippets and secondary summaries because those sites are blocked here; I mark it where it matters.

---

## 0. TL;DR

- **Context** = every token the model sees in one inference call: system prompt, tool definitions, examples, message history, tool results, retrieved docs, memory files. **Context engineering** = "the set of strategies for curating and maintaining the optimal set of tokens (information) during LLM inference" ([Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- **Why it's hard:** (1) the window is finite; (2) even *within* the window, performance degrades as it fills (**context rot**), so treat context as an **attention budget** with diminishing returns; (3) agents generate huge amounts of tokens (Manus: ~100:1 input:output); (4) every turn resends everything, so **KV-cache reuse** dominates cost and latency.
- **The guiding principle:** "find the **smallest possible set of high-signal tokens** that maximize the likelihood of some desired outcome."
- **Toolbox:** right-altitude system prompts; minimal non-overlapping tools; canonical few-shot examples; **just-in-time retrieval** via identifiers and tools; **progressive disclosure** (skills, AGENTS.md as map); **compaction**, **tool-result clearing**, **context resets**; **structured note-taking / memory files**; **sub-agents** for context isolation; **cache-friendly layout** (stable prefix, append-only, mask rather than remove tools).
- **Memory** = context that survives beyond one window. The dominant 2025–26 answer is the **file system as memory** (Weng Pattern 2), because models keep getting better at bash and file editing, so this memory improves "for free" with core capability.
- **RSI link:** memory and context are where *persistent* self-improvement first appears (playbooks, skills, learnings files). Weng argues "context engineering will and should become a core part of intelligence."

---

## 1. Intuition

### 1.1 The desk and the filing cabinet
Think of the model as a very fast worker at a **small desk** (the context window). Everything they're working on must be on the desk. The desk gets messy fast: every tool call drops another pile of paper on it. Two things go wrong:
1. **The desk fills up** (hard limit) and you have to throw things away.
2. **Long before that, the worker gets distracted** (context rot). With 300 pages on the desk they miss the one sticky note that mattered, especially if other pages *look similar* to it.

Context engineering is office management:
- Keep **only what's needed now** on the desk.
- Put the rest in a **filing cabinet** (file system / memory), with a **good index** (file names, paths, a table of contents) so the worker can fetch things just in time.
- Have the worker write a **to-do list and progress notes** they re-read often.
- When the desk is full, **summarize and clear it** (compaction), or start a **fresh desk with a handoff memo** (context reset).
- For a big search, **send an assistant** (sub-agent) to dig through a separate pile and return a one-page summary.
- And because re-reading the desk from the top every minute is expensive, **don't reshuffle the top of the pile** (KV-cache prefix stability).

### 1.2 Prompt engineering → context engineering
| | Prompt engineering | Context engineering |
|---|---|---|
| Unit | one prompt (mostly the system prompt) | the whole token state at each step |
| When | written once | **re-curated every turn** ("iterative … each time we decide what to pass to the model") |
| Typical setting | single-turn classification or generation | multi-turn agents over long horizons |
| Question | "what words?" | "what configuration of context is most likely to generate our model's desired behavior?" |

Karpathy popularized the term in mid-2025 as "the delicate art and science of filling the context window with just the right information for the next step" (paraphrase; the Anthropic post links his tweet).

---

## 2. Why context is a scarce resource: context rot and the attention budget

### 2.1 Context rot (Chroma, Jul 2025)
[Hong, Troynikov & Huber, *Context Rot: How Increasing Input Tokens Impacts LLM Performance*](https://research.trychroma.com/context-rot), tested **18 models** (including GPT-4.1, Claude 4, Gemini 2.5, Qwen3):
- Performance degrades **non-uniformly** as input length grows, *even on simple tasks* (needle-in-a-haystack variants, repeated-word copying, LongMemEval-style conversational QA).
- **Lower needle–question semantic similarity → faster degradation with length.** Lexical-match NIAH overstates long-context ability.
- **Distractors** (topically similar but wrong snippets) hurt more as context grows.
- Counter-intuitively, **shuffled (incoherent) haystacks were *easier* than coherent ones** across models. Narrative structure seems to pull attention.
- *(Per secondary summaries; exact per-model curves not verified.)*

Related classic: **"Lost in the Middle"** (Liu et al. 2023): models recall information at the start and end of the context better than in the middle. Manus's **todo.md recitation** (§6) exploits this by pushing the plan to the *end* of the context.

### 2.2 Why it happens (Anthropic's explanation)
- Attention is all-pairs: **n² pairwise relationships for n tokens**, so attention "gets stretched thin" as n grows.
- **Training distribution**: shorter sequences are more common, so models have "less experience with, and fewer specialized parameters for, context-wide dependencies."
- **Position-encoding interpolation** extends windows but with "some degradation in token position understanding."
- Result: "a performance **gradient** rather than a hard cliff". Context must be treated as "a finite resource with diminishing marginal returns", an **attention budget**.
- Anthropic expects that "context windows of all sizes will be subject to context pollution and information relevance concerns" for the foreseeable future. Bigger windows don't remove the need.

### 2.3 Failure-mode vocabulary (useful in interviews)
| Name | Meaning |
|---|---|
| **Context rot** | degradation with length (Chroma) |
| **Context pollution / distraction** | irrelevant or redundant tokens (old tool outputs) dilute attention |
| **Context confusion** | too many or overlapping tools cause the wrong tool choice |
| **Context poisoning** | an early hallucination or error gets repeated as if it were fact (practitioner term; e.g. Drew Breunig's taxonomy, unverified source) |
| **Context collapse** | iterative rewriting of a prompt or memory erodes details (ACE's term; see note 03) |
| **Brevity bias** | optimizers drift toward short, generic prompts that drop domain specifics (ACE) |
| **Context anxiety** | the model wraps up prematurely as it believes the limit is near (Anthropic, Sonnet 4.5) |
| **Goal drift** | over ~50 tool calls the model forgets the original objective (Manus's motivation for recitation) |
| **Few-shot rut** | the model imitates repetitive action patterns in its own history (Manus) |

---

## 3. Anatomy of a good context (static parts)

From [Anthropic's context-engineering post](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents):

**System prompt at the right altitude**
```
too low (brittle)  ◀──────────── right altitude ────────────▶  too high (vague)
hard-coded if-else       specific enough to guide,           "be helpful", assumes
logic for every case     flexible enough to give heuristics  shared context
```
- Organize into sections (`<background_information>`, `<instructions>`, `## Tool guidance`, `## Output description`). Exact formatting matters less as models improve.
- "Minimal does not necessarily mean short." Start minimal with the best model, then add instructions **based on observed failure modes**.

**Tools**: the contract between the agent and its information and action space. Keep them token-efficient and non-overlapping. Bloated toolsets are "one of the most common failure modes" (see note 01 §6).

**Examples**: use "diverse, canonical examples", not a "laundry list of edge cases". "For an LLM, examples are the 'pictures' worth a thousand words."

**Repository knowledge**: OpenAI's **AGENTS.md as a map, not an encyclopedia**. A short table of contents points into structured `docs/` (progressive disclosure for repo knowledge; via secondary summaries). The same logic applies to CLAUDE.md. Anthropic's postmortem adds that model-specific prompt lines should be gated to the model they target.

---

## 4. Getting information *in*: retrieval strategies

### 4.1 Pre-computed retrieval (classic RAG) vs just-in-time (agentic) retrieval
| | Pre-inference retrieval (RAG) | Just-in-time (JIT) retrieval |
|---|---|---|
| How | embed chunks; top-k similar chunks injected before inference | agent holds **lightweight identifiers** (paths, URLs, stored queries) and loads data via tools when needed |
| Pros | fast, one-shot | always fresh, precise, **progressive disclosure**, uses metadata (folder names, file sizes, timestamps) as signals |
| Cons | stale indexes, chunking errors, static (no adaptation) | slower; needs good tools and heuristics; can waste context chasing dead ends |
| Example | classic QA bots | Claude Code with `glob`/`grep`/`head`/`tail`; the multi-agent research system's multi-step search |

- Anthropic: "Claude Code is an agent that employs this **hybrid** model: CLAUDE.md files are naively dropped into context up front, while primitives like glob and grep allow it to navigate its environment and retrieve files just-in-time, effectively bypassing the issues of stale indexing and complex syntax trees."
- Agent SDK post: "we suggest **starting with agentic search**, and only adding semantic search if you need faster results." Semantic search is "faster … but less accurate, more difficult to maintain, and less transparent."
- "The folder and file structure of an agent becomes a form of context engineering."
- Analogy to human cognition: "we generally don't memorize entire corpuses … but rather introduce external organization and indexing systems like file systems, inboxes, and bookmarks."

### 4.2 Progressive disclosure everywhere
The same principle shows up at every layer: *load a cheap summary first, and the full content only on demand.*
- **Skills**: name and description in the system prompt → `SKILL.md` → bundled files.
- **Tools**: tool search / code-API file tree. Load only the definitions needed (150k → 2k tokens in Anthropic's MCP example).
- **Repo docs**: AGENTS.md TOC → docs/.
- **Tool responses**: `concise` vs `detailed` modes; pagination; truncation with steering hints.
- **Memory**: directory listing → file.

### 4.3 Keep bulky data *out* of context
- Code execution lets the agent filter 10,000 spreadsheet rows inside the sandbox and print 5 ([code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)).
- Programmatic tool calling raised Opus 4.6 BrowseComp accuracy **45.3% → 61.6%** by letting it filter its own tool outputs ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)).
- Privacy bonus: intermediate data can flow tool-to-tool without entering context, and the harness can **tokenize PII** (`[EMAIL_1]`) and untokenize it at the next tool call.

---

## 5. KV-cache-friendly harness design

### 5.1 The mechanism (first principles)
- In a transformer, processing the prompt ("**prefill**") computes key and value vectors for every token at every layer: the **KV cache**. Decoding the next token reuses them.
- An agent resends its whole history every turn. If the server kept the KV state for the previous request's prefix, **only the new suffix needs prefill**. This is **prefix caching** (also prompt caching).
- It only works for an **exact token-for-token prefix match**. Change one token early and everything after it must be recomputed.
- Without caching, total agent cost grows roughly **quadratically** in the number of turns (each turn re-processes all previous tokens). With caching it is closer to linear (Codex agent-loop post, via secondary summaries).
- Economics: **cached input tokens cost ~10% of base input** on Claude ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)). Manus quotes **$0.30 vs $3.00 per MTok** for Claude Sonnet, a 10× gap, and calls **KV-cache hit rate "the single most important metric for a production agent."** Agents are prefill-heavy: Manus reports **~100:1 input:output tokens** and ~50 tool calls per typical task.

### 5.2 Rules (Anthropic + Manus + Codex, consolidated)
| Rule | Why | Source |
|---|---|---|
| **Static first, dynamic last** (system prompt and tools at the top) | maximizes shared prefix | Anthropic |
| **Never put a timestamp or other volatile data at the start of the system prompt** | invalidates the whole cache every request | Manus |
| **Append-only context**; never edit earlier turns | edits break the prefix | Manus, Codex |
| **Deterministic serialization** (stable JSON key order, stable tool order) | non-determinism silently breaks cache; Codex reportedly fixed a bug from non-deterministic MCP tool ordering | Manus, Codex (secondary) |
| **Send updates as messages** (e.g. a `<system-reminder>` appended) instead of editing the system prompt | keeps the prefix stable | Anthropic |
| **Don't switch models mid-session**; use a sub-agent for a cheaper model | caches are model-specific | Anthropic |
| **Don't add or remove tools mid-session; mask instead, or use tool search that appends** | tool defs sit in the prefix | Anthropic, Manus |
| **Move cache breakpoints forward / use auto-caching** | keep the newest prefix cached | Anthropic |
| **Session routing / sticky sessions** in self-hosted inference (e.g. vLLM prefix caching) | the cache lives on specific workers | Manus |

### 5.3 "Mask, don't remove" (Manus)
Problem: with many tools (especially MCP), you want to restrict which tools are available per state. **Removing** tool definitions mid-session breaks the KV cache, and earlier turns that reference removed tools confuse the model. Manus instead keeps all tools in context and uses a **context-aware state machine** that **masks token logits** at decode time, e.g. via response prefill, to forbid or force certain tools. Tool names share **consistent prefixes** (`browser_*`, `shell_*`) so whole groups can be masked by constraining the prefix. *(Mechanism from Manus post via summaries; prefix details partly from memory of the post, so treat as approximately right.)*

### 5.4 A real-world cautionary tale: when cache optimization hurts intelligence
In Claude Code's [April 2026 postmortem](https://www.anthropic.com/engineering/april-23-postmortem), a change cleared old **thinking blocks** from sessions idle for more than 1 hour (the cache had expired anyway, so dropping them saved uncached tokens). A bug made it clear thinking **on every subsequent turn**. Claude "would continue executing, but increasingly without memory of why it had chosen to do what it was doing", which showed up as forgetfulness, repetition and odd tool choices. Because each request dropped content, every request was also a **cache miss**, which drained usage limits. It passed code review, unit tests, e2e tests and dogfooding. **Lesson:** context-management code is intelligence-critical. It needs evals that measure model *behavior*, not just correctness tests.

---

## 6. Manus's six lessons (production context engineering)

Source: Yichao "Peak" Ji, [*Context Engineering for AI Agents: Lessons from Building Manus*](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) (Jul 2025). *(Blocked here; reconstructed from multiple summaries.)* Background: Manus bet on **context engineering over fine-tuning**, shipping improvements "in hours instead of weeks" and staying "orthogonal to the underlying models". They **rebuilt the agent framework four times**, calling the process "Stochastic Graduate Descent" (manual architecture search plus prompt fiddling plus empirical guesswork).

1. **Design around the KV-cache.** Stable prefix, append-only, deterministic serialization, explicit breakpoints (§5).
2. **Mask, don't remove** tools (§5.3).
3. **Use the file system as context.** Treat the sandbox FS as "unlimited, persistent, and directly operable" memory. Compression must be **restorable**: drop a web page's content but keep its **URL**; drop a document's body but keep its **path**, so the agent can re-fetch. Irreversible compression is risky because you can't know which detail will matter 10 steps later.
4. **Manipulate attention through recitation.** The agent keeps rewriting a **`todo.md`**, which pushes the global plan into the *recent* end of the context to fight lost-in-the-middle and goal drift over ~50-call tasks.
5. **Keep the wrong stuff in.** Don't hide failed actions and error traces. Seeing them "implicitly updates the model's beliefs" and reduces repeats. Error recovery is "one of the clearest indicators of true agentic behavior", and is under-tested in benchmarks.
6. **Don't get few-shotted.** Repetitive action-observation pairs in history make the model imitate the pattern, causing drift and overgeneralization (e.g. reviewing 20 résumés identically). Introduce **structured variation**: different serialization templates, phrasings, small formatting noise.

Yichao Ji's follow-up warning: context engineering can **overfit** to today's model limitations; "we never commit to an architecture based on static benchmarks" (paraphrase of an X post).

---

## 7. Getting information *out*: compaction, clearing, resets

### 7.1 Compaction
"Taking a conversation nearing the context window limit, summarizing its contents, and reinitiating a new context window with the summary." It is the "first lever" for long-term coherence.
- **Claude Code's implementation**: the model summarizes the history, preserving "architectural decisions, unresolved bugs, and implementation details while discarding redundant tool outputs", then continues with the summary **plus the five most recently accessed files**.
- **Tuning recipe**: "Start by **maximizing recall** … then iterate to improve **precision**." Tune on complex real traces.
- **Risk**: "overly aggressive compaction can result in the loss of subtle but critical context whose importance only becomes apparent later." Practitioner advice: never rely on compaction to preserve critical rules; put them in CLAUDE.md/AGENTS.md, which are re-injected (from an awesome-list summary of a Claude Code compaction deep-dive).
- **Codex's version** (secondary sources): past `auto_compact_limit`, Codex calls a `/responses/compact` endpoint that returns a replacement history including a compaction item with **opaque `encrypted_content`**. This is model-side compaction that may preserve latent state the user can't read.
- **Server-side compaction API** (Claude Developer Platform) exists; the awesome-list summary attributes an 84% token reduction to it, but the number I verified (below) is for *context editing*.
- **Models are getting better at compaction**: on BrowseComp, given a compaction budget, Sonnet 4.5 stayed flat at **43%**, Opus 4.5 scaled to **68%**, and Opus 4.6 reached **84%** "with the same setup" ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)). Compaction quality is a *model capability*, which supports the bitter-lesson view.
- 2026 research trend: **agent-controlled compression**, where the agent calls a "compress now" tool at natural boundaries instead of the harness compacting at a fixed threshold (LangChain *Autonomous Context Compression*; *Active Context Compression / Focus Agent*, arXiv 2601.07190, reporting a 22.7% token reduction with no accuracy loss; both via awesome-list summaries).
- A reverse-engineering study of Claude Code describes a **five-stage progressive compaction** pipeline (budget reduction → snip → microcompact → context collapse → auto-compact) (arXiv 2604.14228, awesome-list summary; unverified).

### 7.2 Tool-result clearing / context editing (the lightest touch)
"Once a tool has been called deep in the message history, why would the agent need to see the raw result again?" This is "one of the safest lightest touch forms of compaction."
- Anthropic's **context editing** feature (Sep 2025) automatically clears stale tool calls and results near the limit. **Results** ([announcement](https://claude.com/blog/context-management)): on an internal agentic-search eval, **context editing alone: +29%**; **context editing + memory tool: +39%** over baseline; in a **100-turn web-search eval**, it let agents finish workflows that otherwise failed **while reducing token consumption by 84%**.
- It can also clear old **thinking blocks**, which is exactly the mechanism that, when buggy, caused the postmortem incident (§5.4).

### 7.3 Context resets (clean slate + handoff)
- Compaction preserves continuity but "doesn't give the agent a clean slate, which means **context anxiety** can still persist." A reset starts a fresh agent with a **structured handoff artifact** ([long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)).
- Needed for Sonnet 4.5; **unnecessary for Opus 4.5**, where the behavior "was gone. The resets had become dead weight" ([Managed Agents](https://www.anthropic.com/engineering/managed-agents)).
- Costs: orchestration complexity, token overhead, latency. Requirement: the handoff must carry enough state, which in practice means progress files, a feature list and git history.

### 7.4 Irreversibility, and the session-as-context-object solution
Managed Agents points out that compaction, trimming and memory writes are all **irreversible decisions about what to keep**: "It is difficult to know which tokens the future turns will need." Their fix: store the full **append-only session log** *outside* the context window and expose `getEvents()` so the brain can **re-read positional slices** (rewind, re-read before a specific action). The harness can transform fetched events (e.g. for cache hit rate) before they enter the window. This separates **recoverable storage (session)** from **context management policy (harness)**. Anthropic cites prior work treating context as an object in a REPL that the LLM slices with code ([arXiv 2512.24601](https://arxiv.org/pdf/2512.24601); I believe this is the "Recursive Language Models" paper, but that is unverified).

**Unifying principle**: *compress reversibly*. Keep pointers to everything you drop (Manus URLs/paths; Managed Agents session log).

### 7.5 Choosing a technique
| Situation | Technique |
|---|---|
| Long back-and-forth conversation needing continuity | Compaction |
| Old bulky tool results no longer needed | Tool-result clearing |
| Iterative development with milestones | Structured note-taking / progress files |
| Model shows context anxiety or heavy pollution | Context reset + handoff |
| Parallel exploration, research, breadth-first | Sub-agents |
| Very long horizon, need for re-inspection | External session log + JIT re-reading |

(First three rows paraphrase Anthropic: "Compaction maintains conversational flow…; Note-taking excels for iterative development with clear milestones; Multi-agent architectures handle complex research…")

---

## 8. Sub-agents as context isolation

- "Each subagent might explore extensively, using tens of thousands of tokens or more, but returns only a condensed, distilled summary of its work (often **1,000–2,000 tokens**)" ([context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- "The essence of search is **compression**." Sub-agents compress in parallel in their own windows ([multi-agent research](https://www.anthropic.com/engineering/multi-agent-research-system)).
- **Isolated vs forked** sub-agents (LangChain, Sep 2026, awesome-list summary): *isolated* starts fresh (a firewall against pollution); *forked* inherits the parent's conversation (shares understanding, inherits pollution). Choose by whether the subtask needs the parent's history.
- **Avoid the game of telephone**: sub-agents write artifacts to the file system and return **references**, not full content.
- LangChain's architecture comparison reports sub-agents processing **67% fewer tokens than skills** in multi-domain scenarios because isolation prevents cross-domain bloat (awesome-list summary; unverified).
- Costs: total tokens go *up* (~15× chat for multi-agent research). Isolation also means sub-agents lack the parent's tacit context, so delegation messages must be detailed (objective, output format, tools, boundaries).
- Cache note: a sub-agent is also the right way to use a *cheaper model* without breaking the parent's cache.

---

## 9. Memory

### 9.1 Memory taxonomy (cognitive-science lens)
From **CoALA** (Sumers et al. 2023, *Cognitive Architectures for Language Agents*) and common usage:

| Type | Human analogue | Agent implementation | Example |
|---|---|---|---|
| **Working memory** | what you're thinking about now | the **context window** | current messages, todo.md recitation |
| **Episodic** | "what happened" | logs of past trajectories, session event logs, progress files, git history | `claude-progress.txt`, Managed Agents session |
| **Semantic** | facts about the world/user | knowledge files, vector stores, user profiles | memory-tool files, CLAUDE.md facts |
| **Procedural** | how to do things | **skills**, tools, code, prompts, playbooks, and the weights | Agent Skills, Voyager skill library, ACE playbook, learnings.md |
| **Parametric** | learned instincts | model weights | fine-tuning, RL (note 05) |

Another axis: **where memory lives** (in-context / external non-parametric / parametric) and **who writes it** (harness-controlled vs model-controlled, i.e. "agentic memory").

### 9.2 File system as memory (Weng Pattern 2)
Weng: "A harness should not carry the entire workflow and all logs in context; instead, it should keep durable state in files." Long-horizon artifacts (experiment logs, diffs, paper summaries, error traces, trajectories) "often grow much longer than the context window that the model has trained for." And: "Learning how to read, write, and edit the file system (commonly via `bash` commands) is a foundation skill for LLMs, and thus managing persistent memory in the simple form of files **naturally benefits from improvements in core model capability**."

Why files beat bespoke memory infrastructure:
1. **Universal interface**: `ls/cat/grep/sed` are heavily represented in pretraining data.
2. **Inspectable by humans and other agents**, so they double as an observability and collaboration surface.
3. **Hierarchical, with metadata** (names, folders, timestamps) that carry meaning.
4. **Composable with git**, which adds versioning, diffs and rollback for free.
5. **Scales with model capability**, which makes it bitter-lesson compatible. Anthropic: memory, skills and programmatic tool calling "are all built from the bash and text editor tools."

Concrete instances:
- **Anthropic memory tool** (Sep 2025): a client-side, file-based directory that Claude can create, read, update and delete across conversations; the developer owns storage.
- **Structured note-taking**: NOTES.md, to-do lists, progress files.
- **Claude plays Pokémon**: "maintains precise tallies across thousands of game steps", builds maps and strategy notes, and after context resets "reads its own notes and continues multi-hour training sequences."
- **Model progress on memory quality** ([Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence)): after **14,000 steps**, Sonnet 3.5 "treated memory as a transcript": **31 files**, including near-duplicates about caterpillar Pokémon, and was still in the second town. Opus 4.6 at the same step count had **10 files organized into directories, three gym badges, and a learnings file distilled from its own failures**. **Lesson: the harness provides the memory *substrate*; the model's skill decides memory *quality*.**
- **BrowseComp-Plus**: giving Sonnet 4.5 a memory folder raised accuracy **60.4% → 67.2%** (same source).
- **Research-system lead agent** saves its plan to memory because context beyond 200k gets truncated.
- **Long-running coding**: `feature_list.json` (JSON so the model doesn't casually rewrite it), `claude-progress.txt`, `init.sh`, git log.

### 9.3 MemGPT / Letta: memory as virtual memory
[Packer et al. 2023, *MemGPT: Towards LLMs as Operating Systems*](https://arxiv.org/abs/2310.08560) (UC Berkeley; renamed **Letta** in Sep 2024):
- **OS analogy**: context window = RAM ("main context"); external storage = disk ("external context"). **Virtual context management** pages information between them.
- The **LLM itself** decides what to page in and out by calling memory functions. This is self-directed memory management.
- Main context is split into system instructions, a **working context** (editable core memory such as persona and user facts), and a FIFO message queue. External context has **recall storage** (full message history, searchable) and **archival storage** (arbitrary documents, vector-searchable).
- Uses interrupt-like events: memory-pressure warnings as the queue fills prompt the model to save important information before eviction.
- Evaluated on long multi-session chat and large-document QA *(details unverified)*.
- **Historical significance**: MemGPT anticipated the 2025–26 consensus (agent-controlled memory, OS framing, paging). The difference is that 2026 systems tend to use **plain files and bash** rather than bespoke memory APIs, because frontier models became good enough at file manipulation.

### 9.4 Learned and evolving memory (bridge to RSI)
- **ACE** (Zhang et al. 2025): context as an **evolving playbook** of itemized bullets, with Generator → Reflector → Curator and deterministic merging to avoid **context collapse** and **brevity bias**. Memory that *learns from rollouts*.
- **MCE** (Ye et al. 2026): evolves the *mechanism* (the context-engineering skill) as well as the content. This is meta-level memory.
- **Agent-written skills** (Anthropic's stated goal; Voyager; Lin et al. 2026 show even a 9B model can write skills "procedurally isomorphic" to Opus's).
- **OpenViking** (ByteDance/Volcengine): a "context database" that unifies memory, resources and skills under a **filesystem paradigm**, with hierarchical delivery and a self-evolving layer (awesome-list summary). **Relevant for a ByteDance interview.**
- These sit on rungs 2 ("structured context") and 5 ("optimizer") of Weng's ladder; see note 03.

### 9.5 Memory risks
- **Poisoning and injection**: memory persists attacker-planted content across sessions, so treat memory writes as a trust boundary.
- **Staleness and drift**: memory goes out of date (OpenAI's "doc-gardening" agents exist for this reason).
- **Bloat and duplication**: Sonnet 3.5's 31-file Pokémon memory. Memory needs **curation, dedup and consolidation** (ACE's periodic refinement).
- **Reward hacking through memory**: in self-improving loops, memory can store shortcuts that exploit the evaluator. Keep evaluator artifacts out of writable memory (AHE's read-only directories).
- **Eval contamination**: Claude found **git history from previous trials** during evals and gained an unfair advantage ([demystifying evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)). Memory must be isolated between trials.
- **Privacy**: what is remembered about users, where it's stored, and who can read it.

---

## 10. Putting it together: a reference context pipeline

```
 ┌──────────── PREFIX (stable, cached) ─────────────┐┌──────── SUFFIX (grows, append-only) ────────┐
 │ system prompt (right altitude, no timestamps)     ││ user task                                   │
 │ tool defs (fixed set, deterministic order;        ││ turn 1: thinking, tool call, result         │
 │            masked not removed)                    ││ turn 2: …        (old results → cleared)    │
 │ skills metadata (name+description only)           ││ … [compaction summary + 5 recent files]     │
 │ AGENTS.md / CLAUDE.md (map, short)                ││ <system-reminder> updates as messages       │
 └───────────────────────────────────────────────────┘│ todo.md recitation near the end             │
                                                      └─────────────────────────────────────────────┘
          ▲ JIT loads (grep/cat/skill files/tool search)          │ writes
          │                                                       ▼
 ┌──────────────────── EXTERNAL MEMORY (files / session log / git) ─────────────────────┐
 │ progress files · feature_list.json · learnings.md · memory dir · sub-agent artifacts  │
 │ full session event log (re-readable slices) · URLs/paths kept for restorable compress │
 └──────────────────────────────────────────────────────────────────────────────────────┘
          ▲ summaries (1–2k tokens) / file references
 ┌────────┴─────────┐ ┌──────────────────┐ ┌──────────────────┐
 │ sub-agent A      │ │ sub-agent B      │ │ sub-agent C      │   isolated windows
 └──────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## 11. Why this matters for RSI

1. **Context is the cheapest learnable state.** Before touching weights, a system can "learn" by updating its context: playbooks, skills, memory. This is persistent self-improvement *without gradient updates* (ACE, MCE, Dynamic Cheatsheet, Voyager).
2. **Long-horizon auto-research is bottlenecked by context and memory.** Trehan & Chopra (2026) list "memory and context degradation: long-horizon projects lose critical details unless logs are written as persistent artifacts" as one of six failure modes of autonomous research (via Weng).
3. **Harness-optimization agents need context engineering too.** Meta-Harness gives the proposer the full execution history as a **file system** it greps instead of "shoveling everything into a single prompt context"; AHE builds layered evidence (raw trace → per-task report → benchmark overview) for token efficiency. The optimizer applies the same context discipline to itself.
4. **Weng's long-run bet**: "context engineering will and should become a core part of intelligence, rather than staying in the software system layer." There is evidence of this already: compaction and memory quality improve sharply across model generations (BrowseComp compaction: 43% → 68% → 84%; Pokémon memory quality).
5. **Safety**: memory is where reward hacks and injected instructions can persist and compound across iterations of a self-improvement loop, so memory hygiene is RSI hygiene.

---

## 12. Key numbers

| Number | What | Source |
|---|---|---|
| 18 | models tested in Chroma's context-rot study | Chroma, Jul 2025 |
| ~100:1 | input:output token ratio in Manus agents; ~50 tool calls per task | Manus (via summaries) |
| 10× | uncached vs cached input price ($3.00 vs $0.30/MTok, Sonnet) | Manus; Anthropic "cached tokens are 10% the cost" |
| 4 | times Manus rebuilt its agent framework | Manus |
| 1–2k | tokens a sub-agent typically returns | Anthropic |
| 5 | most-recently-accessed files re-attached after Claude Code compaction | Anthropic |
| +29% / +39% | context editing / context editing + memory tool on agentic search | Anthropic, Sep 2025 |
| −84% | tokens in a 100-turn web-search eval with context editing | same |
| 43 → 68 → 84% | BrowseComp with compaction: Sonnet 4.5 → Opus 4.5 → Opus 4.6 | Anthropic, Apr 2026 |
| 60.4 → 67.2% | BrowseComp-Plus with a memory folder (Sonnet 4.5) | same |
| 31 vs 10 files | Pokémon memory at 14k steps: Sonnet 3.5 (still in 2nd town) vs Opus 4.6 (3 badges) | same |
| 150k → 2k | tokens via code-API file tree for MCP (−98.7%) | Anthropic, Nov 2025 |
| 25k | default tool-output token cap in Claude Code | Anthropic |
| 200k | context size beyond which the research lead agent's history is truncated, so the plan is saved to memory | Anthropic, Jun 2025 |

---

## 13. Open questions

1. **Learned vs engineered context management.** Will compaction, retrieval and memory curation be fully absorbed into models (trained end-to-end via RL on long-horizon tasks), or remain harness policy? What is the right training signal for "what to remember"?
2. **Reversible vs irreversible compression.** Is "keep everything in an external log plus re-read on demand" always better than summarization? What is the latency and cost trade-off at scale?
3. **Evaluating memory.** How do we benchmark cross-session memory: usefulness, staleness, poisoning resistance? LongMemEval covers conversational QA; agentic memory needs more.
4. **KV-cache vs adaptivity.** Cache-friendliness pushes toward static prefixes and append-only histories, while good context engineering wants to *edit* context. Server-side context editing and encrypted compaction are partial answers. Is there a principled architecture, e.g. hierarchical or segment-level caching?
5. **Long context vs context engineering.** If models with 1M+ windows stopped rotting, how much context engineering would remain? Anthropic bets on "foreseeable" pollution concerns; Weng sees them "intertwined".
6. **Multi-agent shared memory.** How should agents share memory consistently (distributed-systems problems: consistency, conflicts, typed handoffs)?
7. **Memory as a self-improvement substrate.** When does accumulating learnings help, and when does it entrench mistakes (diversity collapse, Weng challenge 4)?

---

## 14. Interview angles: questions and model answers

**Q1. What is context engineering and how does it differ from prompt engineering?**
A: Prompt engineering writes good instructions, mostly once. Context engineering curates the *entire* token state at *every* inference step: system prompt, tools, examples, history, tool results, retrieved data, memory. The goal is "the smallest set of high-signal tokens that maximizes the desired outcome." It matters for agents because they generate unbounded tokens across many turns, and models degrade as context grows.

**Q2. Why not just use a 1M-token window and put everything in?**
A: Three reasons. (1) **Context rot**: Chroma's 18-model study shows non-uniform degradation with length, worse with semantically similar distractors and low needle-question similarity. Attention is an n² budget, and models see fewer long sequences in training. (2) **Cost and latency**: each turn re-prefills the context; caching helps only for stable prefixes. (3) **Distraction and confusion**: irrelevant tools and results steer behavior. So long windows are a safety margin, not a strategy.

**Q3. Explain KV-cache-aware agent design.**
A: Prefill computes K/V for every prompt token. Agents resend the full history each turn, so servers reuse the K/V of an exact matching prefix, and cached tokens cost about 10% of uncached. Manus calls hit rate the most important production metric (100:1 input:output). Design rules: stable static prefix (system prompt and tools first, no timestamps); append-only history; deterministic serialization and tool order; updates as appended messages; mask tools instead of removing them; don't switch models mid-session (use sub-agents). Pitfall: Claude Code's thinking-clearing bug both degraded reasoning and caused cache misses.

**Q4. Compare compaction, tool-result clearing, context resets, and memory files.**
A: Clearing removes stale raw tool outputs. It is the lightest and safest (Anthropic: +29% alone, 84% fewer tokens over 100 turns). Compaction summarizes history and continues, preserving flow but lossy; tune for recall first, then precision. Claude Code re-attaches the 5 most recent files. Resets start fresh from a structured handoff. They fix "context anxiety", cost orchestration effort, and became unnecessary for Opus 4.5. Memory files persist selected state across all of these. In practice you combine them, with critical rules kept in re-injected files like CLAUDE.md, never only in compacted history.

**Q5. What does "just-in-time context" mean and when would you still use RAG?**
A: The agent holds references (paths, URLs, queries) and loads content with tools when needed, using metadata as signal and building understanding progressively. Claude Code is hybrid: CLAUDE.md up front, grep/glob at runtime, which avoids stale indexes. Use pre-computed retrieval when latency matters, when the corpus is static (e.g. legal or finance), or when the agent's tools can't navigate the data well. Anthropic advises starting with agentic search and adding semantic search only if needed.

**Q6. How would you design memory for a long-running research agent?**
A: Use the file system as the substrate: a plan file (re-read often, recited near the end of context), an append-only experiment log with configs and results (including failures, "keep the wrong stuff in"), a distilled `learnings.md` curated with dedup, artifacts from sub-agents stored as files and referenced by path, and git for versioning and rollback. Compress reversibly (keep paths and URLs). Isolate memory between eval trials. Keep evaluator files read-only. Periodically consolidate, ACE-style, with itemized updates rather than whole rewrites, to avoid context collapse. Measure memory value with ablations, e.g. BrowseComp-Plus 60.4 → 67.2% with a memory folder.

**Q7. How do sub-agents help with context, and what are the trade-offs?**
A: Each sub-agent explores in its own window (tens of thousands of tokens) and returns a 1–2k-token distilled summary or a file reference, so the lead's context stays clean. That is compression plus separation of concerns, and parallelism as a bonus. Trade-offs: much higher total tokens (~15× chat), loss of shared tacit context (delegation must be explicit), telephone-game information loss (mitigate with file artifacts), and poor fit for tightly coupled tasks. Isolated vs forked sub-agents is a design choice: a firewall vs inherited understanding.

**Q8. What's MemGPT's key idea and how does it relate to today's coding agents?**
A: MemGPT treats the LLM like an OS: the context window is RAM, external stores are disk, and the model pages information in and out with function calls (virtual context management), with memory-pressure warnings acting like interrupts. Today's agents keep the core idea (agent-controlled paging between the window and durable storage) but mostly use plain files and bash instead of bespoke memory APIs, because frontier models became fluent at file manipulation. Managed Agents' durable session log with `getEvents()` slices is the modern "disk".

**Q9. Manus says "keep the wrong stuff in" and "don't get few-shotted". Explain.**
A: Error traces in context let the model update its beliefs and avoid repeating failed actions; cleaning them away removes evidence. Error recovery is a hallmark of real agency and is under-benchmarked. Conversely, many near-identical past action-observation pairs act as accidental few-shot examples, and the model mimics them, causing drift. Inject structured variation in serialization and phrasing to break the rut.

**Q10. How is context engineering connected to recursive self-improvement?**
A: Context and memory are the first persistent, learnable state outside the weights. Systems like ACE (evolving playbooks), MCE (evolving the context-engineering *skill* itself, which is recursive), and agent-written skills improve future behavior without gradients. Self-improving harness optimizers (Meta-Harness, AHE) rely on file-system access to their own history and layered summaries. Weng predicts context management will migrate into model intelligence, and compaction and memory quality already climb with model generations. The risk is that memory also persists reward hacks and injections, so writable memory must be separated from evaluator state.

---

## Sources

Read in full:
- Anthropic. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (Sep 29, 2025).
- Anthropic. [Managing context on the Claude Developer Platform](https://claude.com/blog/context-management) (Sep 29, 2025): context editing and the memory tool.
- Anthropic. [Building agents with the Claude Agent SDK](https://claude.com/blog/building-agents-with-the-claude-agent-sdk) (Sep 2025).
- Anthropic. [Equipping agents with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) (Oct 2025).
- Anthropic. [Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) (Nov 2025).
- Anthropic. [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (Nov 2025).
- Anthropic. [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Mar 2026).
- Anthropic. [Harnessing Claude's intelligence](https://claude.com/blog/harnessing-claudes-intelligence) (Apr 2026).
- Anthropic. [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents) (Apr 2026).
- Anthropic. [April 23 Claude Code postmortem](https://www.anthropic.com/engineering/april-23-postmortem) (Apr 2026).
- Anthropic. [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) (Jun 2025).
- Weng, L. [Harness Engineering for Self-Improvement](../sources/weng-2026-harness-engineering-for-self-improvement.md) (Jul 2026).

Via search snippets or secondary summaries (blocked hosts):
- Ji, Y. [Context Engineering for AI Agents: Lessons from Building Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) (Jul 2025).
- Hong, Troynikov, Huber. [Context Rot](https://research.trychroma.com/context-rot) (Chroma, Jul 2025).
- Packer et al. [MemGPT: Towards LLMs as Operating Systems](https://arxiv.org/abs/2310.08560) (2023).
- OpenAI. [Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/) (Jan 2026); [Harness engineering](https://openai.com/index/harness-engineering/) (Feb 2026).
- Sumers et al. Cognitive Architectures for Language Agents (CoALA), 2023, from background knowledge.
- Liu et al. Lost in the Middle, 2023, from background knowledge.
