# AHE — Agentic Harness Engineering: Observability-Driven Automatic Evolution of Coding-Agent Harnesses

- **Authors:** Jiahang Lin, Shichun Liu, Chengjun Pan, et al.
- **Year / Venue:** 2026 (arXiv April 2026, rev. May 2026) / preprint
- **Link:** https://arxiv.org/abs/2604.25850
- **Ladder level:** 4 (harness components as files)

## TL;DR
Harness evolution is bottlenecked by observability. AHE makes components, experience, and decisions observable: file-level components, layered trace-derived evidence, and every edit paired with a falsifiable predicted impact. Ten iterations lift Terminal-Bench 2.0 pass@1 from 69.7% to 77.0%.

## Problem
When a rollout fails, which harness component is responsible? Without attribution, evolution is blind and gains are unattributable or hacked.

## Method — three pillars
1. **Component observability:** 7 editable components — system prompt, tool description, tool implementation, middleware, skill, sub-agent configuration, long-term memory — each a git-tracked file; failure patterns are mapped to one component.
2. **Experience observability:** each harness produces $k$ traces; an *Agent Debugger* writes a per-task root-cause report; reports aggregate into a benchmark overview; raw traces remain drill-down accessible (layered, token-efficient).
3. **Decision observability:** an *Evolve Agent* chooses which component to edit and writes a manifest entry: failure evidence, inferred root cause, targeted fix, predicted impact (expected fixes + at-risk regressions); next round verifies.
- **Constraints:** edits only inside the harness workspace; runs dir, tracer, verifier, LLM config are read-only (prevents disabling the verifier, swapping the model, raising reasoning budget).

## Key results
- Terminal-Bench 2.0 pass@1 69.7% → 77.0% in ten iterations (GPT-5.4), above the human-designed Codex CLI harness (71.9%) and self-evolving baselines ACE and TF-GRPO.
- Frozen evolved harness transfers to SWE-bench Verified; cross-family gains +5.1 to +10.1 pp across three alternate model families (secondary sources: DeepSeek-v4-flash +10.1, Qwen-3.6-plus +6.3, Gemini-3.1-flash-lite +5.1).
- Weng: did not beat human harnesses on the Hard tier.

## Why it matters for RSI
Turns harness evolution into an *auditable scientific process* (evidence → hypothesis → prediction → test). The read-only evaluator boundary is the cleanest worked example of "keep the evaluator outside the loop."

## Limitations
- Evolve agent and debugger are fixed (not recursive).
- Prediction verification is noisy at benchmark scale; Hard-tier tasks remain unsolved.
- Same-benchmark search/eval concerns (cf. 2607.12227).

## Connections
Meta-Harness (filesystem history), Self-Harness (failure mining + regression gates), TextGrad (credit assignment), ACE (baseline), DGM.

## Questions to think about
1. How would you score the accuracy of the evolve agent's predictions, and use it to weight future edits?
2. Which of the 7 components do you expect to transfer across models, and why?
