# RE-Bench: Evaluating frontier AI R&D capabilities of language model agents against human experts

- **Who / when:** Hjalmar Wijk et al. (METR). arXiv [2411.15114](https://arxiv.org/abs/2411.15114), Nov 2024. ICML 2025.
- **One-line:** 7 open-ended ML research-engineering environments with **direct comparison to 61 human experts at matched time budgets**.

## Design
- Each env = (scoring function, starting solution, reference solution), and runs on ≤8 H100s.
- Examples: optimize a GPU kernel, run a scaling-law experiment, fix a corrupted embedding, finetune GPT-2 for QA, optimize LLM-foundry training, etc.
- Score normalized so starting = 0 and reference = 1.
- Human data: **71 eight-hour attempts by 61 experts**.

## Results (late-2024 agents, e.g. Claude 3.5 Sonnet, o1-preview)
- Humans: nonzero score in **82%** of attempts. **24%** matched or beat the reference.
- With a **2 h** total budget, the best agents scored **4x** humans.
- Humans showed better **returns to time**: they narrowly beat agents at **8 h**, and reached **2x** the agents at **32 h**.
- Agents generate and test solutions >10x faster and far cheaper.

## Caveats
- Only 7 envs, so there is high variance. Agents found some exploits in the scoring functions [recalled].
- Now part of METR's time-horizon suite and lab-internal AI R&D evals. Newer frontier scores appear mostly in system cards.

## Interview hooks
- The **returns-to-time curve** is the key idea. Fast iteration beats humans short-term. Sustained insight wins long-term. Time-horizon growth erodes the human advantage.
