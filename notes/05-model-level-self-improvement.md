# 05 — Model-Level (Weight-Updating) Self-Improvement

> Scope: methods in which a model **changes its own weights** using data, rewards, or opponents it largely generates itself. This is the complement to *harness-level* RSI (prompts, memory, tools, agent code) covered in Weng (2026), whose intro explicitly sets aside "model self-play, synthetic data, test-time training and ... continual learning" (citing Yuan 2024, Chen 2024, Zhao 2025, Choi 2026).
>
> Conventions: numbers marked **[v]** were cross-checked against an abstract/proceedings page via web search on 2026-10-01. Items marked **[unverified]** are from memory or secondary summaries — double-check before quoting in an interview. Paper cards live in `notes/papers/`.

---

## 0. Reading guide for a first-timer

If you only remember one picture, remember this loop:

```
            ┌──────────────────────────────────────────────┐
            │                                              │
            ▼                                              │
   (1) GENERATE  ──►  (2) FILTER / SCORE  ──►  (3) TRAIN ──┘
   model samples       something decides        update θ on
   tasks/answers       which samples are good   the kept/weighted data
```

Every method in this note is a choice of:

1. **Who generates?** (the model itself; a frozen copy; a "proposer/challenger" role)
2. **Where does the signal come from?** (ground-truth answer, code executor, unit tests, the model as judge, an opponent, majority vote, the model's own likelihood)
3. **How is θ updated?** (SFT on filtered samples, DPO on preference pairs, policy-gradient RL)
4. **What is repeated?** (one shot vs. iterated rounds; does the data *accumulate* or get *replaced*?)

The central scientific question for RSI: **can this loop produce capability that was not already latent in the starting model, and can it keep doing so?** Most of the theory section (§4) is about why the honest answer is "only as far as the signal lets it."

---

## 1. A unifying framework

### 1.1 Formal template

Let $\pi_\theta(y\mid x)$ be the model, $\mathcal{D}_x$ a prompt distribution (possibly model-generated), and $s(x,y)\in\mathbb{R}$ a **signal**. One round:

$$
\underbrace{y_{1:N}\sim \pi_{\theta_t}(\cdot\mid x)}_{\text{generate}}
\;\;\longrightarrow\;\;
\underbrace{w_i = \phi\big(s(x,y_i)\big)}_{\text{filter / weight}}
\;\;\longrightarrow\;\;
\underbrace{\theta_{t+1}=\arg\max_\theta \textstyle\sum_{x,i} w_i \log \pi_\theta(y_i\mid x)\;\;\text{or an RL/DPO step}}_{\text{train}}
$$

- $\phi(s)=\mathbb{1}[s=1]$ → **rejection-sampling fine-tuning** (STaR, ReST-EM, RFT).
- $\phi$ produces (best, worst) pairs → **preference optimization** (Self-Rewarding, Meta-Rewarding, SPIN).
- $w_i=$ normalized advantage → **on-policy RL** (GRPO in R1-Zero, TTRL, Absolute Zero, R-Zero).

A key identity to know: filtered SFT is a (biased, off-policy) form of policy gradient. For binary reward $r$,

$$
\nabla_\theta\, \mathbb{E}_{y\sim\pi_\theta}[r(x,y)] = \mathbb{E}_{y\sim\pi_\theta}\big[r(x,y)\,\nabla_\theta\log\pi_\theta(y\mid x)\big],
$$

and SFT on samples with $r=1$ estimates exactly this gradient (up to normalization) if the samples are fresh from $\pi_\theta$. STaR's paper makes this observation explicitly.

### 1.2 Where the signal comes from (the most important axis)

| Signal source | Examples | Strength | Weakness |
|---|---|---|---|
| **Ground-truth label / checker** | STaR, ReST-EM, RLVR (R1-Zero) | Unhackable(ish); grounded | Needs labeled problems; only verifiable domains |
| **Environment / executor** | Absolute Zero (Python), Anchored Self-Play (unit tests), TTT-Discover (objective function) | Scales without humans; task generation possible | Verifier certifies *correctness*, not *relevance/realism* (drift) |
| **Self-judge (LLM-as-judge)** | Self-Rewarding, Meta-Rewarding, Constitutional AI / RLAIF | Works on open-ended tasks | Judge bias, reward hacking, self-preference, length bias |
| **Self-consistency / majority vote** | TTRL, R-Zero pseudo-labels, Huang et al. 2022 "LLMs can self-improve" | No labels at all | Confirms the model's mode — can amplify consistent errors |
| **Opponent (self-play)** | SPIN (vs. human data), Absolute Zero / R-Zero (proposer vs. solver), ASP (bug generator vs. fixer) | Automatic curriculum | Non-stationarity, collapse to degenerate games, drift |
| **The model's own likelihood** | "Sharpening" (Huang et al. 2024/25) | Cleanest theory | Can only concentrate mass already there |
| **Downstream performance after an update** | SEAL (reward = did the self-edit help after fine-tuning) | Directly optimizes "learning to learn" | Very expensive inner loop; catastrophic forgetting |

**Mental rule:** self-improvement is possible exactly when *verifying/selecting is easier than generating* for the model (the **generation–verification gap**, §4.1). Every method above is a different way to manufacture such a gap.

---

## 2. Method families

### 2.1 Self-taught reasoning: STaR, Quiet-STaR, V-STaR

**STaR (Zelikman et al., NeurIPS 2022).** Few-shot prompt the model to produce a rationale $r$ and answer $\hat y$. Keep $(x,r,\hat y)$ if $\hat y=y$. For failures, **rationalize**: give the model the correct answer as a hint, sample $r\sim p_M(\cdot\mid x, \text{hint}=y)$, and keep the rationale if it reaches $y$ — but train on it *without* the hint. Fine-tune, repeat (STaR restarts fine-tuning from the original pretrained model each outer iteration to limit overfitting **[unverified detail; consistent with paper's algorithm box as I recall]**).

Objective (STaR §3):

$$
J(M)=\sum_i \mathbb{E}_{\hat r_i,\hat y_i\sim p_M(\cdot\mid x_i)}\big[\mathbb{1}(\hat y_i=y_i)\big],\qquad
\nabla J=\sum_i \mathbb{E}\big[\mathbb{1}(\hat y_i=y_i)\,\nabla\log p_M(\hat y_i,\hat r_i\mid x_i)\big].
$$

Rationalization adds samples from $p_M(r\mid x,y)$ — this is an off-policy **proposal distribution** that lets the model learn from problems it would never solve on-policy (a cheap fix for the "zero-success problems give zero gradient" issue that resurfaces in RLVR).

Results **[v]**: CommonsenseQA 72.5% with GPT-J (6B), vs. 73.0% for a ~30× larger fine-tuned GPT-3; GSM8K 5.8% → 10.7%.

**Quiet-STaR (Zelikman et al., COLM 2024).** Generalizes STaR from QA to *arbitrary text*: at every token, generate a short internal "thought," mix the post-thought prediction with the base prediction via a learned mixing head, and REINFORCE thoughts that raise likelihood of the *actual future tokens*. The "verifier" is the next-token data itself. Results **[v]**: Mistral-7B continued-pretrained on OpenWebMath/C4 → zero-shot GSM8K 5.9% → 10.9%, CommonsenseQA 36.3% → 47.2%, without task-specific fine-tuning.

**V-STaR (Hosseini et al., COLM 2024).** STaR throws away incorrect samples. V-STaR keeps them to train a **verifier** with DPO (correct ≻ incorrect), then uses best-of-$k$ with the verifier at test time. Iterating improves both generator and verifier; **[v]** 4%–17% test-accuracy improvement over prior self-improvement / verification baselines on code and math with LLaMA-2. Lesson: *the failures are training signal for the verifier* — this is how you widen the generation–verification gap.

### 2.2 Reinforced self-training: ReST and ReST-EM

**ReST (Gulcehre et al. 2023)**: alternating *Grow* (sample a dataset from the policy) and *Improve* (filter by a reward model with increasing thresholds, fine-tune offline). Applied to machine translation.

**ReST-EM (Singh et al., "Beyond Human Data", TMLR 2024).** The EM view. Introduce a binary "optimality" variable $O$ with $p(O=1\mid x,y)\propto r(x,y)$ (binary correctness). Maximize $\log p(O=1\mid x)$ via the ELBO:

$$
\log p(O{=}1\mid x)\;\ge\;\mathbb{E}_{q(y\mid x)}\big[\log p(O{=}1\mid x,y)\big]-\mathrm{KL}\big(q(y\mid x)\,\|\,\pi_\theta(y\mid x)\big).
$$

- **E-step:** $q^{t+1}(y\mid x)\propto r(x,y)\,\pi_{\theta_t}(y\mid x)$ — in practice: sample from the current policy and keep samples with $r=1$.
- **M-step:** $\theta_{t+1}=\arg\max_\theta \mathbb{E}_{x}\mathbb{E}_{y\sim q^{t+1}}\big[r(x,y)\log\pi_\theta(y\mid x)\big]$ — reward-weighted NLL, i.e., SFT on the filtered samples. ReST-EM fine-tunes from the *base* model each iteration **[unverified detail, from memory]**.

Why EM is nice: it decouples data collection (E) from optimization (M), so it scales to very large models without on-policy RL infrastructure. Findings **[v, via summaries]**: on MATH and APPS with PaLM-2, model-generated + filtered data beats fine-tuning on human solutions; gains grow with model size; multiple iterations help MATH but overfit APPS; improves pass@1 more than pass@k.

### 2.3 Self-rewarding and judge-based loops

**Self-Rewarding LMs (Yuan et al., ICML 2024).** One model plays both *policy* and *reward model*.

Round $t$:
1. Generate new prompts $x$; sample $N$ responses $y_{1:N}\sim M_t(\cdot\mid x)$.
2. Score each with **LLM-as-a-Judge** prompting of $M_t$ itself (additive 5-point rubric, averaged over multiple judge samples).
3. Form pairs $(y_w,y_l)=$ (highest, lowest score); drop ties.
4. Train $M_{t+1}$ from $M_t$ with DPO:

$$
\mathcal{L}_{\text{DPO}}(\theta)=-\mathbb{E}_{(x,y_w,y_l)}\Big[\log\sigma\Big(\beta\log\tfrac{\pi_\theta(y_w\mid x)}{\pi_{\text{ref}}(y_w\mid x)}-\beta\log\tfrac{\pi_\theta(y_l\mid x)}{\pi_{\text{ref}}(y_l\mid x)}\Big)\Big],\quad \pi_{\text{ref}}=M_t.
$$

Seed: $M_1$ is SFT'd on instruction-following data **and** "evaluation fine-tuning" (EFT) data teaching it to judge. Result **[v]**: Llama-2-70B after three iterations outperforms Claude 2, Gemini Pro and GPT-4 0613 on the AlpacaEval 2.0 leaderboard; the judge skill also improves across iterations. Caveats: few iterations, length growth, judge evaluated by correlation with humans only on limited data.

**Meta-Rewarding (Wu et al., EMNLP 2025).** Self-Rewarding improves the actor but the judge saturates. Add a third role: **meta-judge** compares pairs of the model's own *judgments*, producing preference pairs to DPO-train the judge too (plus a length-control mechanism). **[v]** Llama-3-8B-Instruct: AlpacaEval 2 (length-controlled) 22.9% → 39.4%, Arena-Hard 20.6% → 29.1%, no human labels.

**Constitutional AI (Bai et al., Anthropic 2022) and RLAIF.** CAI's supervised stage is a *self-critique-and-revise* loop guided by a written constitution (generate → critique → revise → SFT on revisions); its RL stage replaces human harmlessness labels with **AI preference labels** (a preference model trained on model comparisons), i.e., RLAIF. **Lee et al. (ICML 2024)** **[v]**: RLAIF ≈ RLHF on summarization and helpful dialogue (difference vs. SFT not significant; head-to-head equally preferred), better on harmlessness (88% vs 76% harmless), and works even when the AI labeler is the *same size or the same checkpoint* as the policy. "Direct RLAIF" (LLM gives the reward during RL, no RM) beats canonical RLAIF. Interpretation for RSI: once judgment quality is "good enough," humans can be removed from the *labeling* loop — but the *constitution / rubric* is still a human-specified anchor.

### 2.4 Self-play fine-tuning: SPIN

**SPIN (Chen et al., ICML 2024).** Setting: you have an SFT dataset $\{(x,y)\}$ from humans/strong models and want more out of it without new labels. Two-player game:
- **Main player** (new model $p_\theta$): distinguish human responses $y\sim p_{\text{data}}$ from opponent responses $y'\sim p_{\theta_t}$.
- **Opponent** (previous iterate $p_{\theta_t}$): generate responses indistinguishable from human ones.

The discriminator is parameterized as a log-ratio, so the loss is DPO-like with human data as "chosen" and self-generated data as "rejected":

$$
\mathcal{L}_{\text{SPIN}}(\theta;\theta_t)=\mathbb{E}_{x\sim q,\;y\sim p_{\text{data}}(\cdot\mid x),\;y'\sim p_{\theta_t}(\cdot\mid x)}
\Big[\ell\Big(\lambda\log\tfrac{p_\theta(y\mid x)}{p_{\theta_t}(y\mid x)}-\lambda\log\tfrac{p_\theta(y'\mid x)}{p_{\theta_t}(y'\mid x)}\Big)\Big],
\quad \ell(t)=\log(1+e^{-t}).
$$

Theory: the global optimum of the iterated game is reached **iff** $p_{\theta}=p_{\text{data}}$ — SPIN can at best recover the SFT target distribution; it is a GAN-like way to *squeeze more out of existing human data*, not to exceed it. **[v]** zephyr-7b-sft-full: Open LLM Leaderboard average 58.14 → 63.16 (iteration 3), MT-Bench 5.94 → 6.78.

Interview point: SPIN is "self-play" only in the sense that the opponent is a past self; the *signal* is human data. It is bounded by $p_\text{data}$.

### 2.5 Synthetic instruction data: Self-Instruct, Alpaca, back-translation

**Self-Instruct (Wang et al., ACL 2023).** Start from 175 seed tasks; the model generates new instructions, classifies task type, generates inputs/outputs, filters by heuristics (e.g., ROUGE-L novelty), and fine-tunes itself. **[v]** ~52K instructions / 82K instances; vanilla GPT-3 gains 33% absolute on Super-NaturalInstructions, on par with InstructGPT-001; human eval leaves a 5% gap to InstructGPT-001. **Alpaca** (Stanford 2023) reused this recipe with a *stronger* teacher (text-davinci-003) — which makes it **distillation**, not self-improvement. Keep this distinction sharp: *who is the teacher?*

**Instruction back-translation (Li et al., ICLR 2024)** generates instructions for unlabeled human documents and self-curates — the *outputs* are human text, so the data stays anchored to the real distribution.

### 2.6 Zero-data self-play with verifiable environments: Absolute Zero, R-Zero, Anchored Self-Play

**Absolute Zero / AZR (Zhao et al., NeurIPS 2025).** A single model plays **proposer** and **solver**; a **Python executor** is the environment. Tasks are (program, input, output) triplets; three modes: *deduction* (predict output), *abduction* (predict input), *induction* (synthesize program from I/O examples). Objective:

$$
\mathcal{J}(\theta)=\max_\theta\;\mathbb{E}_{z\sim p(z)}\Big[\mathbb{E}_{(x,y^\star)\sim f_e(\cdot\mid\tau),\,\tau\sim\pi^{\text{propose}}_\theta(\cdot\mid z)}\Big[r^{\text{propose}}_e(\tau,\pi_\theta)+\lambda\,\mathbb{E}_{y\sim\pi^{\text{solve}}_\theta(\cdot\mid x)}\big[r^{\text{solve}}_e(y,y^\star)\big]\Big]\Big]
$$

with the **learnability reward** (Monte-Carlo estimate $\bar r_{\text{solve}}$ over solver rollouts):

$$
r^{\text{propose}}=\begin{cases}0 & \bar r_{\text{solve}}\in\{0,1\}\\[2pt] 1-\bar r_{\text{solve}} & \text{otherwise}\end{cases},\qquad
r^{\text{solve}}=\mathbb{1}[y=y^\star]\ \text{(checked by execution)}.
$$

Intuition: tasks that are always solved (too easy) or never solved (too hard, or broken) teach nothing — reward the frontier. Trained with **Task-Relative REINFORCE++** (separate baselines per task-type × role). **[v]** Overall SOTA among "zero-setting" models on coding+math (+1.8 avg over prior zero-setting models trained on curated data); AZR-Coder-7B gains +15.2 math points from purely code-based self-play, vs. ~+0.65 for expert code models after standard RLVR — evidence of cross-domain transfer. Noted failure: occasional concerning chains-of-thought ("uh-oh moment") with Llama-3.1-8B **[unverified wording]**.

**R-Zero (Huang et al., ICLR 2026).** Two models initialized from the same base: **Challenger** and **Solver**, trained alternately (GRPO). Challenger reward **[v]**:

$$
r_{\text{unc}}(x)=1-2\,\big|\hat p(x)-\tfrac12\big|,
$$

where $\hat p(x)$ is the fraction of Solver samples agreeing with the majority-vote pseudo-label — maximized at 50% self-consistency (the competence boundary), plus a repetition penalty. Solver trains on filtered questions with **majority-vote pseudo-labels** (no executor). **[v]** Qwen3-4B-Base: +6.49 on math, +7.54 on general reasoning benchmarks. Known issue: pseudo-label accuracy falls as questions get harder, so the loop degrades after a few iterations **[unverified quantitative detail]**.

Compare: AZR = executor-grounded labels (safe), R-Zero = self-consistency labels (no grounding → noisier). Both use a "goldilocks" difficulty reward.

**Anchored Self-Play for Code Repair (Choi, Kaya, Wu, Ma, Hashimoto, Schmidt — ICML 2026).** One model alternates as **bug generator** and **fixer**, trained with RL; unit tests certify fixes. Problem **[v]**: tests certify *correctness, not realism* — the generator drifts toward weird synthetic bugs, improving repair on self-generated bugs while *degrading* on real ones. Fix (**ASP**): anchor with a small reference set of real bugs via (i) a code-embedding similarity reward for the generator and (ii) mixing reference bugs into fixer training. **[v]** On their BugSourceBench, +7.2 pp absolute (+25% relative) average fix rate over standard self-play. This is very likely the "Choi et al. 2026" that Weng cites (OpenReview `lTbBFAoPSA`) **[unverified match]**. Lesson for RSI: **self-play needs an anchor to the target distribution** — the same lesson as model collapse (§4.3).

### 2.7 Self-adapting models: SEAL

**SEAL (Zweiger, Pari, Guo, Akyürek, Kim, Agrawal — MIT, NeurIPS 2025).** The model writes its own **self-edits**: fine-tuning data (e.g., implications/restatements of a passage) and, in the ARC setting, also augmentation + hyperparameter choices. Nested loops:

- **Inner:** $\theta' = \text{SFT}(\theta, \mathrm{SE})$ with $\mathrm{SE}\sim \pi_\theta(\cdot\mid C)$ (LoRA fine-tune on the self-edit).
- **Outer (RL):** reward $r(\mathrm{SE})=\mathbb{1}[\text{performance of } \theta' \text{ on downstream } \tau \text{ improves}]$; optimize the self-edit policy. They use **ReST-EM** (filtered behavior cloning on rewarded self-edits) as the RL algorithm because on-policy methods were unstable **[unverified detail, from memory]**.

**[v]** Knowledge incorporation (SQuAD, no-context QA after absorbing the passage): Qwen2.5-7B, 33.5% (fine-tune on raw passage) → 47.0% with SEAL, above using GPT-4.1-generated synthetic data (46.3%). On a simplified ARC subset, RL-trained self-edits beat ICL and non-RL self-edits. Limitations: catastrophic forgetting over sequential edits; each reward evaluation requires a full fine-tune + eval (very expensive). Conceptually SEAL is **"meta-learning the data generator"** — the closest model-level analog of harness self-modification.

### 2.8 Test-time training and continual learning

- **TTT (Sun et al., ICML 2020)**: update weights on a self-supervised loss on the test input itself before predicting.
- **TTT for ARC (Akyürek et al. 2024)** **[v]**: per-instance LoRA training on augmented demonstrations; up to 6× improvement over base fine-tuned model; 8B model reaches 53% on ARC public validation (61.9% when ensembled with program synthesis **[unverified]**).
- **TTRL (Zuo et al., NeurIPS 2025)**: RL on *unlabeled test questions* with reward $r(y_i)=\mathbb{1}\big[\text{ans}(y_i)=\text{maj}\{\text{ans}(y_j)\}_{j=1}^N\big]$. **[v]** Qwen2.5-Math-7B AIME 2024 pass@1 12.9% → 40.2% (~211%), ~76.5% average relative gain across AIME/AMC/MATH-500. Why it works without labels: even when the majority is wrong, the *reward* is often right for a given sample ("lucky hit" argument — a wrong-answer sample disagreeing with a wrong majority still gets reward 0, which is correct). Ceiling: bounded by maj@N of the initial model **[paper discusses; exact claim unverified]**.
- **Learning to Discover at Test Time / TTT-Discover (Yuksekgonul, …, Choi, Zou, Guestrin, Sun — 2026)** **[v]**: RL at test time on a *single* hard problem (math constructions, GPU kernels, AtCoder, single-cell denoising) with a continuous reward. Goal is *one great solution*, not average performance, so it uses an **entropic objective** that tilts toward the max reward (roughly $\tfrac1\beta\log\mathbb{E}_{y\sim\pi_\theta}[e^{\beta R(y)}]$ with adaptive $\beta$ **[form approximate]**) and a reuse buffer of past attempts with PUCT-style selection. SOTA on Erdős' minimum-overlap, an autocorrelation inequality, a GPUMode kernel task (up to 2× faster), and others. Contrast with AlphaEvolve-style search using a *frozen* LLM: here the search is *amortized into the weights* as it goes.

These blur the line between "inference" and "training" — a natural home for RSI where every deployment step is a learning step.

### 2.9 RLVR as self-improvement: DeepSeek-R1-Zero

**R1-Zero (DeepSeek 2025; Nature, Sept 2025).** Pure RL from a base model (DeepSeek-V3-Base), no SFT, with **rule-based verifiable rewards** (answer correctness + format) and **GRPO**:

$$
A_i=\frac{r_i-\operatorname{mean}(r_{1:G})}{\operatorname{std}(r_{1:G})},\qquad
\mathcal{J}_{\text{GRPO}}=\mathbb{E}\Big[\tfrac1G\textstyle\sum_i \min\big(\rho_i A_i,\operatorname{clip}(\rho_i,1\!\pm\!\epsilon)A_i\big)-\beta\,\mathrm{KL}(\pi_\theta\|\pi_{\text{ref}})\Big],\ \rho_i=\tfrac{\pi_\theta(y_i\mid x)}{\pi_{\text{old}}(y_i\mid x)}.
$$

**[v]** AIME 2024 pass@1 15.6% → 71.0% (arXiv v1; the Nature version reports 77.9%), 86.7% with self-consistency (majority voting). Emergent long CoT, self-verification and the "aha moment". Why it counts as self-improvement: the training data are the model's own rollouts; only the *checker* is external. Note the group-normalized advantage is zero when all $G$ samples agree — problems with 0% or 100% success give no gradient, the same "learnability" insight as AZR/R-Zero.

---

## 3. Comparison table

| Method | Signal source | Data generator | Update rule | Needs external verifier? | Known failure mode |
|---|---|---|---|---|---|
| STaR | Ground-truth answer | Model (+ hint-conditioned rationalization) | SFT on filtered rationales, iterate | Yes (labels) | Correct answer via wrong rationale; needs few-shot ability to start |
| Quiet-STaR | Future-token likelihood | Model's internal thoughts | REINFORCE on thoughts | No (text itself) | Compute-heavy; small gains; thoughts not interpretable |
| V-STaR | Labels → verifier | Model | SFT (gen) + DPO (verifier) | Yes (labels) | Verifier overfits to generator's errors |
| ReST / ReST-EM | Binary reward / RM | Model | EM: filter (E) + reward-weighted SFT (M) | Yes (checker or RM) | Overfits with many iterations (APPS); pass@k not improved |
| Self-Instruct | Heuristic filters | Model (seed tasks) | SFT | No | Low-quality/noisy data; Alpaca-style variants are really distillation |
| Self-Rewarding | Self-judge (LLM-as-judge) | Model | Iterative DPO | No | Reward hacking, length inflation, judge saturation |
| Meta-Rewarding | Self-judge + self-meta-judge | Model | Iterative DPO (actor + judge) | No | Same as above; meta-judge bias |
| CAI / RLAIF | AI preferences guided by constitution | Model (critique-revise) | SFT + RL (PPO) on AI PM | No (needs constitution) | Inherits judge blind spots; constitution is a human anchor |
| SPIN | Human SFT data vs. past self | Previous iterate | DPO-like logistic loss | No (but needs human data) | Bounded by $p_{\text{data}}$; gains stall once matched |
| Absolute Zero | Code executor | Model as proposer | RL (TRR++) on propose+solve | Executor (environment) | Task-distribution drift; safety-relevant CoT oddities |
| R-Zero | Majority vote (self-consistency) | Challenger model | GRPO, alternating | No | Pseudo-label noise grows with difficulty; plateaus after few rounds |
| Anchored Self-Play | Unit tests + similarity anchor | Bug-generator role | RL | Tests + small real reference set | Without anchor: drift to unrealistic bugs |
| SEAL | Post-update downstream score | Model writes self-edits | Inner SFT + outer ReST-EM | Downstream eval | Catastrophic forgetting; very costly reward |
| TTRL | Majority vote on test set | Model | RL (GRPO/PPO) | No | Capped near initial maj@N; can reinforce consistent errors |
| TTT-Discover | Continuous objective of single problem | Model + attempt buffer | Test-time RL, entropic objective | Problem's evaluator | Overfits to one problem by design; compute-heavy |
| R1-Zero (RLVR) | Rule-based checker | Model | GRPO | Yes | Readability/language mixing; debate over "elicit vs. expand" |
| Weak-to-strong | Weak supervisor labels | Weak model | SFT (+ confidence loss) | No | Strong model imitates weak errors; poor for reward modeling |

---

## 4. Theory and limits

### 4.1 The generation–verification gap (Song et al., ICLR 2025)

Setup **[v at abstract level]**: the model (i) generates, (ii) **verifies its own outputs**, (iii) filters/reweights, (iv) distills. Let $u(x,y)$ be the true utility and $g$ the model's self-verification. Define the reweighted policy $\pi[g]$ (e.g., best-of-$N$ under $g$). The **generation–verification gap** is, roughly,

$$
\mathrm{GV\text{-}Gap}(\pi,g)=\mathbb{E}_x\Big[\mathbb{E}_{y\sim\pi[g](\cdot\mid x)}u(x,y)-\mathbb{E}_{y\sim\pi(\cdot\mid x)}u(x,y)\Big]
$$

— how much better the model's self-filtered outputs are than its raw outputs **[formal definition paraphrased]**. Self-improvement is only possible if this gap is positive. Key empirical finding **[v]**: a *relative* variant of the gap **scales monotonically with pretraining FLOPs** — bigger models are better self-verifiers relative to their generation. Additional findings (from the paper/summaries; **[partly unverified]**): the gap is task-dependent (near zero for some tasks like simple factual QA, where verifying is as hard as generating), iterative self-improvement saturates within a few rounds, and verification methods differ (multiple-choice / tournament / CoT-score).

**Why it matters:** this is *the* quantity that decides whether a model-level loop has fuel. Executors, unit tests and math checkers are ways to inject an *external* gap; self-judging relies on an *internal* one.

### 4.2 Sharpening (Huang, Block, Foster, Rohatgi, Zhang, Simchowitz, Ash, Krishnamurthy — ICLR 2025)

Thesis **[v]**: self-improvement = using the model **as its own verifier** to **sharpen** the distribution toward high-quality sequences, thereby **amortizing inference-time computation** (e.g., best-of-N search) into the weights.

Formalism (paraphrased; check paper for exact constants): take self-reward $r_{\text{self}}(x,y)=\log\pi_{\text{base}}(y\mid x)$ (or a length-normalized variant). Target: $y^\star(x)=\arg\max_y \pi_{\text{base}}(y\mid x)$. A sharpened policy $\hat\pi$ should satisfy $\hat\pi(y^\star(x)\mid x)\ge 1-\delta$ for most $x$. Two algorithm families:

- **SFT-Sharpening:** sample $N$ from $\pi_{\text{base}}$, pick the highest self-reward, SFT on it. **Minimax-optimal when the base model has sufficient coverage** of $y^\star$ **[v]**; sample complexity scales with a coverage coefficient like $C_{\text{cov}}=\mathbb{E}_x\big[1/\pi_{\text{base}}(y^\star(x)\mid x)\big]$ **[form unverified]**.
- **RLHF-Sharpening:** online RL against $r_{\text{self}}$ (with KL to base). Can **bypass the coverage requirement via online exploration** **[v]**.

Simple illustration of sharpening: $\pi_\beta(y\mid x)\propto\pi_{\text{base}}(y\mid x)^{1+\beta}$ — as $\beta\to\infty$ the policy becomes argmax. This is also the cleanest model of what RLVR "pass@1 up, pass@k flat/down" means: *mass concentrates on modes that were already there.*

### 4.3 Model collapse vs. accumulation

**Shumailov et al. (Nature, July 2024)** **[v]**: indiscriminately training on recursively generated data causes **irreversible defects in which the tails of the original distribution disappear**; shown for GMMs, VAEs and LLMs (OPT-125m fine-tuned on WikiText-2 across generations). Two sources of error compound: *statistical approximation error* (finite samples lose rare events) and *functional expressivity/approximation error*.

Toy derivation (Gaussian, useful at the whiteboard): fit $\hat\mu_t,\hat\sigma_t^2$ by MLE from $n$ samples of generation $t-1$'s fitted Gaussian, and **replace** the data each round. Since $\mathbb{E}[\hat\sigma^2_{t}\mid\hat\sigma^2_{t-1}]=\tfrac{n-1}{n}\hat\sigma^2_{t-1}$,

$$
\mathbb{E}[\hat\sigma_t^2]=\Big(\tfrac{n-1}{n}\Big)^t\sigma_0^2\;\xrightarrow{t\to\infty}\;0,
$$

i.e., variance (tails) shrinks geometrically; even with an unbiased estimator the variance performs a multiplicative random walk that collapses almost surely.

**Gerstgrasser et al. (ICML 2024 workshop / COLM 2024 **[venue unverified]**) — "Is Model Collapse Inevitable?"** **[v]**: in linear regression, **replacing** data makes test error grow (roughly linearly) with iterations, while **accumulating** real + all past synthetic data gives a **finite upper bound independent of the number of iterations** (as I recall the bound is a $\pi^2/6$ multiple of the single-fit error, from $\sum_k 1/k^2$ **[unverified constant]**). Confirmed empirically on LMs, diffusion and VAEs.

**Practical takeaways for any model-level loop:** keep real data in the mix (SPIN, ASP anchors), keep verifiers external where possible (AZR, R1-Zero), filter for *diversity* not just correctness, and accumulate rather than replace.

### 4.4 Does RL elicit or expand? (the pass@k debate)

Unbiased pass@k estimator (Chen et al. 2021): with $n$ samples, $c$ correct,

$$
\text{pass@}k=\mathbb{E}_x\Big[1-\tbinom{n-c}{k}\big/\tbinom{n}{k}\Big].
$$

- **Yue et al., "Does RL Really Incentivize Reasoning Capacity in LLMs Beyond the Base Model?" (NeurIPS 2025, Best Paper runner-up)** **[v]**: across math, code, visual reasoning, RLVR models win at small $k$ but **base models match or exceed them at large $k$ (e.g., 256)**; RLVR improves *sampling efficiency* but does not expand the *reasoning boundary* and narrows exploration. Distillation from a stronger teacher, by contrast, can expand it **[paper's claim as I recall; unverified]**.
- **ProRL (Liu et al., NVIDIA, NeurIPS 2025)** **[v]**: *prolonged* RL with KL control, reference-policy resets, and diverse tasks yields models that beat base models across pass@k, including on tasks where the base model fails regardless of $k$; gains correlate with base competence (largest where the base was weak) and training duration.
- Reconciliation (my synthesis): short RLVR ≈ **sharpening** (§4.2); long RL with exploration and diverse/hard tasks can **compose** existing skills into new trajectories that were astronomically unlikely (effectively zero coverage at practical $k$). "Inside the support" is not the same as "reachable by sampling." Self-play that **generates new tasks** (AZR, R-Zero, ASP) is one way to keep expanding the training distribution rather than sharpening a fixed one.

### 4.5 Weak-to-strong generalization (Burns et al., OpenAI 2023; ICML 2024)

Fine-tune a strong model on labels from a weak model. Metric: **performance gap recovered**

$$
\text{PGR}=\frac{\text{perf(weak→strong)}-\text{perf(weak)}}{\text{perf(strong ceiling)}-\text{perf(weak)}}.
$$

**[v]** With a GPT-2-level supervisor and GPT-4 student on NLP tasks plus an **auxiliary confidence loss**, ~80% of the gap is recovered; methods are inconsistent and much worse for **reward modeling**. Relevance to RSI: a self-improving model is a student that must exceed its own (weaker, earlier) supervisor — weak-to-strong is the empirical evidence that students can generalize *beyond* noisy supervision, and also a warning that they learn to imitate supervisor errors when they can. Weng's **Autodata** (Kulikov et al. 2026) flips this: a challenger generates tasks where the **strong solver succeeds but the weak solver fails**, and trains the weak solver — which Weng notes is closer to "indirect distillation over a generated prompt distribution" than RSI, since the strongest model doesn't improve.

### 4.6 Introspection (brief)

Self-improvement loops depend on a model knowing what it doesn't know. Relevant evidence (from `sources/awesome-rsi.md` §Introspection; not deeply verified here): models are partially calibrated about their own knowledge (Kadavath et al. 2022), can show privileged self-prediction after training (Binder et al., "Looking Inward", ICLR 2025), and can articulate learned behaviors (Betley et al. 2025). RISE ("Recursive Introspection", NeurIPS 2024) trains models to improve over their own previous attempts within a multi-turn episode. Better introspection = a larger *internal* generation–verification gap and better targeted curricula ("what should I practice next?").

---

## 5. Harness-level vs. model-level RSI: how they combine

| | Harness-level | Model-level |
|---|---|---|
| What changes | prompts, context, memory, tools, workflow code, optimizer code | weights θ |
| Speed / cost of an iteration | minutes, cheap, reversible | hours–weeks, expensive, hard to roll back |
| Interpretability / auditability | high (diffable code/text) | low |
| Generalization | brittle, task-specific | broad, amortized |
| Typical failure | overengineering, Goodhart on eval harness | collapse, reward hacking, forgetting |

**How they combine (concrete systems from Weng 2026):**

- **SIA (Hebbar et al. 2026):** a Meta-Agent proposes a harness, a Task-Specific Agent executes, and a **Feedback-Agent decides each iteration whether to update the harness or the model weights**. Weng's critique: confounded (task agent `gpt-oss-120b` vs. meta/feedback agents Claude Sonnet 4.6), weak baselines — "interesting direction, provisional evidence"; training stability and Goodhart effects open.
- **Continual Harness (Karten et al. 2026):** long-horizon gameplay; online harness updates plus co-learning a policy model by **distilling a strong teacher's labels on low-reward trajectories**.
- **Harness → data → weights.** A mature harness (verifiers, executors, curricula, agentic data scientists like Autodata) is the *generator + filter* in §1's loop; weight updates then amortize it. In sharpening language: **harness = inference-time search; training = amortization of that search.** Each RL/distillation step "internalizes" part of the harness.
- **Weights → better harness.** A smarter model writes better harness code (DGM, Hyperagents), closing the outer loop.

**Weng's prediction (sources/weng-2026, "Harness Layer vs Core Intelligence?"):** the near-term path is **not** a model directly rewriting its weights; rather (1) harness engineering becomes *meta-methodology* (optimizing the machinery for getting better answers), and (2) mature harnesses enable auto-research for the model self-improvement loop while smarter models keep harnesses from overengineering. Eventually many harness improvements get **internalized** into the model (like prompt tricks were absorbed by instruction tuning), but the *interface* to external context, tools, goals, constraints and evaluation remains.

My one-line synthesis for interviews: **model-level methods supply amortization and generalization; harness-level methods supply the verification gap, exploration and curriculum. RSI needs both — the harness is where new signal is created, the weights are where it is compounded.**

---

## 6. Interview angles (Q&A)

**Q1. Give one framework that covers STaR, ReST-EM, Self-Rewarding, SPIN, and R1-Zero.**
Generate → filter/weight → train, differing by signal source and update rule. STaR/ReST-EM: label-filtered SFT (EM / filtered policy gradient). Self-Rewarding: self-judged pairs + DPO. SPIN: human-vs-self pairs + DPO-like loss. R1-Zero: checker reward + GRPO.

**Q2. Show that SFT on correct self-samples is a policy gradient.**
$\nabla \mathbb{E}_{\pi_\theta}[r] = \mathbb{E}_{\pi_\theta}[r\nabla\log\pi_\theta]$. With $r\in\{0,1\}$ and samples drawn from current $\pi_\theta$, the SFT gradient on kept samples, $\sum_{i:r_i=1}\nabla\log\pi_\theta(y_i)$, is an unbiased (unnormalized) estimate. It becomes off-policy/biased once you reuse samples across many steps or use rationalization (proposal $\neq\pi_\theta$), which would need importance weights.

**Q3. Derive the ReST-EM E-step.**
Maximize ELBO $\mathbb{E}_q[\log p(O|x,y)] - \mathrm{KL}(q\|\pi_\theta)$ over $q$: solution $q^\star\propto \pi_\theta(y|x)\,p(O{=}1|x,y)$. With binary reward this is "$\pi_\theta$ restricted to correct samples" — exactly rejection sampling. M-step = weighted MLE.

**Q4. What is the optimum of SPIN and why does it imply a ceiling?**
The game's global optimum is $p_\theta=p_{\text{data}}$: when the model's samples are indistinguishable from human data the logistic loss has no preferred direction. So SPIN cannot exceed the quality of its SFT data — it's a sample-efficient way to fit $p_{\text{data}}$, not a source of new knowledge.

**Q5. Why does Absolute Zero set the proposer reward to 0 at solve-rate 0 or 1? Relate to GRPO.**
Tasks with all-pass or all-fail give zero group-normalized advantage in the solver's RL (no gradient), and 0-rate tasks may be invalid. Rewarding $1-\bar r$ in $(0,1)$ pushes the curriculum to the solver's frontier. R-Zero's $1-2|\hat p-\tfrac12|$ is the same idea peaked at 50%. Variance of a Bernoulli reward, $p(1-p)$, is also maximized at $p=1/2$ — that's where per-sample gradient signal is largest.

**Q6. Model collapse: give the math and the remedy.**
Gaussian refit with replacement: $\mathbb{E}\hat\sigma_t^2 = ((n-1)/n)^t\sigma_0^2\to 0$ — tails vanish. Remedy: accumulate real + synthetic (Gerstgrasser: bounded error), keep an anchor to real data, external verifiers, diversity filters.

**Q7. TTRL uses majority vote as the label. Why doesn't it just reinforce wrong answers?**
It partly can. But (i) reward correctness ≠ label correctness: a sample with a wrong answer that disagrees with a wrong majority still gets the right reward (0); (ii) RL sharpens toward the majority, which, for a reasonably calibrated model, is correct more often than a single sample — so pass@1 rises toward maj@N. The ceiling is roughly the initial maj@N, and it fails on problems where the model is confidently wrong.

**Q8. "RL only sharpens" — defend and attack.**
Defend: Yue et al.: at large $k$ base ≥ RL; sharpening theory says RL concentrates mass on existing modes. Attack: ProRL shows pass@k gains where base fails at all $k$ after long RL with resets and diverse tasks; "in support" ≠ "reachable"; composition of skills makes previously negligible-probability trajectories likely. Also measurement issues: pass@k at huge $k$ on answer-only checks rewards guessing (e.g., numeric answers). A good answer: it depends on training length, task diversity, exploration, and whether new tasks are generated.

**Q9. What is the generation–verification gap and how would you measure it?**
Difference in true utility between self-filtered (e.g., best-of-$N$ by self-verification) and raw generations. Measure: sample $N$ per prompt, score with the model's own verifier, pick top, compare accuracy against unfiltered. Song et al. find a relative version scales with pretraining FLOPs. If ≈0, self-improvement has no fuel without external signal.

**Q10. How does SEAL differ from Self-Instruct?**
Self-Instruct generates data once with heuristic filters. SEAL *learns the data generator* with RL whose reward is "did fine-tuning on this data improve downstream performance" — a bilevel/meta-learning objective. It optimizes the *update*, not the answer.

**Q11. When would you choose harness-level vs. model-level improvement in a product?**
Harness when iteration speed, auditability and rollback matter, or when the gap is in tools/context. Model-level when the same reasoning pattern is needed across many tasks (amortization), when latency/cost of inference-time search is too high, or when the harness has become a pile of heuristics that a model could internalize. A Feedback-Agent à la SIA formalizes this as a learned choice.

**Q12. Self-Rewarding: what are the failure modes and mitigations?**
Self-preference/judge bias, length inflation, reward hacking (actor exploits judge), judge saturation. Mitigations: meta-judging (Meta-Rewarding), length control, mixing in human/verified preference data, external verifiers, holding out a fixed judge for evaluation.

**Q13. Why does anchoring matter in self-play (ASP)?**
Executable verifiers certify correctness, not realism; the generator optimizes for difficulty and drifts to an unnatural distribution, so fixer gains don't transfer (even degrade). An embedding-similarity reward to real bugs + mixing real bugs into training keeps the curriculum on-distribution. General principle: Goodhart on the curriculum generator.

**Q14. Compute: what's the fixed point of self-improvement with a perfect verifier and infinite compute?**
With a perfect verifier and a model with nonzero coverage of correct solutions, SFT/RL-sharpening drives pass@1 → coverage-reachable pass@∞ of the base; beyond that you need exploration (online RL), new tasks (self-play), or new knowledge (environment interaction). So the limit is set by the reachable support, not the verifier.

---

## 7. Open research questions

1. **Sustained iteration.** Almost all loops plateau within ~3–5 rounds (Self-Rewarding, R-Zero, ReST-EM on APPS). What keeps the generation–verification gap open over many rounds? Co-training verifiers (V-STaR, Meta-Rewarding) is a partial answer.
2. **Ungrounded domains.** How to self-improve on open-ended research tasks where neither executor nor checker exists? Rubric co-evolution (EvoLM, SERPO in awesome-rsi) is an early attempt; Goodhart risk is high.
3. **Elicit vs. expand, properly measured.** Better metrics than pass@k at large $k$ (which over-credits guessing); controlled studies on synthetic tasks with known support.
4. **Continual learning without forgetting.** SEAL and test-time training highlight catastrophic forgetting; how to accumulate many self-edits (memory-like weights, LoRA libraries, replay)?
5. **Curriculum drift and anchoring.** How small can the real-data anchor be (ASP, model-collapse accumulation)? Can it be learned?
6. **Harness ↔ weights credit assignment.** When should an improvement live in the harness vs. the weights (SIA's Feedback-Agent)? What is "internalization" formally — distillation of a search procedure?
7. **Safety of self-modification.** Self-generated tasks can produce concerning reasoning (AZR's reported oddities); reward hacking by self-judges; oversight when the model writes its own training data (SEAL). Weak-to-strong-style guarantees for RSI.
8. **Scaling laws for self-improvement.** Song et al. relate the gap to pretraining FLOPs; what's the analogous law for the *number of useful rounds* or for proposer/solver co-evolution?

---

## Sources consulted (via web search, 2026-10-01)

- STaR: https://arxiv.org/abs/2203.14465 · Quiet-STaR: https://arxiv.org/abs/2403.09629 · V-STaR: https://arxiv.org/abs/2402.06457
- ReST-EM: https://arxiv.org/abs/2312.06585 · Self-Rewarding: https://arxiv.org/abs/2401.10020 · Meta-Rewarding: https://arxiv.org/abs/2407.19594
- SPIN: https://arxiv.org/abs/2401.01335 · Self-Instruct: https://arxiv.org/abs/2212.10560 · RLAIF vs RLHF: https://arxiv.org/abs/2309.00267 · Constitutional AI: https://arxiv.org/abs/2212.08073
- Absolute Zero: https://arxiv.org/abs/2505.03335 · R-Zero: https://arxiv.org/abs/2508.05004 · Anchored Self-Play: https://arxiv.org/abs/2607.03523 (ICML 2026 poster https://icml.cc/virtual/2026/poster/62051)
- SEAL: https://arxiv.org/abs/2506.10943 · TTRL: https://arxiv.org/abs/2504.16084 · TTT-ARC: https://arxiv.org/abs/2411.07279 · TTT-Discover: https://arxiv.org/abs/2601.16175
- DeepSeek-R1: https://arxiv.org/abs/2501.12948 · Yue et al.: https://arxiv.org/abs/2504.13837 · ProRL: https://arxiv.org/abs/2505.24864
- Model collapse: Nature 631, 755–759 (2024), doi:10.1038/s41586-024-07566-y · Accumulate: https://arxiv.org/abs/2404.01413
- Weak-to-strong: https://arxiv.org/abs/2312.09390 · Mind the Gap: https://arxiv.org/abs/2412.02674 · Sharpening: https://arxiv.org/abs/2412.01951
- Weng 2026 (local: `sources/weng-2026-harness-engineering-for-self-improvement.md`), awesome-rsi (local).
