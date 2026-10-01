# Anchored Self-Play for Code Repair (ASP)

- **Authors:** Caroline Choi, Zeyneb Kaya, Shirley Wu, Tengyu Ma, Tatsunori Hashimoto, Ludwig Schmidt (Stanford)
- **Year / Venue:** 2026 / ICML 2026
- **Link:** https://arxiv.org/abs/2607.03523 · https://icml.cc/virtual/2026/poster/62051

**TL;DR:** Bug-generator / fixer self-play with RL improves repair on self-generated bugs but drifts from real bugs; anchoring to a small real reference set fixes this.

**Problem:** Unit tests certify correctness but not *realism*; self-play generators drift and can *degrade* performance on real-world bugs.

**Method:** One model alternates generating bugs and fixing them (automatic curriculum). ASP adds (i) code-embedding similarity reward to a small reference set of real bugs for the generator; (ii) mixes reference bugs into fixer training. New benchmark BugSourceBench (human-authored bugs, human-edited buggy LM code, errors in LM-generated code).

**Key results (verified):** Best fix rates; +7.2 pp absolute (+25% relative) average fix rate over standard self-play.

**Why it matters for RSI:** Concrete evidence of *curriculum Goodhart* in self-play and a cheap remedy (anchoring) — parallels accumulate-vs-replace in model collapse. Likely the "Choi et al. 2026" cited by Weng **[match unverified]**.

**Limitations:** Requires a reference set; code-repair only; embedding similarity is a crude realism proxy.

**Connections:** Absolute Zero, SPIN (human anchor), model collapse/accumulation, SWE-RL.

**Questions:** How small can the anchor be? Can realism be judged by a learned discriminator instead?
