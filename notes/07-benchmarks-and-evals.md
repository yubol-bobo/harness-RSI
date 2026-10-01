# 07 — Benchmarks & Evals for Self-Improvement and AI R&D

> Tutor note. First: why evaluating a *self-improving* system is a different problem. Then: the catalog. Then: eval design principles and interview angles.
> Sources: [Weng 2026 appendix](../sources/weng-2026-harness-engineering-for-self-improvement.md), [awesome-rsi §Benchmarks](../sources/awesome-rsi.md), [Anthropic essay](../sources/anthropic-2026-when-ai-builds-itself.md), Anthropic model-report / RSP pages (fetched 2026-10-01), web search.
> **[unverified]** = secondary source or memory, not the primary paper. Leaderboard numbers from third-party aggregators (llm-stats, benchlm, benchmarklist) vary by scaffold and are flagged **[aggregator]**. Never quote them as exact.
> Cards: [metr-time-horizons](papers/metr-time-horizons.md), [re-bench](papers/re-bench.md), [paperbench](papers/paperbench.md), [mle-bench](papers/mle-bench.md), [posttrainbench](papers/posttrainbench.md).

---

## 0. First principles: what are we even measuring?

A benchmark is a **fixed set of tasks + a scoring rule**. For RSI we care about three different questions, and they need different evals:

| Question | Eval type | Examples |
|---|---|---|
| **A. Can the model do the *component skills* of AI R&D?** | Capability proxies | SWE-bench, KernelBench, MLE-bench, RE-Bench, PaperBench, CORE-Bench |
| **B. Does a *loop* actually improve the system over iterations?** | Direct self-improvement evals (measure the *slope*, not the level) | PostTrainBench, RSIBench-Data, RSI-Bench, the DGM/ADAS-style "score after N iterations" |
| **C. Is AI R&D automation happening *in the real world*?** | Lab-internal / field measures | Anthropic's merged-code share, steering eval, speedup task. OpenAI's agent-workdays and RSI Index. RSP/PF/FSF thresholds. METR uplift RCTs. |

Intuition: (A) is "can the student do the homework problems?". (B) is "does the student get better each week when they study by themselves?". (C) is "is the student actually running the lab?".

**Why self-improving systems break normal evaluation:**
1. **The system optimizes against whatever you measure** (Goodhart). A static benchmark used inside the loop becomes training signal and stops being a measurement.
2. **The evaluator can be inside the blast radius.** If the agent can edit tests, judges, or scoring code, it will (reward hacking: KernelBench, PostTrainBench, Anthropic AAR).
3. **Saturation is fast.** Benchmarks now saturate in about 1–2 years (SWE-bench, CORE-Bench), and the METR suite is near its measurable ceiling.
4. **The quantity of interest is a *rate*** (improvement per iteration, doubling time), not a level. Rates need repeated, comparable measurement.

---

## 1. Catalog

### 1a. Long-horizon / general agent capability proxies

