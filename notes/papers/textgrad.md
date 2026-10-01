# TextGrad — Automatic "Differentiation" via Text

- **Authors:** Mert Yuksekgonul, Federico Bianchi, Joseph Boen, Sheng Liu, Zhi Huang, Carlos Guestrin, James Zou
- **Year / Venue:** 2024 (arXiv June 2024) / Nature 2025
- **Link:** https://arxiv.org/abs/2406.07496
- **Ladder level:** 1–2 (any textual variable: prompts, solutions, code)

## TL;DR
Autograd for compound AI systems where gradients are natural-language critiques produced by an LLM, back-propagated through a computation graph of LLM calls; a "Textual Gradient Descent" step rewrites each variable.

## Problem
Compound systems (multiple LLM calls, tools) have many textual knobs and no gradients; how do we assign credit and update each knob?

## Method
1. Define variables (text) with `requires_grad`; build a graph of LLM calls / functions.
2. Loss: an LLM evaluation (or metric) producing textual feedback.
3. Backward: for each variable $v$, ask an LLM how $v$ should change given downstream gradients: $\partial \mathcal L/\partial v = \bigcup_{w\in \mathrm{succ}(v)} \nabla_{\mathrm{LLM}}(v, w, \partial \mathcal L/\partial w)$.
4. TGD step: $v_\text{new} = \mathrm{TGD.step}(v, \partial\mathcal L/\partial v)$ (an LLM rewrites $v$). PyTorch-like API.

## Key results (abstract)
- GPT-4o zero-shot GPQA accuracy 51% → 55%.
- 20% relative performance gain on LeetCode-Hard solution optimization.
- Also: prompt optimization for reasoning, molecule design, radiotherapy treatment plan optimization.

## Why it matters for RSI
Supplies a general credit-assignment language for multi-component harnesses; anticipates "experience observability" and trace-grounded edits in AHE/Self-Harness.

## Limitations
- Gradients are LLM opinions — can be wrong/verbose; no step size or convergence guarantees.
- Cost scales with graph size; instance-level optimization (e.g., one solution) isn't persistent improvement.

## Connections
Reflexion (verbal feedback), GEPA (reflection + evolution), Dynamic Cheatsheet (same group), DSPy/MIPRO (alternative compile-time approach).

## Questions to think about
1. What's the analogue of momentum or learning-rate in textual gradient descent?
2. When is instance-level test-time optimization "self-improvement" vs. "self-refinement"?
