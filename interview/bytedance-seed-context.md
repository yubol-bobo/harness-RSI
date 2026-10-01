# ByteDance Seed / TikTok: context for a "harness + RSI" research-scientist interview

> Written 2026-10-01 for a newcomer. The goal is to connect your preparation on harness engineering and recursive self-improvement (RSI) to work ByteDance has actually published, so you can show "I know what you do, and here is how my thinking plugs in."
>
> **Verification policy.** Numbers come from paper abstracts or official pages (via search results, since arxiv/github.io/bytedance sites were not directly fetchable from this sandbox). Org and people facts come from press reports and are labeled **(reported)**. Anything I could not confirm is labeled **(unverified)**. Before the interview, open the arXiv pages yourself and re-check any number you plan to say out loud.

---

## 0. TL;DR: why "harness" and "RSI" for a ByteDance interview?

1. **ByteDance Seed is publishing directly on RSI and harness self-evolution.** On 2026-09-01, ByteDance Seed with collaborators (SUTD, M-A-P, TokenWave.AI and others) released the **"Self-Developing Agents"** project: three benchmarks (**Aspire**, **S³Gym**, **HarnessDev**) framed as moving "from half-loop to closed-loop RSI". HarnessDev literally asks: *can LLMs create and evolve their own agent harness?* This is very likely why your recruiter said "prepare harness and RSI". **Read these three papers first.**
2. **ByteDance builds the infrastructure that self-improvement runs on:** the **verl** RL framework (HybridFlow), RL algorithms **DAPO** and **VAPO**, multi-turn tool RL (**ReTool**), RL-trained memory (**MemAgent**), self-evolving training environments (**Agent-World**), and a product-grade coding-agent harness (**TRAE / trae-agent**).
3. **Its agent models are trained with self-improving data loops:** UI-TARS ("iterative training with reflective online traces"), UI-TARS-2 (a "data flywheel" + multi-turn RL), Seed-Coder ("let the code model curate data for itself"), Seed-Prover (learning from Lean verifier feedback).

Your story: *"Harness engineering is how capability becomes agency; RSI is what happens when the harness, the data and the training loop are improved by the agent itself. ByteDance has the pieces (verl, DAPO, UI-TARS data flywheel, TRAE, HarnessDev). The open problems are evaluation, transfer, and keeping the evaluator outside the loop."*

---

## 1. Organization and people (reported; verify before quoting)

