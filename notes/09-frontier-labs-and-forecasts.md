# 09 — Frontier Labs & Forecasts: Who Says What About RSI, and How Fast Could It Go?

> Tutor note. Part 1: what each lab says and does, with dates. Part 2: the evidence, read carefully. Part 3: takeoff models and the timelines debate, explained from scratch. Part 4: interview angles.
> Sources: [Anthropic, *When AI builds itself*](../sources/anthropic-2026-when-ai-builds-itself.md) (primary, read in full), anthropic.com RSP / model-report / roadmap / AAR pages (curl'd 2026-10-01), [Weng 2026](../sources/weng-2026-harness-engineering-for-self-improvement.md), web search for everything else.
> **[unverified]** = secondary reporting or memory. Dates matter in this note, so check them before quoting.
> Cards: [anthropic-when-ai-builds-itself](papers/anthropic-when-ai-builds-itself.md), [anthropic-automated-w2s-researcher](papers/anthropic-automated-w2s-researcher.md), [forethought-software-intelligence-explosion](papers/forethought-software-intelligence-explosion.md), [metr-time-horizons](papers/metr-time-horizons.md).

---

## 0. The 30-second version

- **Every frontier lab now names RSI / automated AI research as an explicit goal or tracked risk.** OpenAI has dated milestones (research intern by Sep 2026, *claimed met*; automated AI researcher by Mar 2028). Anthropic publishes internal acceleration data and says fully automated R&D in AI and other domains is "plausible, as soon as early 2027". DeepMind's leadership says "all the leading labs are quite focused on" it. Meta's superintelligence lab was framed around self-improving AI.
- **The evidence:** execution ("doing") is largely automated inside labs. Judgment ("choosing") is not yet, though it is improving. No lab has reported crossing its formal AI R&D threshold (as of Oct 2026).
- **The forecasting debate:** once AI R&D is automated, does progress *explode* (software intelligence explosion), or does it get *bottlenecked* (compute, experiments, human review, Amdahl's law)?

---

## 1. Anthropic

### 1.1 "When AI builds itself" (Anthropic Institute; Marina Favaro & Jack Clark; data through May 2026, updated 18 Sep 2026)

Data to know cold (all from the source file):

| Claim | Number | Caveat stated in the essay |
|---|---|---|
| Share of merged code authored by Claude | **>80%** (May 2026). Low single digits before Claude Code's Feb 2025 research preview. | Leadership publicly estimated 90%+ including scripts. 80% is the conservative attributed-lines measure, and the attribution pipeline has gaps. |
| Code per engineer | **8x** lines merged per engineer per day in Q2 2026 versus 2024. Flat 2021–2024, with inflections in 2025 (Claude runs code) and 2026 (long-horizon autonomy). | "Almost certainly an overstatement of the true productivity gain". LoC measures quantity, not quality. |
| Self-reported uplift | Median **~4x** output with Mythos Preview (Mar 2026 poll, n=130 research staff) | "True degree of uplift ... somewhat lower". Cites METR's finding that developers overestimate. |
| Work that wouldn't have happened | Claude shipped **800+ fixes** in Apr 2026 that cut a class of API errors **1000x**. A human was estimated at 4 years. | Anecdote. |
| Open-ended task success | **76%** success on the most open-ended tier (May 2026), **+50 pp in 6 months** | Success is judged by a Claude judge ("succeeded without requiring corrections"). Workload shifts cause fluctuations. |
| Code quality | Worse than human in late 2025, "roughly at parity today", expected "strictly better within the year" | No consensus among staff. |
| Automated review | A retrospective Claude review would have caught ~**1/3** of bugs behind past claude.ai incidents | — |
| Fixed-goal experiment (training-code speedup) | Opus 4 ~**3x** (May 2025) → Mythos Preview ~**52x** (Apr 2026). A skilled human reaches ~**4x** in 4–8 h. | The absolute multiple depends on the slack in the starting code. Compare like-for-like. |
| Open-ended research (automated W2S) | Agents recovered **97%** of the performance gap versus **23%** for 2 humans over ~1 week. ~800 cumulative hours, ~$18k. | Did not transfer cleanly to production scale. Humans chose the problem and the rubric. |
| Research steering | Model's next step judged better than the human's **51%** (Opus 4.5, Nov 2025) → **64%** (Mythos Preview, Apr 2026). n=129 moments from Jan–Mar 2026 sessions. | Moments were *selected* where the human went off course. On a control set of 127 strong-human moments, models won ~20%. |
| External | METR time horizon doubling ~**4 months** (was ~7). Opus 3 ~4 min (Mar 2024) → Sonnet 3.7 ~1.5 h → Opus 4.6 ~12 h. Mythos Preview "at least" 16 h. SWE-bench from low single digits to saturated in ~2 years. CORE-Bench ~20% (2024) to saturated ~15 months later. | 50% reliability horizon. The trend looks the same at 80% (footnote 1). |

**Three scenarios** (memorize them):
1. **Trend stalls, but today's capabilities diffuse.** The curves are S-curves. Taste may need a new architecture. The binding constraint may be supply chain (energy, chips) or an exogenous shock. Even frozen capabilities change the world (Project Glasswing: Mythos Preview found >10,000 high/critical vulnerabilities in its first weeks). *Anthropic considers this unlikely*: "We have not yet seen that curve bend."
2. **Compounding efficiency gains, humans still steer.** "We're likely heading into this scenario." 100-person orgs do the work of 10,000–100,000. Limited by **Amdahl's law**: speeding up part of a process moves the bottleneck. Anthropic already sees **human code review** as the new bottleneck, plus more ideas than capacity to pursue them.
3. **Full RSI.** AI designs and builds its successors. The pace is set by compute and by the speed of discovering efficiencies. Humans move to oversight and verification of a "virtual lab". Alignment outcome very uncertain: misalignment "could compound as the models build their successors". The world-facing impact is still gated by Amdahl bottlenecks (clinical trials, elections, relationships).

**Policy stance:** it would be good to have the *option* to slow or pause. Anthropic "would slow down or temporarily pause, if other developers at or near the frontier also did so in a verifiable manner." Verification is harder than for arms control: training runs are easier to hide than missile silos.

**"What if we're wrong?"** The objection: humans keep the part that matters (choosing problems). The reply: most progress is incremental ("99% perspiration"), and perspiration is being automated. Even with zero taste, the conservative reading still implies compounding acceleration.

### 1.2 Formal commitments: the RSP AI R&D thresholds ([RSP page](https://www.anthropic.com/responsible-scaling-policy), fetched 2026-10-01)

| Date | Change |
|---|---|
| Oct 2024 (v2.0) / v2.1 | AI R&D split into **AI R&D-4**, "fully automate the work of an entry-level, remote-only Researcher at Anthropic", and **AI R&D-5**, "cause dramatic acceleration in the rate of effective scaling". |
| 10 Feb 2026 | Opus 4.6 judged *not* to cross AI R&D-4, but "confidently ruling out this threshold is becoming increasingly difficult". It "maxed out most of our automated rule-out evaluations". 0/16 surveyed researchers thought it could replace an entry-level researcher within 3 months. Anthropic published a **Sabotage Risk Report** as a precaution. |
| 24 Feb 2026 (v3.0) | Full rewrite: Frontier Safety Roadmaps + Risk Reports. Rationale: pre-set thresholds were "far more ambiguous than we anticipated", and capability thresholds did not create the hoped-for industry consensus. |
| 2 Apr 2026 (v3.1) | Clarifies the AI R&D threshold: "compress two years of 2018–2024 AI progress into a single year" means **doubling the rate of aggregate AI progress**, *not* doubling researcher productivity. |
| 8 Jul 2026 (v3.4) | "Revises our threshold for automated R&D to better track the threat model of concern" (new wording not read here). |
| 14 Aug 2026 | Risk Report covering through 15 Jul 2026. |
| Roadmap ([page](https://www.anthropic.com/responsible-scaling-policy/roadmap)) | "We believe it is plausible, **as soon as early 2027**, that our AI systems could fully automate, or otherwise dramatically accelerate, the work of large, top-tier teams of human researchers in domains where fast progress could cause threats to international security ... for example, energy, robotics, weapons development and AI itself." |
| Latest model report (Mythos 5.1 / Fable 5.1) | "Does not cross the RSP capability threshold. **We have not observed a sustained doubling in the pace of our AI progress attributable to AI**, and the model is not close to substituting for our research scientists and engineers; external testing by METR produced findings consistent with this assessment." |

**Interview point.** Note the tension. The essay shows 8x code, 4x self-reported uplift, and 52x on speedup tasks. The formal determination is still "no sustained doubling of aggregate AI progress". Both can be true: per-person output ≠ the pace of frontier progress. Compute, experiments, and review bottlenecks (Amdahl) sit between them. The v3.1 clarification exists for exactly this reason.

### 1.3 Automated research demos
- **Automated Alignment Researchers (14 Apr 2026)**: see note 06 and the [card](papers/anthropic-automated-w2s-researcher.md).

---

## 2. OpenAI

| Date | Event |
|---|---|
| Apr 2025 | **Preparedness Framework v2** makes **AI Self-improvement** a Tracked Category. *Critical*: a superhuman research-scientist agent, OR a generational improvement (o1 → o3 scale) in 1/5 of the 2024 wall-clock time (~4 weeks) sustained for several months. Critical requires safeguards *during development* and halting further development until they are specified. *High* (from memory) [unverified]: equivalent to giving every OpenAI researcher a highly performant mid-career research-engineer assistant. Critics (LessWrong, "OpenAI's red line for AI self-improvement is fundamentally flawed") argue the lagging indicator fires too late. |
| Nov 2025 | Bubeck et al., *Early science acceleration experiments with GPT-5* (case studies. "p-hacking and eureka-ing". The Erdős-problems overclaim controversy was mostly literature retrieval). |
| 28 Oct 2025 | Livestream (Altman, with chief scientist Jakub Pachocki [unverified that he co-presented]): internal goals of an **automated AI research intern by Sep 2026** and a **"legitimate AI researcher" by Mar 2028**. |
| Feb 2026 | "Why we no longer evaluate SWE-bench Verified" (contamination + flawed tests) → recommends SWE-bench Pro. |
| Jul 2026 | GPT-5.6 system card: AI Self-Improvement evals (Internal Research Debugging, KernelGen 1P, NanoGPT, PostTrainBench Lite, MLE-Bench Revised …) aggregated into an **RSI Index**. Sol 57.9 / Terra 56.3 / Luna 41.9 versus GPT-5.5 41.7 [secondary]. **Below High.** |
| 27–28 Jul 2026 | **Lilian Weng** leaves Thinking Machines Lab (which she co-founded with Mira Murati), citing health and workload. OpenAI confirms the next day that she **returns to OpenAI to lead a team on recursive self-improvement research** ([Dataconomy](https://dataconomy.com/2026/07/30/lilian-weng-rejoins-openai-lead-ai-research-team/), [TNW](https://thenextweb.com/news/lilian-weng-thinking-machines-openai-recursive-self-improvement)). Her *Harness Engineering for Self-Improvement* post (4 Jul 2026) appeared weeks earlier, so read it as her research agenda. |
| 6 Sep 2026 | "**Research acceleration: The view inside OpenAI**": OpenAI says it **met the research-intern goal**, a system that does well-defined multi-day research tasks under human direction. Key metric: **3.1 agent-workdays per human workday** across the research org (mid-Aug 2026). It was computed by converting coding-agent runtime into 8-hour days. Task success rates improved Jan–Jul across difficulty levels. Next: "strong progress" toward the **Mar 2028 automated AI researcher** ([TechRadar](https://techradar.com/pro/openai-says-it-has-built-an-automated-research-intern-to-carry-out-menial-tasks-and-its-only-just-getting-started), [Help Net Security](https://www.helpnetsecurity.com/2026/09/07/openai-research-automation-intern/)). |

**Critique of "3.1 agent-workdays".** It measures *agent runtime*, not output value. Parallel agents idling or retrying still count. Compare it with Anthropic's own LoC caveat. A good interview line: "it is an input metric dressed as an output metric."

---

## 3. Google DeepMind / Google

- **AlphaEvolve** (May 2025): already a small closed loop on Google's own AI stack. Speedup of 23% on a Gemini matmul kernel, which cut Gemini training time by **1%**. FlashAttention kernel up to **32.5%** faster. A Borg scheduling heuristic in production recovers **0.7%** of fleet compute ([blog](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/)). These are small numbers, but they are *real* AI-improves-AI-infrastructure results.
- **AI co-scientist** (preprint Feb 2025; *Nature* 19 May 2026): hypothesis generation in biomedicine. Humans did the wet lab.
- **ScientistOne** (Google Cloud AI Research, May 2026): Chain-of-Evidence verifiable research.
- **Frontier Safety Framework**: ML R&D CCLs (acceleration/uplift and autonomy levels). v2 (Feb 2025) recommends the highest security for ML R&D CCLs. v3 (22 Sep 2025) adds harmful manipulation and covers shutdown/control-resistance scenarios.
- **Statements:** Demis Hassabis to Axios (Jan 2026): Google is exploring whether models can "continue to learn out in the wild after you finish training them"; "all the leading labs are quite focused on" RSI; "there'll be clear gains in terms of speed of your research" ([Axios](https://www.axios.com/2026/01/27/models-improve-ai)). Reports say Sergey Brin pushed DeepMind to prioritize RSI [unverified, secondary].

## 4. Meta

- **Meta Superintelligence Labs (MSL)**, formed Jun 2025. Zuckerberg (Q2 2025 earnings and a 30 Jul 2025 letter): "Over the last few months we have begun to see **glimpses of our AI systems improving themselves**. The improvement is slow for now, but undeniable." He framed self-improvement as the path to superintelligence, and signaled Meta may not open-source its most powerful systems.
- Research: **Autodata** (FAIR, Jun 2026), **MLGym** (Feb 2025), **HyperAgents** (2026), self-rewarding LMs (2024).

## 5. Others worth a sentence

- **Sakana AI**: AI Scientist (v1 2024, v2 2025, *Nature* Mar 2026), Darwin Gödel Machine, ShinkaEvolve.
- **Thinking Machines Lab** (Murati): Weng was a co-founder until Jul 2026.
- **Tencent Hunyuan Hyra**, **recursive.com**, **xyz-lab AI4AI**, Karpathy **autoresearch** (Mar 2026): industry and open-source auto-research loops (awesome-rsi blog section).
- **METR**: the independent evaluator in this space (time horizons, RE-Bench, uplift RCT, external system-card evals).
- **ByteDance Seed**: see `interview/bytedance-seed-context.md` (another note).

---

## 6. Takeoff models, from first principles

### 6.1 The basic loop
Let **S** = the level of AI "software" (algorithms, data, training recipes, harnesses). Progress comes from research effort **R**:

dS/dt ∝ R^λ · S^(1−β)

- λ ≤ 1: duplicating researchers gives less than proportional gains (parallelization penalty, "stepping on toes").
- β > 0: ideas get harder to find. Each doubling of S takes more effort.

**Today:** R = humans (+ AI tools). R grows slowly (hiring), so progress is steady or exponential, fed by compute and money.
**After AI R&D is automated (ASARA):** R ∝ number and speed of AI researchers, which ∝ (compute) × (efficiency S). Holding compute fixed, R ∝ S. Substitute:

dS/dt ∝ S^(λ + 1 − β)  →  the exponent exceeds 1 iff **r ≡ λ/β > 1**

- **r > 1**: each doubling of software produces *more* than one doubling of research input. The doubling times *shrink*, giving hyperbolic growth: a **software intelligence explosion (SIE)**, which needs no new chips.
- **r < 1**: the feedback fizzles. Growth slows unless compute grows.

### 6.2 Forethought (Tom Davidson & co.)
- **Eth & Davidson, "Will AI R&D Automation Cause a Software Intelligence Explosion?" (26 Mar 2025)** ([link](https://forethought.org/research/will-ai-r-and-d-automation-cause-a-software-intelligence-explosion)). Defines **ASARA** (AI Systems for AI R&D Automation). Uses empirical estimates of returns to software R&D (e.g. how fast algorithmic efficiency grew versus growth in research inputs, using Epoch data on LLMs and computer vision). Concludes r is *more likely than not* > 1 at the point of automation, so an SIE is plausible [exact point estimate unverified; recall ~r≈1.2 with wide uncertainty]. They discuss compute bottlenecks as the main objection.
- **Davidson & Houlden, "How quick and big would a software intelligence explosion be?" (2025)**: ~**60%** chance the SIE compresses >3 years of progress into <1 year, ~**20%** that it compresses >10 years into <1 year. Initial speed-up 2–32x (median 8x) versus 2020–24. 6–16 OOMs of headroom before effective limits. Illustration: from 30,000 top-expert AIs at 30x speed to 30 million superintelligent researchers at 120x. The authors put "not much faith in the specific numbers."

### 6.3 Counterarguments: the bottlenecks
1. **Compute for experiments.** Research needs experiments, and experiments need compute, which does not grow with S. Model research output as CES(cognitive labor L, compute K). If L and K are **complements** (elasticity σ < 1), infinite AI labor still saturates at a compute-limited ceiling. **Whitfill & Wu (2025), "Will Compute Bottlenecks Prevent an Intelligence Explosion?"** ([2507.23181](https://arxiv.org/abs/2507.23181)) estimated σ on a 2014–2024 panel of OpenAI, DeepMind, Anthropic, and DeepSeek. The baseline spec gives **substitutes** (no hard bottleneck). The "frontier experiments" spec gives **complements** (a bottleneck). The answer is genuinely unresolved.
2. **Epoch AI skeptics** (Erdil, Besiroglu, and others): much algorithmic progress is *compute-dependent* (found by scaling experiments), and parallelization limits plus hardware limits slow any explosion [summary, unverified specifics].
3. **Amdahl's law** (Anthropic's own frame): if a fraction *p* of the R&D process is automated and sped up by *s*, the overall speedup is 1 / ((1−p) + p/s). With p = 0.9 and s → ∞, the cap is 10x. The *un-automated* remainder (taste, review, compute waits, coordination) dominates. Anthropic already reports human code review as the binding constraint.
4. **Diminishing returns / S-curves** (Anthropic scenario 1). Taste might not come from scaling.
5. **Measurement skepticism.** METR's 2025 RCT: −19% for experienced developers who believed they were +20%. Self-reports overstate.
6. **Physical-world gating.** Even with RSI in software, deployment and benefits are rate-limited by institutions (Anthropic: drugs, elections, friendships).

### 6.4 Scenario forecasts and timelines

| Source | Claim | Date |
|---|---|---|
| I. J. Good | "Ultraintelligent machine ... intelligence explosion" | 1965 |
| **AI 2027** (Kokotajlo, Alexander, Larsen, Lifland, Dean; AI Futures Project) | Scenario: a superhuman coder (~early 2027), then a superhuman AI researcher, then superintelligence by ~end 2027, driven by AI R&D speed multipliers inside a leading lab ("OpenBrain"). Two endings (race / slowdown). | Apr 2025 |
| AI Futures Model, Dec 2025 update | ~3 years *longer* to full coding automation than before (less bullish on pre-automation speedups): early 2030s | 31 Dec 2025 |
| AI Futures, 2026 updates | Snapped back shorter. Kokotajlo's Automated Coder median ~**Nov 2027** (vs May 2028 previously) [secondary] | Q1–Q3 2026 |
| FutureSearch | Superhuman coder median ~2033 | 2025–26 |
| Anthropic roadmap | Full automation or dramatic acceleration of top-tier research teams "plausible as soon as early 2027" | 2026 |
| OpenAI | Intern Sep 2026 (claimed met). Automated AI researcher Mar 2028. | Oct 2025 / Sep 2026 |
| METR trend extrapolation (Anthropic essay) | Multi-day tasks "this year" (2026). Week-long tasks in 2027. | 2026 |

**How to talk about timelines in an interview.** Don't pick a date. Name the cruxes:
(1) Does time-horizon doubling continue past the "days" scale?
(2) Is research taste learnable, and does the steering-eval trend continue?
(3) Is r > 1, and are compute and cognitive labor substitutes?
(4) How fast can verification and oversight scale? This is the Amdahl term, and the safety term.

---

## 7. Interview angles

**Q1. Summarize Anthropic's evidence that AI is accelerating AI development, and the strongest critique.**
A: >80% of merged code by Claude. 8x code per engineer. 76% success on open-ended tasks (+50 pp in 6 months). Speedup task 3x → 52x versus human 4x. AAR 97% versus 23% PGR. Steering 51 → 64%. Critiques: LoC and self-reports overstate. The success and steering numbers use Claude judges. The steering set is selected. AAR didn't transfer to production. And Anthropic's own formal determination still says "no sustained doubling in the pace of AI progress". Per-person output is not frontier pace.

**Q2. What is Amdahl's law and why does Anthropic invoke it?**
A: Overall speedup = 1/((1−p) + p/s). Automating 90% of the work infinitely fast gives at most 10x. Bottlenecks move to what isn't automated. At Anthropic, that is human code review and the capacity to pursue ideas. Implication for harness research: *automated verification and review* is the highest-leverage target.

**Q3. Compare how Anthropic, OpenAI, and GDM define the dangerous AI R&D threshold.**
A: Anthropic: automate an entry-level researcher (R&D-4) and dramatically accelerate effective scaling (R&D-5), reframed in v3.x as doubling the *rate of aggregate AI progress*. OpenAI: AI Self-improvement; Critical = superhuman research-scientist agent or 5x faster generational improvement, sustained. GDM: ML R&D acceleration and autonomy CCLs (automate the R&D pipeline at competitive cost). All three combine a *leading indicator* (agent capability) with a *lagging indicator* (observed acceleration). All three are struggling because the automated proxy evals are saturated.

**Q4. OpenAI says it hit "automated research intern". Convince me or push back.**
A: Supporting it: multi-day well-defined tasks under direction, 3.1 agent-days per human day, rising success rates. Pushback: agent runtime is an input metric. "Intern" is defined by OpenAI. Quality, transfer, and the human review burden are not reported (in what I could read). The same company's system card puts GPT-5.6 below High on self-improvement. A consistent reading: the doing is automated, the steering is not.

**Q5. Explain the software intelligence explosion argument and the best counterargument.**
A: After ASARA, research labor scales with software efficiency. If returns r = λ/β > 1, doubling times shrink (Forethought: ~60% chance of >3 years of progress in <1 year). Best counter: experiments need compute. If compute and labor are complements (one of Whitfill & Wu's specifications), progress hits a compute ceiling. Add Amdahl (taste, review) and the S-curve risk.

**Q6. Why did Lilian Weng's move matter, and what is her research agenda?**
A: In late Jul 2026 she returned to OpenAI to lead RSI research, right after publishing "Harness Engineering for Self-Improvement". The agenda in that post: harnesses as the near-term path to RSI; context, workflow, and harness-code optimization; evolutionary search; joint harness + weight updates. Her open problems: weak and fuzzy evaluators, memory lifecycle, negative results, diversity collapse, reward hacking (evaluator outside the loop), long-term success (maintainability), and "humans move up the stack". Expect interviewers to have read it.

**Q7. What would change your mind that RSI is near / far?**
A: Near: time horizons sustained past a week. Steering evals well above human on *unselected* moments. AI-discovered methods transferring to production training runs. Labs reporting a measured doubling of frontier pace. Far: time-horizon growth bending into an S-curve. Discovered methods failing to transfer. Compute-labor complementarity confirmed. The review bottleneck not shrinking.

**Q8. What should a lab do if it believes it is entering scenario 3?**
A: (From the essay and RSP practice.) Sabotage risk reports and alignment audits for models doing R&D. "Eyes on everything" monitoring of internal AI development (an Anthropic roadmap goal). Security for weights (ML R&D CCLs warrant top security). Evaluators and permissions outside the loop. Human checkpoints at promotion decisions. Support verifiable coordination for an industry-wide slowdown or pause option.
