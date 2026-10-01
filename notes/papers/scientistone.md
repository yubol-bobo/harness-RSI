# ScientistOne: Towards Human-Level Autonomous Research via Chain-of-Evidence

- **Who / when:** Rui Meng, Bhavana Dalvi Mishra, Jiefeng Chen, Chun-Liang Li, Palash Goyal, Mihir Parmar, Yiwen Song, et al. (Google Cloud AI Research). arXiv [2605.26340](https://arxiv.org/abs/2605.26340), May 2026. Project page: scientist-one.github.io. A Google Research blog calls the framework "Science One Framework" / "Scientist-One".
- **One-line:** make **verifiability** the central design constraint. Every claim must trace to an evidence source.

## Mechanism
- **Chain-of-Evidence (CoE):** claims are typed (citation, numerical, methodological, conclusion), and each is linked to evidence (retrieved paper, run log/score, code, task spec). The chains are maintained *by construction* through literature review, solution discovery, and writing.
- **Pipeline:** Problem Investigator → Discovery Engine → Paper Writer with **Claim Verifier**.
- **CoE Integrity Audit:** four checks applied to *all* compared systems:
  1. **Score verification:** are the reported numbers reproducible from the logs?
  2. **Specification violation:** did the agent break task rules?
  3. **Reference verification:** do the citations exist, and do they support the claim?
  4. **Method–code alignment:** does the code implement the described method?

## Results
- Reported **top-1 on the Parameter Golf live LLM-training competition** as of 27 Apr 2026 (per abstract summaries) [unverified detail, I could not read the PDF].
- Other quantitative comparisons: not verified here.

## Why it matters
It directly targets the failure modes in Trehan & Chopra and Weng: fabricated citations, unreproducible scores, and method descriptions that diverge from the code (implementation drift). It is a *type system for research claims* and doubles as an **evaluation protocol** for other auto-researchers.

## Caveats
- The verifiers are themselves partly LLM-based, so the auditor has blind spots.
- A live-competition result is strong evidence against contamination, but it covers a narrow, metric-driven task.
- A follow-up, "ScientistTwo" (arXiv 2609.19644), appeared in Sep 2026 [not read].

## Interview hooks
- "How do you stop an AI scientist from fabricating?" Answer: CoE plus an evaluator outside the loop.