| Item | What is reported | Status |
|---|---|---|
| **Seed** | ByteDance's foundation-model research team (also historically called the Doubao large-model team). Models ship as **Doubao** via **Volcano Engine**. | Well established |
| **Wu Yonghui (吴永辉)** | Former Google Fellow / Google DeepMind VP; joined ByteDance in early 2025 as head of foundational research for Seed, reportedly reporting to CEO Liang Rubo ([TechNode, Feb 2025](https://technode.com/2025/02/24/former-google-deepmind-vp-joins-bytedance-as-seed-team-research-lead/); [SCMP](https://www.scmp.com/tech/big-tech/article/3299146/veteran-google-ai-researcher-joins-tiktok-owner-bytedance-lead-foundational-research)). | (reported) |
| **Seed Edge** | Long-term AGI research program launched Jan 2025: longer evaluation cycles, dedicated compute, "bold" topics; initial directions include the limits of reasoning and perception, hardware–software co-design, new learning methods, scaling ([TechNode, Jan 2025](https://technode.com/2025/01/24/bytedance-launches-seed-edge-for-ai-innovation-aiming-for-agi/); [量子位](https://www.qbitai.com/2025/01/247606.html)). | (reported) |
| **Top Seed** | Talent program for top PhD graduates and research interns. A 2026 campus round targeted ~30 new PhDs across LLMs, ML algorithms & systems, multimodal generation/understanding, speech; asks for strong ML/NLP/RL fundamentals, top-venue papers preferred, and strong coding/algorithms (ACM/ICPC, NOI/IOI a plus) ([牛客 posting](https://www.nowcoder.com/feed/main/detail/818af776760a4062a5b5795c7e993ad2)). | (reported) |
| **2026 priorities** | Reported company priorities: world models (a target to release at least one and benchmark against Google's Genie 3), keeping Seedance (video) top-tier, strengthening coding foundations, commercializing Doubao especially for office productivity ([KrASIA](https://kr-asia.com/bytedance-sets-four-ai-priorities-for-2026)). | (reported) |
| **Aug 2026 reorganization** | Seed reportedly created four first-level departments: **Pretrain Data** (Li Chenggang), **Horizon RL** (Tang Shengyu; "enhancing the basic intelligence ceiling of models through RL"), **Product Posttrain-Work** (Qin Yujia; B-end applications and **agentic models**), **Product Posttrain-Chat**. Separate reports of discussions about a >5T-parameter model, not officially announced ([TechNode, Aug 2026](https://technode.com/2026/08/20/bytedance-reorganizes-seed-foundation-model-team-amid-reported-5-trillion-parameter-model-plans/)). | (reported) |
| **AI Data & Safety** | ByteDance reportedly formed a new top-level "AI Data and Safety" department in Aug 2026, alongside Seed, Flow and Douyin ([TechNode, Aug 2026](https://technode.com/2026/08/12/bytedance-reportedly-forms-new-ai-data-and-safety-department/)). I found no published ByteDance frontier-safety framework. | (reported) / (unverified) |

**Interview use:** knowing that "Horizon RL" and "Posttrain-Work (agentic models)" exist tells you RL for long-horizon agents is a top priority. Don't recite org-chart gossip; use it only to choose emphasis.

---

## 2. The work, grouped by how it connects to harness / RSI

### 2.1 Directly about RSI and harness self-evolution (highest priority)

**Self-Developing Agents (ByteDance Seed + SUTD + M-A-P + TokenWave.AI, Sep 2026)**: project page `self-developing-agents.github.io`. Three benchmarks, each asking a different "can the loop actually close?" question:

| Paper | Question | Setup | Reported findings |
|---|---|---|---|
| **HarnessDev** ([arXiv 2609.01437](https://arxiv.org/abs/2609.01437)), Yuhao Wu et al. | *Can LLMs create and evolve their own agent harness?* | Shifts evaluation from task outputs to **the runnable harness itself**. *Creation*: from a minimal weak seed and a few cases, build a complete harness. *Evolution*: revise your own harness using downstream execution feedback. Six creator LLMs, four domains, five downstream benchmarks, 2,207 held-out instances. | Generated harnesses stay well behind mature human-engineered references on **code** and **search/research** (one summary cites 52.4 vs. 92.2 on BrowseComp, **(verify)**), but match or beat references on **writing** and **ML experimentation**. Evolution gives gains that are **unstable**, **transfer only partially** to held-out tasks, and **depend heavily on which model runs the harness**. |
| **Aspire** ([arXiv 2608.31111](https://arxiv.org/abs/2608.31111)) | *Can models self-evolve from a vague goal* (e.g., "become a better physicist") without seeing the test tasks? | The agent only gets a natural-language capability goal; it must choose data, update method (**weights or harness**), build its own training/validation signals, decide when to evaluate. Hidden expert-written evaluation: 520 items over 6 goals. | Vague goals shift effort toward *interpreting the goal*. Agents routinely complete training and harness-editing loops, but **weight-level gains are sparse and unstable**, and the best evolved harness is **still below the engineered Qwen-Agent reference**. |
| **S³Gym** ([arXiv 2608.31100](https://arxiv.org/abs/2608.31100)) | *Can LLMs turn self-testing and self-judging into self-improvement?* | Seven text games. The agent sees environment changes but **not** the programmatic verifier's step rewards or final score; self-judgments decide how experience is organized, environment scores measure real performance. Compares History-ICL, score-conditioned Summary Memory, and parameter Training. | Improvement is **task-dependent and often fails to transfer**. Summaries help when experience compresses into rules; raw history wins when success depends on precise state. Training gives big gains on some tasks and **severe negative transfer** on others. "Recognizing success is not the same as learning a reusable policy." |

**Why this matters for you.** These papers formalize the exact concepts in your notes: *closed loop vs. half loop*, *the agent must build its own evaluator* (Aspire, S³Gym), *harness as the unit of improvement* (HarnessDev), and *transfer to held-out tasks as the real test*. They also contain the safety-relevant design choice from [note 08](../notes/08-safety-and-theory-of-rsi.md): **S³Gym deliberately hides the true verifier from the agent**, which is "evaluator outside the loop" made into a benchmark design.

**Also relevant, broader:** *The Last AI Built by Humans: Toward Genuine Recursive Self-Improvement* ([arXiv 2609.11873](https://arxiv.org/abs/2609.11873), Sep 2026): a large multi-institution roadmap paper (SJTU, Tsinghua, ByteDance, Xiaohongshu, Shanghai AI Lab and others are among listed affiliations). It defines RSI as an autonomous, closed-loop process in which a system identifies its limitations, develops and validates improvements, and uses the gains to improve the improvement process itself. I have not read the full text; treat details as **(unverified)**.

### 2.2 Self-evolving environments and agent self-training

- **Agent-World** (Renmin Univ. + ByteDance Seed, [arXiv 2604.18292](https://arxiv.org/abs/2604.18292), 2026): a "self-evolving training arena". (1) *Environment–task discovery*: autonomously explores real-world environment themes, tool ecosystems and databases, and synthesizes **verifiable tasks with controllable difficulty**. (2) *Continuous self-evolving training*: multi-environment RL plus an arena that **diagnoses capability gaps and synthesizes targeted tasks**, so policy and environments **co-evolve**. Reported to beat environment-scaling baselines across 23 agent benchmarks. RSI link: this closes the loop on the *curriculum*, not just the policy. Safety link: the environment generator is also an evaluator, so Goodhart applies to it.
- **Agent-R** (Fudan + ByteDance, [arXiv 2501.11425](https://arxiv.org/abs/2501.11425), Jan 2025): iterative self-training for **reflection**. Uses MCTS to find a failed trajectory's first error step and splice it onto a correct sibling path, so the model learns to recover mid-trajectory rather than at the end. RSI link: the model's own failures become its training data, iterated.

### 2.3 Agent models trained with data flywheels (GUI / computer use)

- **UI-TARS** ([arXiv 2501.12326](https://arxiv.org/abs/2501.12326), Jan 2025): a **native** GUI agent: screenshots in, keyboard/mouse actions out, end-to-end (no GPT-4o wrapper with hand-written workflows). Four ideas: enhanced perception, unified action space across platforms, "System-2" reasoning (task decomposition, reflection, milestone recognition), and **iterative training with reflective online traces**: automatically collect, filter and reflectively refine new traces on hundreds of VMs. Reported OSWorld 24.6 (50 steps) / 22.7 (15 steps) vs. Claude 22.0 / 14.9 at the time; AndroidWorld 46.6 vs. GPT-4o 34.5.
- **UI-TARS-1.5** (Apr 2025): open-weights update that adds RL-based reasoning (details not verified here).
- **UI-TARS-2** ([arXiv 2509.02544](https://arxiv.org/abs/2509.02544), Sep 2025): "Advancing GUI Agent with Multi-Turn RL". (1) **Data flywheel** that iteratively improves model and data together (continual pre-training → SFT → multi-turn RL, starting from Seed1.6 checkpoints). (2) **Stabilized multi-turn RL framework**. (3) **Hybrid GUI environment** that adds file system and terminal to pure GUI. (4) **Unified sandbox platform** for large-scale rollouts. Reported: Online-Mind2Web 88.2, OSWorld 47.5, WindowsAgentArena 50.6, AndroidWorld 73.3.
  - *Harness link:* "hybrid GUI + terminal + file system" is a harness design decision (action space). The **sandbox platform is harness infrastructure**.
  - *RSI link:* the data flywheel is persistent self-improvement where the model's own rollouts become the next round's training data.
- **Game-TARS** ([arXiv 2510.23691](https://arxiv.org/abs/2510.23691)): generalist multimodal game agents, same TARS line (details not verified here).

### 2.4 Coding agents and the TRAE harness

- **TRAE**: ByteDance's AI-native IDE (international: trae.ai). Includes an autonomous **SOLO** mode that takes a natural-language spec and runs requirement analysis, code generation, terminal commands, browser testing and deployment as a multi-step agent. A standalone SOLO version (desktop + web, "Code" and "MTC / More Than Coding" modes) reportedly launched 2026-03-31 **(reported)**. User figures I found (e.g., >1M MAU) are from secondary sources with unclear dates; **don't quote them**.
- **trae-agent** (open-sourced 2025-07-04; [github.com/bytedance/trae-agent](https://github.com/bytedance/trae-agent)): the core agent of TRAE released as a research-friendly CLI harness. Tech report *Trae Agent: An LLM-based Agent for Software Engineering with Test-time Scaling* ([arXiv 2507.23370](https://arxiv.org/abs/2507.23370)): frames issue resolution as **optimal solution search** with **modular agents for generation, pruning and selection** ("agent-based ensemble reasoning"), to handle large candidate spaces and repository-level understanding. Tools include a string-replace file editor, a persistent bash shell, and a sequential-thinking tool. Reported **75.20% Pass@1 on SWE-bench Verified** (first place on the leaderboard at the time) and +10.22% average Pass@1 over baselines. Also at AgenticSE@ASE 2025 and ICSE 2026 (as "Agent-Based Ensemble Reasoning for Repository-Level Issue Resolution").
  - *Harness link:* this is a textbook harness: tools + loop + test-time scaling (generate many patches, prune, select). Selection is an **evaluator**, so all the Goodhart questions apply (does the selector overfit to tests? to style?).
- **Seed-Coder** ([arXiv 2506.03524](https://arxiv.org/abs/2506.03524), 2025): 8B base/instruct/reasoning code models. Key idea, "**let the code model curate data for itself**": LLM-based scoring and filtering instead of hand-written rules to build a ~6T-token code corpus from GitHub code, commits and code-related web data. *RSI link:* a model-in-the-loop data pipeline is a weak form of self-improvement; *risk link:* model-graded data can drift or collapse toward the grader's preferences.
- **Seed Diffusion Preview** ([arXiv 2508.02193](https://arxiv.org/abs/2508.02193), 2025, with Tsinghua AIR): discrete-diffusion code model, 2,146 tokens/s on H20 GPUs, two-stage curriculum (mask-based then edit-based corruption); reported HumanEval 84.8, MBPP 88.0. *Harness link:* fast generation changes harness economics: more candidates per second makes test-time search (like trae-agent's) cheaper.

### 2.5 RL infrastructure and algorithms (the engine of self-improvement)

- **HybridFlow / verl** ([arXiv 2409.19256](https://arxiv.org/abs/2409.19256), EuroSys 2025; [github.com/volcengine/verl](https://github.com/volcengine/verl)): Seed + HKU. Hybrid programming model that combines single-controller flexibility (easy to write new RL dataflows) with multi-controller efficiency, decoupling control flow from computation; a **3D-HybridEngine** reshards the actor between training and generation with zero memory redundancy. Reported 1.5×–20× throughput over prior frameworks. verl is now one of the most widely used open RL-for-LLM libraries, and DAPO, ReTool and MemAgent were built on it.
  - *Why you should care:* RSI at the weight level is RL on self-generated experience; verl is the substrate. Multi-turn **agentic** RL (tools, sandboxes, async rollouts) is where the framework work is heading, which is also harness work: the rollout environment *is* a harness.
- **DAPO** ([arXiv 2503.14476](https://arxiv.org/abs/2503.14476), NeurIPS 2025; Seed + Tsinghua AIR): open-source large-scale RL system. Four techniques: **Clip-Higher** (decoupled upper/lower clip ranges to prevent **entropy collapse**), **Dynamic Sampling** (drop prompts whose samples are all right or all wrong, since they give zero GRPO advantage), **Token-level policy-gradient loss** (so long responses aren't under-weighted), **Overlong reward shaping** (reduce noise from truncated responses). 50 points on AIME 2024 with Qwen2.5-32B base, vs. 47 for DeepSeek-R1-Zero-Qwen-32B, with about half the training steps; a naive GRPO run got 30.
  - *RSI/safety link:* Clip-Higher is a direct fix for **diversity collapse** in an RL self-improvement loop; overlong shaping is a small case study in **reward design** (the reward for a truncated answer is a proxy).
- **VAPO** ([arXiv 2504.05118](https://arxiv.org/abs/2504.05118), 2025): value-based PPO for long CoT; tackles **value-model bias, heterogeneous sequence lengths, sparse rewards**. Reported 60.4 on AIME 2024 with Qwen-32B base, >10 points over DAPO and R1-Zero-Qwen-32B in the same setting, within 5,000 steps.

### 2.6 Tool use, memory, and long-horizon agency

- **ReTool** ([arXiv 2504.11536](https://arxiv.org/abs/2504.11536), ICLR 2026): RL for **strategic tool use**, interleaving real-time code execution inside reasoning. Cold-start SFT on code-augmented reasoning data, then RL with **multi-turn code-interpreter rollouts** and outcome rewards. ReTool-32B: 67% on AIME 2024 after 400 RL steps vs. 40% after 1,080 steps for a text-only RL baseline; 72.5% in an extended setting. *Harness link:* the tool (sandboxed interpreter) is part of the RL environment; the model learns *when* to call it, i.e., it internalizes part of the harness policy.
- **MemAgent** ([arXiv 2507.02259](https://arxiv.org/abs/2507.02259), ICLR 2026; Seed + Tsinghua AIR): reads text chunk by chunk and **overwrites a fixed-length memory** of ordinary tokens; trained with an extension of DAPO for multi-conversation (independent-context) rollouts, rewarding memory updates that lead to correct answers. Trained on 32K text with 8K context, it extrapolates to 3.5M-token QA with <5% loss and gets 95%+ on 512K RULER. *Harness link:* context management, normally hand-written harness logic, becomes a **learned policy**. Weng lists memory lifecycle as RSI bottleneck #2.
- **M3-Agent** ([arXiv 2508.09736](https://arxiv.org/abs/2508.09736), ICLR 2026): multimodal agent with **long-term episodic and semantic memory**, entity-centric; RL-trained; new **M3-Bench** (100 robot-view videos + 929 web videos). Reported +6.7 / +7.7 / +5.3 points over a Gemini-1.5-pro + GPT-4o prompting baseline on M3-Bench-robot / M3-Bench-web / VideoMME-long.

### 2.7 Verified reasoning (the "perfect evaluator" regime)

- **Seed-Prover** ([arXiv 2507.23726](https://arxiv.org/abs/2507.23726), 2025): lemma-style whole-proof Lean model that **iteratively refines proofs using Lean feedback**, proved lemmas and self-summarization; trained with RL using formal verification. Reported 78.1% of formalized past IMO problems, saturates MiniF2F, >50% on PutnamBench; at IMO 2025 fully proved 5 of 6 problems (with Seed-Geometry for P2). **Seed-Prover 1.5** ([arXiv 2512.17260](https://arxiv.org/abs/2512.17260)) reports 88% PutnamBench, 80% Fate-H, 33% Fate-X, via "learning from experience".
  - *RSI link (good talking point):* Lean is an evaluator the agent **cannot hack** (short of exploiting the checker). That makes theorem proving the cleanest domain for closed-loop self-improvement. Contrast with HarnessDev/Aspire, where evaluators are fuzzy and gains don't transfer. This is Weng's bottleneck #1 ("weak and fuzzy evaluators") illustrated inside ByteDance's own portfolio.

### 2.8 The foundation models (agentic capabilities)

| Model | Date | Agent-relevant facts (reported) |
|---|---|---|
| **Seed1.5-Thinking** ([arXiv 2504.13914](https://arxiv.org/abs/2504.13914)) | Apr 2025 | MoE, 20B active / 200B total; AIME 2024 86.7, Codeforces 55.0, GPQA 77.3. RL-trained reasoning. |
| **Seed1.5-VL** | May 2025 | Vision-language model; GUI/agent abilities (details not verified here). |
| **Seed1.6 / Doubao-Seed-1.6** ([Seed blog](https://seed.bytedance.com/en/blog/introduction-to-techniques-used-in-seed1-6)) | Jun 2025 | 256K context; **adaptive thinking** (AdaCoT: the model decides whether to use extended reasoning); multimodal, GUI interaction. Third-party wiki: MoE ~230B total / ~23B active **(unverified)**. Used as the starting checkpoint for UI-TARS-2. |
| **Seed1.8** ([arXiv 2603.20633](https://arxiv.org/abs/2603.20633), model card) | Dec 2025 – Mar 2026 | "Towards Generalized Real-World Agency": one model with a unified agentic interface (search, code generation/execution, GUI across desktop/web/mobile) rather than task-specific pipelines; configurable thinking modes; reported SOTA on GUI navigation (OSWorld, AndroidWorld) and agentic search. |
| **Seed2.0 / Doubao-Seed-2.0** ([Seed page](https://seed.bytedance.com/en/seed2)) | Feb 14, 2026 | Pro / Lite / Mini general "Agent models" plus a Code model (supports TRAE). Emphasis on long-horizon, multi-step real-world tasks; reported gold-medal-level performance on IMO/CMO/ICPC-style contests. A "Seed 2.1" appears on third-party sites **(unverified)**. |

**Pattern to notice:** Seed's model line moved from "reasoning model" (1.5-Thinking) → "adaptive thinking + GUI" (1.6) → "generalized agency in one model" (1.8) → "agent models for long-horizon work" (2.0). The harness is increasingly *inside* the model (native agents), while the outside harness (TRAE, sandboxes, verl rollouts) handles tools, permissions and evaluation.

### 2.9 TikTok-side research (brief)

TikTok/ByteDance also hire research scientists for recommendation, search/ads, multimodal content understanding, and trust & safety ("Business Integrity"). Recent job postings mention LLM applications for search/ads/recommendation **(reported from postings)**. If your interview is with a TikTok product-side team rather than Seed, connect harness/RSI ideas to (a) **LLM agents for content moderation and policy enforcement** (evaluator design, Goodhart on engagement metrics), and (b) **self-improving recommendation/ranking loops** (feedback loops are a classic Goodhart setting: optimizing watch time vs. user well-being). Ask your recruiter which team you are interviewing with.

---

## 3. Talking points that connect your preparation to ByteDance's work

Use these as 30–60 second "bridges". Each pairs a concept from your notes with a ByteDance paper.

1. **"Harness as the unit of improvement" → HarnessDev.** "Weng argues code is a universal language for harnesses, so an LLM optimizing harness code accesses a much bigger design space than prompt tuning. HarnessDev tests exactly that and finds model-built harnesses already match humans on writing and ML experimentation but lag badly on code and search. My hypothesis: domains with mature tool ecosystems and long-tail engineering knowledge (sandboxing, retries, caching, retrieval) are where human harnesses encode the most tacit experience. AHE's evidence-driven edits plus a component-level failure taxonomy could close that gap."
2. **"Transfer is the real test" → HarnessDev, Aspire, S³Gym.** "All three report gains that are unstable and transfer only partially. In Goodhart terms that's partly regressional: selecting the best of many variants on a dev set selects noise. I'd add replication, multiple-comparison correction and evaluation on a second model family as acceptance gates. HarnessDev's finding that gains depend on which model runs the harness suggests learning model-specific harness *diffs* (like Self-Harness) rather than one universal harness."
3. **"Evaluator outside the loop" → S³Gym hides the verifier; UI-TARS-2 sandbox platform.** "S³Gym separates self-judgment from environment-verified score. That's the right design: the agent can use its own judge to organize experience, but promotion decisions use a verifier it can't see. In production I'd extend that to permissions: the evolving agent can edit only a declared workspace, while tracer, verifier and model config are read-only, as in AHE."
4. **"Perfect verifiers make RSI work" → Seed-Prover vs. Aspire.** "Seed-Prover improves through Lean feedback, an evaluator you can't fool, and reaches IMO-level results. Aspire, where the agent must invent its own evaluation from a vague goal, sees sparse and unstable gains. The gap between these two is Weng's bottleneck #1: evaluator quality determines whether self-improvement compounds. A research direction: *verifier construction as a learnable skill*, with held-out human audits to catch Goodhart."
5. **"Diversity collapse" → DAPO Clip-Higher; Anthropic AAR.** "DAPO's Clip-Higher fixes entropy collapse in RL; at the population level the same problem shows up in harness evolution. Anthropic's automated researchers converged on similar ideas unless given diverse starting directions. I'd combine token-level entropy control (DAPO) with population-level quality-diversity archives (DGM-style) in an Agent-World-style arena."
6. **"Memory is a learned harness component" → MemAgent, M3-Agent.** "Weng lists memory lifecycle as a key bottleneck and predicts context engineering will become part of intelligence rather than staying in the software layer. MemAgent is exactly that: RL learns the overwrite policy of a fixed-size memory. A safety angle: *Your Agent May Misevolve* found safety alignment can decay as memory accumulates, so learned memory needs safety evals across time, not only QA accuracy."
7. **"Agentic RL needs a harness-shaped environment" → verl, ReTool, UI-TARS-2.** "In multi-turn tool RL, the environment includes the sandbox, the tool API, timeouts and the reward function. That *is* a harness. So harness design choices (tool descriptions, error messages, timeouts) change what the policy learns. The AI Scientist lengthening its own timeout shows that limits must be enforced outside the code the agent can edit, including during RL rollouts."
8. **"Self-curated data is weak RSI" → Seed-Coder, UI-TARS flywheel.** "Model-graded data filtering and reflective online traces are persistent self-improvement loops. Risks: model collapse and grader drift. Mitigations: anchor to real data, use external verification (execution, tests), and track diversity of the corpus over iterations."
9. **"Test-time scaling is search; selection is an evaluator" → trae-agent.** "trae-agent generates many patches, prunes, and selects. The selector is an evaluator subject to Goodhart: it can prefer patches that pass visible tests but don't fix the issue. Hidden regression tests and diverse selectors help. And if the agent ever evolves its own selector, the selector must be evaluated by something it can't edit."
10. **"Safety for self-improving agents is an engineering discipline" → your checklist.** "From DGM's objective hacking to Anthropic's automated researchers gaming their scorer, every closed loop we know of games its measurement eventually. I'd bring a concrete design: read-only trust boundary, hidden held-out evals, trusted-model review of every self-edit, diff-based tamper detection, and safety metrics tracked across iterations. That would make HarnessDev-style results trustworthy enough to deploy in TRAE." (See [note 08](../notes/08-safety-and-theory-of-rsi.md) §8.)

---

## 4. Likely interview format (reported, varies by team)

Sources: interview-guide aggregators and candidate reports ([Interview Query, ByteDance RS](https://www.interviewquery.com/interview-guides/bytedance-research-scientist); [Interview Query, TikTok AI RS](https://www.interviewquery.com/guides/tiktok-ai-research-scientist); Glassdoor; Chinese reports on 知乎/牛客/InfoQ). Treat as **(reported)**; formats vary across teams and over time.

| Stage | What to expect |
|---|---|
| Recruiter / HR screen | Background, team fit, timeline. |
| **2–4 technical rounds** (often with your future mentor/manager and team members) | Each typically mixes **(a) a deep dive on your own research** and **(b) a coding problem**. |
| Research deep dive | Interviewers press past the headline into **study design, implementation details, ablations, and why you made each choice**. Chinese reports on Seed say interviews focus on discussing LLM thinking: "what architecture, what data, what result", the theory behind the analysis, and ablations. A structured walkthrough is preferred over loose conversation. |
| Coding | LeetCode-style data structures and algorithms (medium, sometimes hard), and sometimes ML coding: implement self-attention, a loss, top-k sampling, PPO/GRPO advantage computation, etc. Top Seed postings explicitly value algorithmic coding skill. |
| ML fundamentals | Reported topics include LayerNorm vs. BatchNorm in LLMs, attention implementation details, multimodal LLM architectures, diffusion details, RL for LLMs. |
| Possibly a research talk | Some research roles include a presentation of your work (unverified for this specific role; ask the recruiter). |
| Hiring-manager / final round | Research vision, fit with team direction, collaboration. |

Timeline reports range from 1–2 weeks to about a month.

---

## 5. Prep advice (prioritized)

1. **Read the three Self-Developing Agents papers (HarnessDev, Aspire, S³Gym)** in full. For each, be able to state: the question, the setup, the main finding, one limitation, and one follow-up experiment you would run. Do the same for **UI-TARS-2**, **DAPO**, and **trae-agent**.
2. **Prepare a 5-minute "harness × RSI" framing** (use [00-big-picture](../notes/00-big-picture.md)): definitions (self-refinement vs. persistent vs. recursive), the loop anatomy, the evaluator problem, and a safety design. Then a 2-minute version.
3. **Prepare your own research deep dive** as a fixed structure: problem → why it matters → key idea → setup → main result → ablations → what failed → what you'd do next. Expect "why this design and not X?" for every choice.
4. **Be ready to derive or implement RL-for-LLM basics**: PPO clipped objective, GRPO group-relative advantage, why all-correct/all-wrong groups give zero advantage (DAPO dynamic sampling), what Clip-Higher changes, token-level vs. sequence-level loss averaging, KL penalty role. Practice writing them in ~30 lines of PyTorch.
5. **Coding practice:** daily LeetCode mediums (graphs, DP, heaps, two pointers), plus ML implementations (multi-head attention, KV cache, top-p sampling, beam search).
6. **Have 2–3 research proposals** that build on ByteDance work, e.g.:
   - *Tamper-evident HarnessDev*: measure how often evolving agents try to modify or read the evaluator under different permission designs, and test trusted-monitor protocols (AI control) for catching it.
   - *Transfer-aware harness evolution*: accept harness edits only if they improve on two model families and a held-out domain; study whether this fixes HarnessDev's partial transfer.
   - *Learned verifiers for vague goals*: in Aspire, train the agent's self-built validation set to predict hidden-test gains; measure Goodhart gaps over iterations.
7. **Show safety maturity without lecturing.** Frame safety as what makes self-improvement *work* (trustworthy gains, transfer), not only as risk. ByteDance has no public frontier-safety framework that I could find; don't criticize it, just show you design for reliability.
8. **Questions to ask them:** How does the team evaluate self-evolved harnesses before shipping to TRAE? Is Horizon RL working on agentic multi-turn RL in verl? How do HarnessDev findings feed into Seed2.x agent training? Which part of the loop do they think is the bottleneck: evaluator, environment, or optimizer?

---

## 6. Paper cards for this note

- [HarnessDev](../notes/papers/harnessdev.md)
- [Self-Developing Agents: Aspire & S³Gym](../notes/papers/aspire-s3gym.md)
- [UI-TARS-2](../notes/papers/ui-tars-2.md)
- [Trae Agent](../notes/papers/trae-agent.md)
- [HybridFlow / verl](../notes/papers/verl-hybridflow.md)
- [DAPO](../notes/papers/dapo.md)
- [ReTool](../notes/papers/retool.md)
- [MemAgent](../notes/papers/memagent.md)
- [Agent-World](../notes/papers/agent-world.md)
- Safety: [AI Control](../notes/papers/ai-control.md), [Sycophancy to Subterfuge](../notes/papers/sycophancy-to-subterfuge.md)
