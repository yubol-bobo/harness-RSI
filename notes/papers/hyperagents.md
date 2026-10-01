# Hyperagents (DGM-H)

- **Authors:** Jenny Zhang et al. (UBC / Meta FAIR / Meta Superintelligence Labs / Vector; Jeff Clune among senior authors) — full list **[unverified]**
- **Year:** 2026 (arXiv 2603.19461, 19 Mar 2026)
- **Venue:** arXiv; "accepted to ICLR 2026" appears only in secondary sources **[unverified]**
- **Link:** https://arxiv.org/abs/2603.19461 · code https://github.com/facebookresearch/HyperAgents (CC BY-NC-SA 4.0)

## TL;DR
Put the **task agent and the meta agent in one editable program**, so the self-improvement procedure itself evolves (metacognitive self-modification); extends DGM beyond coding.

## Problem
DGM assumes task skill ⇒ self-improvement skill; true in coding (the self-edit is coding), false in e.g. paper reviewing or reward design.

## Method
DGM-style archive and open-ended selection, but the meta-level modification code is part of the editable hyperagent.

## Key results (secondary summaries of the paper)
- Coding: comparable to DGM.
- Non-coding: paper review **0.710** accuracy; robotics reward design **0.372**; beats non-customized DGM.
- Meta-level improvements (e.g. persistent memory, performance tracking) transfer across domains: Olympiad-math grading **imp@50 = 0.630**.
- `imp@k` = improvement after k iterations, not absolute SOTA.

## Why it matters for RSI
Moves from "improve the agent" to "improve how the agent improves" — closer to full RSI at harness level.

## Limitations
Fixed FM; editable meta-level enlarges the attack/hacking surface — Roesner & Kohno (2026) poisoned Hyperagents to disable HTTPS verification in 30/30 neutral tasks.

## Connections
DGM, ADAS, HGM, Gödel Agent, trusting-trust contamination.

## Questions
Which components must remain immutable (evaluator, sandbox, selection) for safety, and does freezing them cap improvement?
