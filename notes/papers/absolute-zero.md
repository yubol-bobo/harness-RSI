# Absolute Zero: Reinforced Self-play Reasoning with Zero Data

- **Authors:** Andrew Zhao, Yiran Wu, Yang Yue, Tong Wu, Quentin Xu, Matthieu Lin, Shenzhi Wang, Qingyun Wu, Zilong Zheng, Gao Huang (Tsinghua et al.) **[author list partly from memory]**
- **Year / Venue:** 2025 / NeurIPS 2025
- **Link:** https://arxiv.org/abs/2505.03335

**TL;DR:** One model proposes code-reasoning tasks and solves them; a Python executor validates tasks and checks answers; trained with RL, zero external data.

**Problem:** RLVR still depends on human-curated question/answer sets, which won't scale or exceed human-designed curricula.

**Method:** Tasks are (program, input, output) triplets; modes deduction / abduction / induction. Learnability reward $r^{\text{propose}}=1-\bar r_{\text{solve}}$ if $0<\bar r_{\text{solve}}<1$ else 0; solver reward = executor-checked correctness. Joint training with Task-Relative REINFORCE++ (per task-type×role baselines). Buffer of past valid triplets conditions new proposals.

**Key results (verified):** Overall SOTA among zero-setting models on coding + math, +1.8 points average over prior zero-setting models trained on curated data; AZR-Coder-7B gains +15.2 math points from code-only self-play (vs ~+0.65 for expert code models after RLVR).

**Why it matters for RSI:** Self-generated curriculum with an external, unhackable grounding (execution) — closest current template for open-ended model-level RSI.

**Limitations:** Domain limited to what a code executor can verify; reported concerning CoT in Llama-3.1-8B runs ("uh-oh moment") **[unverified wording]**; task distribution may drift from useful tasks.

**Connections:** R-Zero, Anchored Self-Play, asymmetric self-play (Sukhbaatar 2018), PAIRED/teacher-student curricula.

**Questions:** What anchors task usefulness? Does the learnability reward stay informative as the solver improves?
