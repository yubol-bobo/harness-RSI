# UI-TARS-2 Technical Report: Advancing GUI Agent with Multi-Turn Reinforcement Learning

- **Authors:** ByteDance Seed (large team)
- **Year:** 2025 (arXiv 2025-09-02)
- **Link:** https://arxiv.org/abs/2509.02544 · predecessor UI-TARS: https://arxiv.org/abs/2501.12326

## TL;DR
A native GUI agent model (screen in, mouse/keyboard/terminal actions out) trained with a **data flywheel** and **stabilized multi-turn RL** in a **hybrid GUI + file-system + terminal environment**, on a **unified sandbox platform** for large-scale rollouts.

## Method
1. **Data flywheel:** iteratively improve model and data together. Starting from Seed1.6 pretrained checkpoints: continual pre-training → SFT → multi-turn RL; the improved model generates the next round's data.
2. **Stabilized multi-turn RL** for long-horizon GUI tasks.
3. **Hybrid environment:** GUI plus file systems and terminals, so the agent isn't limited to clicking.
4. **Unified sandbox platform** to run large numbers of environments reliably.
- Lineage: UI-TARS (Jan 2025) introduced "iterative training with reflective online traces" collected on hundreds of VMs.

## Results (verified from abstract)
- Online-Mind2Web **88.2**, OSWorld **47.5**, WindowsAgentArena **50.6**, AndroidWorld **73.3**; reported to outperform UI-TARS-1.5 and Claude / OpenAI agents at the time.
- (UI-TARS v1, Jan 2025: OSWorld 24.6 at 50 steps / 22.7 at 15 steps; AndroidWorld 46.6.)

## Relevance to harness / RSI
- The **data flywheel** is persistent self-improvement: the model's rollouts feed its own next training round.
- **Harness design inside RL:** the action space (hybrid GUI + terminal) and the sandbox platform are harness decisions that shape what the policy can learn.
- Trend toward **native agents**: capabilities once in the external harness (planning, reflection) move into the weights; the outside harness keeps tools, sandboxing, permissions, evaluation.

## Questions to prepare
- How do you assign rewards in long-horizon GUI tasks, and how could the agent hack them (e.g., reaching a "success" screen state without doing the task)?
- What makes multi-turn RL unstable (long credit assignment, environment non-determinism, entropy collapse), and what would you try?
- How do you keep the flywheel from collapsing toward easy tasks? (Curriculum, diversity tracking, Agent-World-style gap targeting.)
