# Trae Agent: An LLM-based Agent for Software Engineering with Test-time Scaling

- **Authors:** Trae Research Team (ByteDance) and collaborators
- **Year:** 2025 (open-sourced 2025-07-04; arXiv July 2025)
- **Link:** https://arxiv.org/abs/2507.23370 · code https://github.com/bytedance/trae-agent · also ICSE 2026 research track as "Agent-Based Ensemble Reasoning for Repository-Level Issue Resolution"

## TL;DR
The open-source core agent of ByteDance's TRAE IDE. Treats issue resolution as **optimal solution search** with test-time scaling: **modular agents for generation, pruning and selection** of candidate patches.

## Method
- **Tools:** string-replace file editor, persistent bash shell, a sequential-thinking tool (structured iterative reasoning), task-completion signal.
- **Test-time scaling ("agent-based ensemble reasoning"):** generate many candidate patches; prune (e.g., dedupe / filter by regression behavior); select the best with an agent that has repository-level understanding. Addresses (1) large ensemble spaces and (2) repository-level understanding, which prompting-only ensemble methods lack.
- Designed as a research-friendly, modular CLI harness (configurable LLM providers, trajectory recording).

## Results (verified from abstract)
- **75.20% Pass@1 on SWE-bench Verified**, first place on the leaderboard at the time.
- +10.22% average Pass@1 over all baselines in their comparisons.

## Relevance to harness / RSI
- A production harness from the company interviewing you: tools + loop + search + selection.
- **Selection is an evaluator.** Goodhart questions apply: does the selector prefer patches that pass visible tests but don't fix the issue?
- A natural target for harness self-evolution (cf. DGM, which evolved a SWE-bench agent; HarnessDev's code domain, where model-built harnesses still lag human ones).

## Questions to prepare
- Compare trae-agent's search/selection to DGM's evolutionary archive: one searches over *patches* at test time, the other over *agent code* across iterations.
- How would you let trae-agent evolve its own prompts/tools safely? Which components must stay read-only?
- What does "trajectory recording" enable for self-improvement (AHE-style failure attribution)?
