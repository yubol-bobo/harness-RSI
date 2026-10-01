# ReTool: Reinforcement Learning for Strategic Tool Use in LLMs

- **Authors:** ByteDance Seed (co-first authors; see arXiv)
- **Year:** 2025 (arXiv April 2025); ICLR 2026
- **Link:** https://arxiv.org/abs/2504.11536

## TL;DR
Teach a reasoning model **when and how to call a code interpreter** in the middle of its chain of thought, using RL with real-time multi-turn code execution and outcome rewards.

## Method
1. **Cold start:** build a dataset of long-form reasoning with code-interpreter calls interleaved (synthetic code-augmented reasoning traces), and SFT on it.
2. **Tool-integrated RL:** policy rollouts interleave natural-language reasoning with real code execution in a sandbox; interpreter outputs are fed back into the context; reward is the final-answer outcome.

## Results (verified from abstract)
- **ReTool-32B: 67% on AIME 2024 after 400 RL steps**, vs. **40% after 1,080 steps** for a text-only RL baseline.
- **72.5%** in an extended setting (reported as +27.9 points over OpenAI o1-preview).

## Relevance to harness / RSI
- The **tool and its sandbox are part of the RL environment**: harness design (tool interface, error messages, timeouts) shapes what is learned.
- The model internalizes part of the harness policy (when to call tools), a step toward "native" agents.
- Safety: any tool with code execution in RL needs limits enforced outside the code the model writes (cf. the AI Scientist editing its own timeout).

## Questions to prepare
- Should interpreter output tokens be masked from the loss? Why? (They are not the policy's actions.)
- How could the policy reward-hack with a code interpreter (e.g., brute-force search, reading files with answers)? How to prevent it?
- How would you extend ReTool to multiple tools and longer horizons?
