# ExpeL — LLM Agents Are Experiential Learners

- **Authors:** Andrew Zhao, Daniel Huang, Quentin Xu, Matthieu Lin, Yong-Jin Liu, Gao Huang
- **Year / Venue:** 2023 / AAAI 2024
- **Link:** https://arxiv.org/abs/2308.10144
- **Ladder level:** 2 (cross-task insight memory)

## TL;DR
The agent gathers experience on training tasks (with Reflexion-style retries), then extracts reusable natural-language insights by comparing successes with failures and stores successful trajectories; at test time it uses insights + retrieved similar trajectories — no weight updates.

## Problem
Reflexion-style lessons don't transfer across tasks; fine-tuning is expensive or impossible for API models.

## Method
1. **Experience gathering:** run tasks with retries; store success/failure trajectories.
2. **Insight extraction:** LLM compares failed vs. successful trajectories (and sets of successes) and edits an insight list via operations ADD, EDIT, UPVOTE, DOWNVOTE (insights with low votes get removed).
3. **Inference:** insights in the prompt + top-k similar successful trajectories retrieved as few-shot examples.

## Key results
- Improves over ReAct/Reflexion-style baselines on HotpotQA, ALFWorld, WebShop, with positive transfer to FEVER **[qualitative; exact numbers not verified here]**.

## Why it matters for RSI
A clean early example of *persistent* non-parametric self-improvement with explicit memory-maintenance operations (voting = a primitive acceptance rule). ACE's itemized bullets with helpful/harmful counters are a direct descendant.

## Limitations
- Insight quality depends on the LLM; noisy votes; no held-out acceptance.
- Insights accumulate in-context (scalability).

## Connections
Reflexion, ACE, AWM, Dynamic Cheatsheet, Voyager (skills as code instead of insights).

## Questions to think about
1. Is the ADD/EDIT/VOTE scheme an implicit evolutionary algorithm? What's its fitness?
2. When should an insight be deleted?
