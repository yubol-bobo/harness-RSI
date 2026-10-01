# Manus — Context Engineering Lessons

- **Title:** Context Engineering for AI Agents: Lessons from Building Manus
- **Authors:** Yichao "Peak" Ji (Manus)
- **Year:** Jul 2025
- **Link:** https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus
- **Status:** **NOT read directly** (blocked). Reconstructed from multiple summaries plus my memory of the post; specific numbers below appeared in summaries.

**One-line TL;DR:** Six production lessons. Optimize **KV-cache hit rate**; **mask, don't remove** tools; use the **file system as (restorable) context**; **recite** goals (todo.md); **keep errors in context**; **avoid few-shot ruts** via structured variation.

**Problem:** A general agent with ~50 tool calls per task and ~100:1 input:output tokens is dominated by prefill cost and suffers from goal drift and context bloat.

**Method:** Context engineering instead of fine-tuning ("ship improvements in hours instead of weeks", orthogonal to the model). Four framework rebuilds via "Stochastic Graduate Descent" (empirical architecture search).

**Key facts:** Cached vs uncached input **$0.30 vs $3.00 / MTok** (Claude Sonnet), a 10× gap. KV-cache hit rate is "the single most important metric for a production agent". No timestamps at the prompt start; append-only, deterministic serialization; logit masking / prefill to restrict tools, with consistent tool-name prefixes (`browser_`, `shell_`); compression must be restorable (keep URL/path); todo.md pushes the plan into recent attention.

**Why it matters for harness/RSI:** The clearest statement of **inference-economics constraints on harness design**. Its error-preservation principle matches Weng's "negative results" challenge (harnesses should preserve failures as learning signal).

**Limitations:** Blog, not a paper; no ablation numbers; Manus-specific stack.

**My questions:** How much do these lessons depend on model family (Ji himself warns context engineering can overfit to current models)? Can logit masking coexist with provider APIs that don't expose logits?
