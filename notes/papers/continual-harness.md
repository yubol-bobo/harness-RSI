# Continual Harness — Online Adaptation for Self-Improving Foundation Agents

- **Authors:** Seth Karten, Joel Zhang, et al. (Princeton, ARISE Foundation, Google DeepMind) **[full list: see paper]**
- **Year / Venue:** 2026 (arXiv May 2026) / preprint
- **Link:** https://arxiv.org/abs/2605.09998
- **Ladder level:** 4 (online harness) + weight co-learning

## TL;DR
A reset-free framework where an LLM *Refiner* rewrites the harness — system prompt, sub-agents, skills, memory — in place, mid-episode, via CRUD edits over a trajectory window; evaluated on long-horizon Pokémon (Red, Emerald). Extended to jointly train an open model's weights.

## Problem
Most harness evolution assumes episodic resets and batch evaluation. Long-horizon embodied/game agents live in one continuous trajectory.

## Method
1. Start from a minimal environment interface (frames, ASCII map, button inputs).
2. Agent acts; periodically a Refiner inspects a recent trajectory window and applies create/read/update/delete edits to harness state (via an `evolve_harness` tool per the repo).
3. Optional weight co-learning: online DAgger + process-reward-model pipeline; distill a strong teacher's labels on low-reward trajectories into the policy model.
- Related: the Gemini Plays Pokémon harness (human-in-the-loop refinement) finished several Pokémon games (repo).

## Key results
- Online harness refinement improves progress in Pokémon Red/Emerald relative to static harnesses **[qualitative; numbers not verified]**.

## Why it matters for RSI
Shows harness self-improvement as *continual learning* without episode boundaries, and a bridge to joint harness+weights updates.

## Limitations
- Hard to evaluate (single long trajectory, high variance); stability of in-place self-edits; teacher dependence for weight learning.

## Connections
Live-SWE-agent (online scaffold evolution), DemoEvolve (sparse long-horizon feedback), SIA (harness+weights), Voyager.

## Questions to think about
1. How do you roll back a bad self-edit in a reset-free setting?
2. What's the right timescale separation between harness edits and weight updates?
