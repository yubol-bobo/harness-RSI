# Why LLMs Aren't Scientists Yet: Lessons from Four Autonomous Research Attempts

- **Who / when:** Dhruv Trehan & Paras Chopra (Lossfunk). arXiv [2601.03315](https://arxiv.org/abs/2601.03315), Jan 2026. Artifacts: github.com/Lossfunk/ai-scientist-artefacts-v1.
- **One-line:** a careful negative-results case study. Run the idea-to-paper pipeline with minimal scaffolding and catalog how it fails.

## Setup
- A pipeline of **six LLM agents** mapped to workflow stages, with basic tools (`read_file`, `write_file`, `llm_search`, `list_files`) and a per-idea workspace.
- Three domains: world models, multi-agent RL, AI safety & alignment. Each had **45–50 seed documents**.
- Human experts selected **4 ideas** for the full pipeline. **3 failed** in implementation or evaluation. **1 completed** and was **accepted at Agents4Science 2025** (an inaugural venue requiring AI first authors, with both human and AI review).

## The six failure modes (memorize)
1. **Bias toward training-data defaults:** stale libraries and commands, assumed formats.
2. **Implementation drift under execution pressure:** slides toward a simpler common method.
3. **Memory/context degradation** over long horizons.
4. **Over-excitement / over-optimism:** declares success despite failure (compare Bubeck's "p-hacking and eureka-ing").
5. **Insufficient domain intelligence:** tacit craft knowledge (implementation complexity, plausibility, which baselines matter).
6. **Weak scientific taste:** experiments run but don't answer the right question.

## Why it matters
It is the cleanest taxonomy of auto-research failure, and Weng cites it as the reason "paper production ≠ discovery". Each mode maps to a harness mitigation (see note 06 §3.1).

## Caveats
- n = 4 attempts. Qualitative. Model and scaffold choices fixed in late 2025.
