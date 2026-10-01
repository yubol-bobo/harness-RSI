# OPRO — Large Language Models as Optimizers

- **Authors:** Chengrun Yang, Xuezhi Wang, Yifeng Lu, Hanxiao Liu, Quoc V. Le, Denny Zhou, Xinyun Chen (Google DeepMind)
- **Year / Venue:** 2023 / ICLR 2024
- **Link:** https://arxiv.org/abs/2309.03409
- **Ladder level:** 1 — instruction prompt

## TL;DR
Describe the optimization problem in natural language, show the LLM previously tried solutions sorted by score, ask it for a better one; iterate. Applied to prompt optimization.

## Problem
Derivative-free optimization over discrete spaces (like prompts) where the objective is only evaluable, not differentiable.

## Method
1. Build a **meta-prompt**: task description + a few training exemplars + the optimization trajectory (top-k past prompts with their training accuracies, sorted ascending).
2. Optimizer LLM generates several new candidate prompts per step.
3. Scorer LLM evaluates each candidate on a training subset; add (prompt, score) to trajectory.
4. Repeat until no improvement / budget.
(Also demonstrated on linear regression and TSP as toy optimization problems.)

## Key results
- Best OPRO prompts outperform human-designed prompts by up to 8% on GSM8K and up to 50% on Big-Bench Hard tasks (abstract).
- Famous discovered instruction: "Take a deep breath and work on this problem step-by-step." **[recalled; verify exact wording/model]**

## Why it matters for RSI
Established the "scored history in context" optimizer pattern used by ADAS (archive), Meta-Harness (filesystem history), MCE (skill database).

## Limitations
- Proposer sees only scalars → weak credit assignment.
- Small training sets → overfitting; prompts can be model-specific.
- Meta-prompt grows; limited exploration.

## Connections
APE (earlier prompt search), Promptbreeder, DSPy/MIPRO, GEPA (adds traces + reflection).

## Questions to think about
1. Why does sorting history ascending (best last) help an autoregressive model?
2. What is the minimum information needed in feedback for the optimizer to beat random search?
