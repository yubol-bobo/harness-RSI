# Context Rot (Chroma)

- **Title:** Context Rot: How Increasing Input Tokens Impacts LLM Performance
- **Authors:** Kelly Hong, Anton Troynikov, Jeff Huber (Chroma)
- **Year:** Jul 14, 2025
- **Link:** https://research.trychroma.com/context-rot
- **Status:** **NOT read directly** (blocked). Based on search summaries; cited by Anthropic's context-engineering post.

**One-line TL;DR:** Across **18 LLMs**, performance degrades non-uniformly as input length grows, even on trivially simple tasks, so long context windows are not uniformly reliable.

**Method:** Extended needle-in-a-haystack (varying needle–question semantic similarity, adding distractors, varying haystack coherence), repeated-word copying, and LongMemEval-style conversational QA at increasing lengths.

**Key results (as summarized):**
- Lower needle–question similarity leads to faster degradation with length.
- Semantically similar distractors hurt more as context grows.
- **Shuffled (incoherent) haystacks outperform coherent ones** across models.
- Models differ in degradation profile, but all degrade.

**Why it matters for harness/RSI:** It is the empirical basis for the "attention budget" view and for context engineering as a necessity rather than a hack. It also motivates sub-agent isolation, clearing and JIT retrieval.

**Limitations:** Mostly synthetic retrieval-style tasks; agentic multi-step degradation is not directly measured. Exact numbers not verified here.

**My questions:** How does context rot interact with RL-trained long-horizon agents: do agentic RL models degrade more gracefully? Is degradation driven by length or by distractor density?
