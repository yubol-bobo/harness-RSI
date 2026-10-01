# Google AI co-scientist

- **Who / when:** Juraj Gottweis et al., Google Research / DeepMind with academic partners. Preprint Feb 2025 ("Towards an AI co-scientist"). Published in **Nature on 19 May 2026** (with companion papers including FutureHouse's **Robin**) [Nature publication details from secondary sources].
- **One-line:** a Gemini-based multi-agent system that **generates, debates, and evolves** research hypotheses, ranked by a tournament.

## Mechanism (from the 2025 preprint, from memory) [unverified details]
- Supervisor agent + specialized agents: **Generation, Reflection (review), Ranking (Elo tournament via simulated debates), Evolution (refine/combine), Proximity (cluster similar ideas), Meta-review**.
- Test-time compute scaling: more tournament rounds → higher Elo → better expert-rated quality.

## Results (validated by human-run wet labs)
- **AML drug repurposing:** nominated **KIRA6** (an IRE1α inhibitor not previously tested in AML). In cell assays it was selective for leukemia cells at concentrations up to **~18x lower** than those that harmed controls (per press coverage).
- **Liver fibrosis:** novel epigenetic targets validated in organoids.
- **Antimicrobial resistance:** independently proposed a mechanism for gene transfer (cf-PICI / phage tails) that matched an unpublished experimental finding.

## Caveats
- Humans ran all wet-lab work. The system proposes; it does not execute.
- Novelty and quality are partly judged by experts and Elo, not ground truth.
- Coverage of the Nature cluster notes that Robin's unsupervised bioinformatics performance fell to ~15% [secondary].

## RSI relevance
It is science acceleration, not AI improving AI. It matters as an example of **search + LLM-judge tournaments** as a harness pattern, and of "AI for science" transferring to AI R&D.
