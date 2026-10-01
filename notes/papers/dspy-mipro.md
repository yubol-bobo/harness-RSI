# DSPy and MIPRO — Compiling LM Programs; Optimizing Instructions & Demonstrations

- **DSPy:** Omar Khattab, Arnav Singhvi, Paridhi Maheshwari, Zhiyuan Zhang, Keshav Santhanam, et al., Matei Zaharia, Christopher Potts. 2023. ICLR 2024 (awesome-rsi lists the NeurIPS 2023 R0-FoMo workshop version). https://arxiv.org/abs/2310.03714
- **MIPRO:** Krista Opsahl-Ong, Michael J. Ryan, Josh Purtell, David Broman, Christopher Potts, Matei Zaharia, Omar Khattab. 2024. EMNLP 2024 **[venue recalled; verify]**. https://arxiv.org/abs/2406.11695
- **Ladder level:** 1→3 boundary — per-module prompts of a multi-stage program

## TL;DR
Write LM pipelines as declarative modules with signatures; an optimizer ("teleprompter") compiles them by choosing instructions and few-shot demos per module to maximize a metric. MIPRO is the strongest classic DSPy optimizer, using a Bayesian surrogate for credit assignment across modules.

## Problem
Multi-stage LM programs need jointly good prompts for all modules, but there are no labels for intermediate steps and no gradients.

## Method
**DSPy**
1. Modules with signatures (`question -> answer`), composed in Python.
2. Metric $\mu(\hat y, y)$ on a small train set.
3. **BootstrapFewShot:** run the program (teacher), keep traces where the final metric passes, use the intermediate input/outputs as demos for each module; random search over demo sets.

**MIPRO** (objective: $\max_{\{\iota_m,\delta_m\}} \frac{1}{|D|}\sum \mu(\Phi(x),y)$)
1. Bootstrap demo candidates per module.
2. Propose instruction candidates using program- and data-aware grounding (dataset summary, program code, example traces, tips).
3. Stochastic mini-batch evaluation; fit a **Bayesian surrogate** (TPE-style) over discrete choices per module → credit assignment.
4. Meta-optimization: LMs refine how proposals are generated over time.

## Key results
- DSPy: compiled pipelines outperform standard few-shot prompting by over 25% (GPT-3.5) and 65% (llama2-13b-chat) (abstract).
- MIPRO: outperforms baseline optimizers on 5 of 7 LM programs with Llama-3-8B, by up to 13% accuracy (abstract).

## Why it matters for RSI
Reframes prompts as *learnable parameters of a program* — the conceptual bridge to "harness = code + parameters to optimize". DSPy hosts GEPA and is the most deployed prompt-optimization stack.

## Limitations
- Optimizes text parameters only; program structure is human-designed.
- Metric must be cheap; small train sets risk overfitting.
- Surrogate over discrete combos scales poorly with many modules.

## Connections
OPRO (proposal by LLM), GEPA (successor optimizer; beat MIPROv2), TextGrad (alternative credit assignment), Meta-Harness (co-authored by Khattab; moves to code).

## Questions to think about
1. Why are bootstrapped demos often more valuable than instructions?
2. How does credit assignment in MIPRO compare to textual backprop in TextGrad?
