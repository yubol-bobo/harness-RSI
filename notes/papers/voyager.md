# Voyager — An Open-Ended Embodied Agent with Large Language Models

- **Authors:** Guanzhi Wang, Yuqi Xie, Yunfan Jiang, Ajay Mandlekar, Chaowei Xiao, Yuke Zhu, Linxi Fan, Anima Anandkumar
- **Year / Venue:** 2023 / TMLR 2024
- **Link:** https://arxiv.org/abs/2305.16291
- **Ladder level:** 2 (executable skill library) — tool/skill creation

## TL;DR
A GPT-4 Minecraft agent that (1) proposes its own curriculum, (2) writes code skills via iterative prompting with environment feedback and self-verification, and (3) stores verified skills in an ever-growing, retrievable, composable skill library.

## Problem
Lifelong learning in an open-ended world without fine-tuning and without catastrophic forgetting.

## Method
1. **Automatic curriculum:** GPT-4 proposes the next task given state and progress (novelty-seeking).
2. **Iterative prompting:** write JavaScript (Mineflayer) code; execute; feed back env feedback, execution errors, and self-verification critique; revise.
3. **Self-verification:** a GPT-4 critic checks task success.
4. **Skill library:** store successful programs indexed by embeddings of their descriptions; retrieve top-k for new tasks; skills call other skills (compositional).

## Key results (abstract)
- 3.3× more unique items, 2.3× longer distances traveled, and unlocks key tech-tree milestones up to 15.3× faster than prior SOTA.
- Skill library transfers to a new Minecraft world to solve novel tasks.

## Why it matters for RSI
Shows "skills as code" persistent improvement — the precursor to today's skill files (Claude/Codex Skills), Live-SWE-agent's tool creation, and AHE's "skill" component.

## Limitations
- Relies on a strong model (GPT-4) and an LLM self-verifier (can be wrong).
- Domain-specific API; library growth and retrieval quality issues.

## Connections
AWM (workflows), ExpeL (insights), Live-SWE-agent (tools on the fly), Alita-G (MCP tool generation), DGM (code self-modification).

## Questions to think about
1. What's the difference between a skill library and a harness edit?
2. How would you prevent the library filling with near-duplicate or subtly wrong skills?