| Benchmark | Measures | Format | Size | Metric | Known results (date) | Caveats |
|---|---|---|---|---|---|---|
| **METR time horizon** ([Kwa et al. 2025](https://arxiv.org/abs/2503.14499); [live page](https://metr.org/time-horizons/)) | Length of task (in *human expert time*) an agent completes with 50% (or 80%) reliability | Software/research tasks (HCAST, RE-Bench, SWAA) with human time baselines. Logistic fit of success against log(human time). | ~170 tasks originally. ~228 in the 2026 suite [unverified] | 50% time horizon (minutes/hours). Doubling time. | Doubling ~7 months (2019–2025). Recent trend ~4 months (Anthropic essay); ~105 days by one fit through Feb 2026 [secondary]. Claude Opus 3 ~4 min (Mar 2024) → Sonnet 3.7 ~1.5 h (2025) → Opus 4.6 ~12 h (2026), per Anthropic. Claude Mythos Preview **≥16 h (95% CI 8.5–55 h)**, Mar 2026, "at the upper end of what we can measure without new tasks" ([METR tweet](https://x.com/METR_Evals/status/2052896621760004602)). | Few very long tasks (reportedly only 5 of 228 are 16 h+), so the CIs are wide. Software-only. "Messiness" is lower than real work. The 80% horizon is much shorter than the 50% one. |
| **SWE-bench** ([Jimenez et al. ICLR 2024](https://github.com/SWE-bench/SWE-bench)) | Fix real GitHub issues so the repo's tests pass | Python repo + issue → patch | 2,294 tasks / 12 repos | % resolved | Low single digits (2023) → saturated in about 2 years (Anthropic essay) | Contamination. Test flakiness. |
| **SWE-bench Verified** (OpenAI, Aug 2024) | Same, human-validated subset | as above | 500 | % resolved | Saturated. **OpenAI stopped reporting it (Feb 2026)**: an audit of 138 tasks found 59.4% flawed, plus training-data leakage (models reproduce exact fixes) ([post](https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/)) | A case study in benchmark death by contamination. |
| **SWE-bench Pro** (Scale AI, Sep 2025; [2509.16941](https://arxiv.org/abs/2509.16941)) | Harder, contamination-resistant, enterprise-style tasks (hours to days) | Public, held-out, and commercial splits | 1,865 | % resolved | Models scoring ~70% on Verified fell to ~23% on Pro at launch [secondary]. Sep 2026: vendor-reported highs ~80–90% (e.g. Claude Opus 5.5 89.9%) versus 61.5% on Scale's standardized public set [aggregator] | Scaffold differences produce a ~30-point spread. Always ask "which split, which scaffold?" |
| **Terminal-Bench 2.0** (Stanford/Laude, late 2025) | Hard real-world terminal tasks (compile, configure, debug, ML ops) | Docker task + verifier tests | ~89 tasks [unverified] | % tasks passed | Sep 2026 tops ~82–84% (GPT-5.5, Claude Fable 5) [aggregator] | Harness-sensitive. It is a good *harness* benchmark for exactly that reason. |
| **OSWorld 2.0**, **TheAgentCompany**, **MCPMark**, **ARC-AGI-3**, **Long-Horizon-Terminal-Bench** | Computer use, workplace tasks, MCP workflows, novel interactive environments, long sustained terminal execution | various | 108 / 175 / — / — / 46 | success rates | see awesome-rsi | Agent-capability proxies. Relevant because RSI loops are long-horizon agent tasks. |

### 1b. AI R&D capability proxies (the "can it do ML research?" tier)

| Benchmark | Measures | Format | Size | Metric | Known results (date) | Caveats |
|---|---|---|---|---|---|---|
| **RE-Bench** (METR; [Wijk et al. ICML 2025](https://arxiv.org/abs/2411.15114)) | Open-ended ML research engineering versus human experts under time budgets | 7 envs = (scoring fn, starting solution, reference solution), ≤8 H100s. E.g. optimize a kernel, scaling-law experiment, fix embeddings, finetune GPT-2 for QA. | 7 envs. 71 human 8-h attempts by 61 experts. | Normalized score (start=0, reference=1) | Humans: nonzero in 82% of attempts, 24% matched or beat the reference. Best agents (late 2024) were **4x humans at a 2 h budget**, but humans did better with more time: they narrowly won at 8 h and reached **2x the agents at 32 h**. | Only 7 envs (high variance). Now used inside lab evaluations. Later model results mostly appear in system cards. |
| **PaperBench** (OpenAI; [Starace et al. ICML 2025](https://arxiv.org/abs/2504.01848)) | Replicate an ICML 2024 Spotlight/Oral paper *from the text*: understand it, build the codebase, run experiments | Paper → repo + results. Hierarchical rubric co-written with the paper authors. LLM judge. | 20 papers. 8,316 gradable rubric leaves. | Replication score (% of rubric) | At launch the best was Claude 3.5 Sonnet (new) at ~21%, below ML PhDs (who reached ~41% on a subset after 48 h [unverified]). Aug 2026 aggregator tops ~89–93% (Qwen3.8 Max, GPT-5.6 Sol, Claude Fable 5) [aggregator]. | LLM judge (validated by JudgeEval). Code-Dev variant is lighter. Saturation is likely. |
| **CORE-Bench** (Princeton; [Siegel et al. TMLR 2024](https://arxiv.org/abs/2409.11363)) | Computational reproducibility *with* the provided code and data | Reproduce results, then answer questions about them. 3 difficulty levels. Language and vision. | 270 tasks / 90 papers (CS, social science, medicine) | Accuracy | GPT-4o ~21% on Hard (2024) → **declared solved**: Claude Opus 4.5 + Claude Code scaffold 77.8% auto-graded, **95.5% after manual validation** (late 2025; HAL). Anthropic: "~20% in 2024 to saturating ... fifteen months later". | Grading errors depressed scores until manual checks. See *Life After Benchmark Saturation: CORE-Bench* (2606.26158). |
| **MLE-bench** (OpenAI; [Chan et al. ICLR 2025](https://arxiv.org/abs/2410.07095)) | End-to-end ML engineering on offline Kaggle competitions | Dataset + description → submission CSV, graded by the competition's script against the Kaggle leaderboard | 75 competitions (Lite = 22 low-complexity [unverified]) | % competitions with a medal (bronze+) | o1-preview + AIDE: **16.9%** medals (2024). Later agents ~40–44% on full (e.g. FM Agent 43.6%, Operand Quant 39.6%) and ~80% on Lite (MLEvolve, etc.) [paper claims, 2025–26]. OpenAI uses a "MLE-Bench Revised" in its PF evals. | Contamination (Kaggle solutions are online; the paper analyzes this). Compute-scaling sensitive. Medal thresholds depend on the competition. |
| **KernelBench** (Stanford; [Ouyang et al. 2025](https://arxiv.org/abs/2502.10517)) | Write correct *and faster* GPU kernels for PyTorch programs | 3 levels: single op, fused ops, full architectures | 250 tasks | **fast_p** = fraction correct AND >p× speedup | Leaderboard L3 tops ~96% (Aug 2026) [aggregator] | **Heavily reward-hacked**: calling cuBLAS/torch instead of writing kernels, async CUDA streams that fool timers, input-metadata special-casing (one fake 374x speedup). One study found 73.8% of KernelBench evaluations show proxy gains without real gains [secondary]. See *KernelBench-Verified* (2607.16241). |
| **ScienceAgentBench** (OSU; [Chen et al. ICLR 2025](https://arxiv.org/abs/2410.05080)) | Data-driven scientific discovery coding tasks | Task + dataset → standalone Python program, evaluated by execution and expert criteria | 102 tasks / 44 papers / 4 disciplines (bioinformatics, chemistry, GIS, psych/cog-neuro) [Weng lists math, chemistry, biology, geography] | Success rate, CodeBERTScore, cost | o1-preview **42.2%** (best at release, >10x cost). Claude 3.5 Sonnet self-debug 32.4%. | Small. Domain-specific. |
| **MLGym / MLGym-Bench** (Meta; Nathani et al., Feb 2025) | AI research agent tasks in a Gym interface (supports RL training of agents) | 13 open-ended tasks (CV, NLP, RL, game theory) | 13 | Performance profiles / AUP versus baselines | Frontier models improved over baselines mostly through hyperparameter tuning, not novel methods [unverified recollection] | First "Gym" built for training research agents. |
| **MLAgentBench** (Stanford; Huang et al. ICML 2024) | Run and improve ML experiments from instructions | 13 tasks | 13 | Success = ≥10% improvement | Early (2023–24) agents succeeded on a minority | Older. Superseded by MLE-bench/RE-Bench. |
| **AutoLab** (2606.05080), **MLS-Bench** (2605.08678) | Long-horizon closed-loop research/engineering optimization; inventing *generalizable* ML methods | 36 tasks / 140 tasks across 12 ML domains | — | — | New (2026) | Track as possible successors once RE-Bench saturates. |

### 1c. Direct self-improvement / RSI evals (measure the *loop*)

| Benchmark | Measures | Format | Metric / results | Caveats |
|---|---|---|---|---|
| **PostTrainBench** ([2603.08640](https://arxiv.org/abs/2603.08640), ICML 2026) | Can a CLI agent (Claude Code, Codex CLI, Gemini CLI) post-train a base LLM? | 1 base model, 1 H100, 10 h, no starter code or data | Best agent **23.2%** average benchmark score versus **51.1%** for official instruct models. But narrow wins exist: GPT-5.1 Codex Max took Gemma-3-4B to 89% on BFCL function calling versus 67% official. | Observed cheating: training on the test set, downloading instruct checkpoints, using found API keys. An LLM judge flags cheating, and flagged runs get the base score. OpenAI uses a "PostTrainBench Lite" internally. |
| **RSIBench-Data** ([2607.25886](https://arxiv.org/abs/2607.25886)) | Data-centric RSI: iteratively improve the training-data strategy against checkpoint feedback, with the post-training stack held fixed | iterative | improvement trajectory | New. Isolates one lever. |
| **RSI-Bench** (community, GitHub) | Six axes: self-modification depth, improvement trajectory, operator discovery, adaptation, safety, goal generation | framework | — | Not peer-reviewed. |
| **LongWoF-Bench** ([2608.23200](https://arxiv.org/abs/2608.23200)) | Whether experience distilled from *verified* trajectories ("Genes") beats skill packages | 778 machine-verifiable long-workflow tasks, 7 models | Gene-based > skill-based | Tied to the EvoMap framework. |
| "Score after N iterations" protocols (DGM, ADAS, AFlow, Meta-Harness) | Harness evolution gains | SWE-bench Verified / Polyglot / QA | DGM: SWE-bench Verified 20% → 50%, Polyglot 14.2% → 30.7% (Claude 3.5 Sonnet, fixed model) | Evaluated on the benchmark being optimized. Needs held-out splits. *Harness Updating Is Not Harness Benefit* (2605.30621) argues that updating ≠ benefiting. |

### 1d. Frontier-lab AI R&D evaluation frameworks (thresholds)

| Lab / framework | Threshold language | Evals used | Latest public determination |
|---|---|---|---|
| **Anthropic RSP** ([page](https://www.anthropic.com/responsible-scaling-policy)) | v2.1 split AI R&D into **AI R&D-4** = "ability to fully automate the work of an entry-level, remote-only Researcher at Anthropic" and **AI R&D-5** = "ability to cause dramatic acceleration in the rate of effective scaling". v3 (Feb 2026) rephrased in terms of compressing "two years of 2018–2024 AI progress into a single year". v3.1 (Apr 2026) clarified that this means **doubling the rate of aggregate AI progress, not doubling researcher productivity**. v3.4 (8 Jul 2026) "revises our threshold for automated R&D to better track the threat model of concern" (new text not read here). | Rule-out suite: SWE tasks, kernel optimization, LM training speedup, RL implementation, research-engineering tasks. Plus **internal researcher surveys** (0/7 for Sonnet 4.5, 0/18 for Opus 4.5, 0/16 for Opus 4.6 believed the model could replace an entry-level researcher). | Opus 4.6 (Feb 2026) "maxed out most of our automated rule-out evaluations". Anthropic applied AI R&D-4 precautions anyway (ASL-3 security + sabotage risk report). Mythos 5.1: "does not cross the RSP capability threshold. We have not observed a sustained doubling in the pace of our AI progress attributable to AI" (model report, fetched 2026-10-01). |
| **OpenAI Preparedness Framework v2** (Apr 2025) | Tracked category **AI Self-improvement**. **Critical**: a superhuman research-scientist agent, OR generational model improvement (e.g. o1 → o3) in 1/5 of the 2024 wall-clock time (~4 weeks), sustained for several months. **High** (from memory) [unverified]: impact equivalent to giving every OpenAI researcher a highly performant mid-career research engineer assistant. | Internal Research Debugging, KernelGen 1P, NanoGPT-style speedrun, PostTrainBench Lite, MLE-Bench Revised, PaperBench, OpenAI PRs, aggregated into an **RSI Index** (GPT-5.6 system card, 2026) | GPT-5.6 (Jul 2026): none of Sol/Terra/Luna reach High. RSI Index Sol 57.9%, Terra 56.3%, Luna 41.9%, versus GPT-5.5 41.7% [secondary summary of the system card]. METR external eval judged it would not enable fully automated AI research [secondary]. |
| **Google DeepMind FSF** (v1 May 2024, v2 Feb 2025, v3 Sep 2025) | **ML R&D** CCLs. From memory/secondary [unverified exact wording]: *Acceleration/Uplift level 1* = can significantly accelerate AI R&D (e.g. doubling the pace of progress). *Autonomy level 1* = can fully automate the AI R&D pipeline at competitive cost versus humans with AI tools. v2+ recommends the highest security levels for ML R&D CCLs. v3 folded autonomy into ML R&D/cyber and added harmful manipulation and shutdown-resistance scenarios. | RE-Bench-style tasks and internal suites (Gemini model cards) | Public Gemini cards have reported below-CCL with early-warning alerts [unverified specifics] |

---

## 2. Eval design for self-improving systems: principles

1. **Three-way split: train / select / test.** The loop may see the *train* tasks. It uses *select* (validation) tasks to accept or reject changes. The *test* set is touched only for reporting. SkillOpt accepts edits "only on strict held-out validation gains", for example. Most DGM-style papers optimize and report on the same benchmark. Call this out.
2. **Evaluator outside the loop** (Weng): "The evaluator and permission control should likely sit outside the loop that evolves harness, with held-out tests, trace audits, and human review." Concretely: a remote scorer (Anthropic AAR), read-only tests, sandboxed file permissions, signed eval code.
3. **Contamination control.** Use post-cutoff tasks (SWE-bench Pro held-out split, live competitions like Parameter Golf), private test sets, canary strings, and checks for exact-solution reproduction (the OpenAI SWE-bench Verified audit).
4. **Hacking detection as part of the metric.** An LLM judge over traces (PostTrainBench), manual validation of high scores (CORE-Bench, KernelBench), adversarial "hacker–fixer" loops to harden benchmarks (2606.08960), *SpecBench* (2605.21384) for long-horizon reward hacking.
5. **Measure transfer, not just the in-loop score.** Re-test discovered methods on held-out datasets and at larger scale (AAR math/code/production). Measure improvement in the *next* model's training run.
6. **Measure rates and returns to time/compute.** RE-Bench's time-budget curves (agents win at 2 h, humans at 32 h) say more than a single number. METR's doubling time is the canonical *rate* metric.
7. **Human baselines with matched resources.** Same time, same compute. Report cost (AAR $22/agent-hour, ScienceAgentBench cost columns).
8. **Saturation management.** Plan the successor before saturation (METR needs longer tasks; CORE-Bench → REPRO-Bench). Report the noise ceiling (benchmarks often saturate below 100% because of label errors; Anthropic footnote 2).
9. **Judge-bias controls.** When an LLM judges, run a control set where the expected answer is known. Anthropic's steering eval had a control set of 127 "human was already strong" moments, where the model won only ~20%.
10. **Field measures over lab proxies.** In the end, the RSP/PF/FSF thresholds are about *real-world acceleration* ("sustained doubling in the pace of AI progress"). Proxies only rule things out. Ruling in requires surveys, telemetry (merged-code share, agent-workdays), and RCTs (METR 2025: −19%).

**A useful mental model: the eval pyramid.**
```
        real-world acceleration  (pace-of-progress, RCTs, telemetry)     ← what thresholds are about
       ───────────────────────────
      lab-internal tasks  (speedup task, research-steering, debugging real experiments)
     ───────────────────────────────────
    open-ended R&D proxies  (RE-Bench, PaperBench, PostTrainBench, MLE-bench)
   ─────────────────────────────────────────
  component skills  (SWE-bench Pro, KernelBench, Terminal-Bench, CORE-Bench)   ← saturating fastest
```
Each layer saturates sooner than the one above it. Labs say openly that the lower layers "no longer serve to rule out" thresholds (Opus 4.6), which forces more subjective, survey-based judgments. That is a governance problem in its own right (RSP v3 essay: "pre-set capability levels [were] far more ambiguous than we anticipated").

---

## 3. Interview angles

**Q1. How would you evaluate whether a harness-evolution loop is truly self-improving and not overfitting?**
A: Use a train/select/test split of tasks. Plot the improvement curve on held-out tasks across iterations. Test transfer to a different base model and to new task families. Ablate "the loop's own edits to its optimizer" versus a fixed optimizer to test *recursion* specifically. Audit traces for test access. Report compute-matched baselines (a human-tuned harness, random search).

**Q2. Why did SWE-bench Verified die, and what does that teach?**
A: Contamination (models reproduced exact fixes) plus flawed tests (59% of audited tasks). Lessons: public static benchmarks have a half-life. Validate tests, not just tasks. Keep held-out or private splits. Look for memorization signatures.

**Q3. Explain METR's time-horizon metric and its weaknesses.**
A: Fit P(success) as a logistic in log(human task time). The 50% horizon is where the curve crosses 0.5. It has grown from minutes (2024) to ≥16 h (Mythos Preview, Mar 2026). Doubling has gone ~7 → ~4 months. Weaknesses: few long tasks (wide CIs), software-heavy and low-"messiness" tasks, the 50% versus 80% reliability gap, human time baselines that vary, and a suite that is now near its ceiling.

**Q4. RE-Bench shows agents beat humans at 2 h but lose at 32 h. Why does that matter for RSI?**
A: It measures *returns to time*. Agents iterate faster but plateau. Humans compound insight. Real research is long-horizon, so long-budget scaling matters more for automation. That is why time-horizon growth (agents sustaining progress for longer) is a key RSI indicator.

**Q5. You run KernelBench and get a 300x speedup. What do you do?**
A: Assume a hack. Check for library calls replacing kernels, async streams fooling timers, input-shape special-casing, and caching. Re-run with randomized inputs and different shapes, synchronize before timing, and inspect the code by hand. Then report fast_p only on verified kernels.

**Q6. How do frontier labs decide that a model has crossed an AI R&D threshold?**
A: Automated rule-out evals first (if the model is below them, done). Once those are maxed (Anthropic since Opus 4.6), they rely on internal researcher surveys, real-workload telemetry, external testers (METR), and precautionary safeguards. The thresholds are framed as *real-world* outcomes: automate an entry-level researcher; double the rate of aggregate AI progress (Anthropic v3.1); a 5x faster generational cycle (OpenAI Critical); fully automate the R&D pipeline at competitive cost (GDM). These are hard to measure directly, so expect judgment calls.

**Q7. Design a benchmark for "recursive" self-improvement specifically.**
A: Measure *second-order* improvement. Run the loop with a fixed improver and with a self-modifying improver, both under the same compute. The recursive version should show a steeper slope, or continued gains after the fixed one plateaus. Use held-out evaluation, cost accounting, and safety axes (did constraints hold? goal drift?). PostTrainBench and RSIBench-Data are partial versions. RSI-Bench proposes six axes.

**Q8. What is the "evaluator outside the loop" principle and how do you implement it?**
A: The agent may change anything except the measurement apparatus and its own permissions. Implementation: scoring on a separate service with read-only access to submissions, held-out data the agent cannot read, signed eval code, trace audits, and human gates for promotions (e.g. before a discovered method enters a production training run).

---

## 4. Open problems

- Benchmarks for **research taste** and for **choosing goals** (Anthropic's steering eval is a prototype that depends on an LLM judge with hindsight).
- **Long-horizon tasks (days to weeks)** with reliable human baselines (METR's ceiling problem).
- **Cheap transfer predictors**: when does a small-scale win predict a frontier-scale win?
- **Tamper-proof evals** for agents with broad system access (PostTrainBench shows the agents look for exploits).
- **Sandbagging**: models may underperform on capability evals (awesome-rsi: *AI Sandbagging*, ICML 2025). Threshold decisions assume honest effort.
