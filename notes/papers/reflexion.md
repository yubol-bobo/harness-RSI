# Reflexion — Language Agents with Verbal Reinforcement Learning

- **Authors:** Noah Shinn, Federico Cassano, Edward Berman, Ashwin Gopinath, Karthik Narasimhan, Shunyu Yao
- **Year / Venue:** 2023 / NeurIPS 2023
- **Link:** https://arxiv.org/abs/2303.11366
- **Ladder level:** 2 (episodic verbal memory)

## TL;DR
After a failed attempt, the agent writes a natural-language self-reflection about what went wrong; reflections are stored in an episodic memory buffer and conditioned on in the next trial — "RL" with words instead of gradients.

## Problem
LLM agents can't easily learn from trial-and-error without expensive fine-tuning.

## Method
1. Actor generates a trajectory (ReAct/CoT-style).
2. Evaluator scores it (binary env reward, unit tests, heuristics, or LLM).
3. Self-reflection model converts (trajectory, reward) into a verbal lesson.
4. Append lesson to memory (bounded window); retry the task with lessons in context.

## Key results
- 91% pass@1 on HumanEval vs. 80% for the GPT-4 baseline at the time (abstract).
- Improvements on ALFWorld decision-making and HotpotQA reasoning **[exact numbers: see paper]**.

## Why it matters for RSI
The prototypical "verbal RL" loop; the ancestor of ACE's Reflector and every "reflect on traces" step in harness evolution. But mostly **within-task** retries → closer to self-refinement than persistent improvement in awesome-rsi's terminology.

## Limitations
- Needs a reliable evaluator (cf. "LLMs cannot self-correct reasoning yet").
- Lessons are task-specific; memory window is small; no cross-task consolidation.

## Connections
Self-Refine, ExpeL (cross-task insights), ACE, GEPA, TextGrad.

## Questions to think about
1. What changes when reflections must generalize across tasks (ExpeL) instead of retries?
2. How would you detect a wrong reflection that hurts future trials?
