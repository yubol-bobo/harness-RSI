# The AI Scientist (v1, v2, and the 2026 *Nature* paper)

- **Who / when:** Sakana AI with UBC (Jeff Clune's group), Vector Institute, and Oxford. Lead author Chris Lu.
  - v1: *The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery*, arXiv [2408.06292](https://arxiv.org/abs/2408.06292), Aug 2024.
  - v2: *The AI Scientist-v2: Workshop-Level Automated Scientific Discovery via Agentic Tree Search*, arXiv [2504.08066](https://arxiv.org/abs/2504.08066), Apr 2025.
  - *Nature*: Lu et al., "Towards end-to-end automation of AI research", *Nature* 651:914–919, published 26 Mar 2026 ([doi](https://doi.org/10.1038/s41586-026-10265-5)).
- **One-line:** a hand-designed harness that runs the whole ML-paper lifecycle. Ideate → novelty check → code experiments → analyze → write LaTeX → automated review.

## How it works
- **v1:** starts from a human *code template* for a narrow area (e.g. diffusion, NanoGPT, grokking). The LLM proposes ideas, scores them (interestingness/novelty/feasibility), and checks novelty via Semantic Scholar. Aider-based coding implements experiments. The paper is written section by section. An LLM reviewer calibrated on ICLR reviews scores it.
- **v2:** **template-free**. **Agentic tree search** over experiment nodes (parallel exploration, debugging, ablation stages) managed by an experiment-manager agent. **VLM feedback** on figures. Writes complete papers.
- **Automated Reviewer:** **69% balanced accuracy**, reported to exceed NeurIPS-2021 inter-human agreement (per *Nature*-paper coverage).

## Key results
- v1: per-paper cost under ~$15 [unverified, recalled from the v1 paper].
- v2: 3 fully AI-generated manuscripts were submitted, with organizer consent, to the ICLR 2025 *I Can't Believe It's Not Better* (ICBINB) workshop. One scored an **average of 6.33** (reported as higher than ~55% of human submissions), above the average acceptance threshold. It was withdrawn before publication, as pre-agreed.

## Limitations (authors' own and Weng's)
- Naive or underdeveloped ideas, weak methodological rigor, difficulty with complex code, hallucinations (including citations).
- Weng: "paper production is not identical to scientific discovery". Risks: fabricated citations, implementation drift, weak results.
- A workshop bar is low, and reviewer scores are a gameable proxy.

## Why it matters for RSI / harness engineering
The canonical example of a **workflow-designed harness** for auto-research (Weng's §Workflow Design). AI-generated research passing *some* peer review is a milestone, but the system does not improve itself. It is automation, not recursion.

## Interview hooks
- Template-based vs. template-free (generality vs. reliability).
- What metric should replace "a reviewer accepted it"? Independent replication, held-out transfer, chain-of-evidence audits.
