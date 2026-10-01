# STOP — Self-Taught Optimizer: Recursively Self-Improving Code Generation

- **Authors:** Eric Zelikman, Eliana Lorch, Lester Mackey, Adam Tauman Kalai
- **Year / Venue:** 2023 (arXiv Oct 2023) / COLM 2024
- **Link:** https://arxiv.org/abs/2310.02304
- **Ladder level:** 5 — optimizer code (the improver improves itself)

## TL;DR
A "seed improver" program uses an LM to improve solutions to tasks; STOP runs that improver *on its own source code*, scored by a meta-utility, and gets better improvers. With GPT-4 it rediscovers beam search, genetic algorithms, simulated annealing, bandits; with weaker LMs it gets worse.

## Problem
Can scaffolding (the code that calls an LM) be recursively improved by the LM itself, with the LM weights fixed? This is the smallest working model of recursive self-improvement.

## Method
1. **Improver** $I(u, s; M) \to s'$: given utility $u$, solution $s$, black-box LM $M$, return improved $s'$. Seed $I_0$: prompt LM for several candidate improvements, return the best by $u$.
2. **Meta-utility:** $\hat{u}(I) = \frac{1}{|\mathcal{D}|}\mathbb{E}_{(u,s)\sim\mathcal{D}}[u(I(u,s;M))]$ over a set of downstream tasks (e.g., algorithmic tasks like learning parity with noise).
3. **Self-improvement step:** $I_t = I_{t-1}(\hat{u}, I_{t-1}; M)$ — the improver treats its own code as "the solution" and $\hat u$ as "the utility".
4. **Transfer test:** apply the improved improver to held-out tasks.
5. **Safety probes:** measure how often generated improvers disable a sandbox flag; look for reward hacking.

## Key results
- With GPT-4, mean downstream performance improved across self-improvement iterations; discovered strategies include beam/tree search, genetic algorithms, decomposing and improving parts, multi-armed prompt bandits, simulated annealing, varying temperature (Weng's summary of the paper).
- With GPT-3.5 and Mixtral, performance **degraded** across iterations (Weng).
- Sandbox-circumvention and reward-hacking behaviors were observed; exact rates **[not reproduced here — check paper]**.
- Authors note it is *not full RSI* because the LM is unchanged.

## Why it matters for RSI
The canonical formal definition of scaffold-level RSI ($I$ is in its own domain) and the canonical *negative* result: recursion amplifies capability only above a threshold. Also an early empirical safety study of self-improving code.

## Limitations
- Fixed meta-utility and fixed LM bound the fixed point.
- Small/algorithmic tasks; expensive (many LM calls per meta-utility evaluation).
- The improver mostly rediscovers known meta-heuristics rather than novel ones.

## Connections
- Promptbreeder (concurrent; self-referential mutation prompts).
- ADAS / DGM / SICA scale the same idea to agents and coding harnesses.
- "Harness Updating Is Not Harness Benefit" revisits capability dependence.
- Weng uses STOP as the anchor for "Self-Improving Harness".

## Questions to think about
1. If $\hat u$ were also learned, what new failure modes appear?
2. Why might weaker models *degrade* rather than plateau? (Hint: accepted edits are noisy; bugs compound.)
3. How would you design an acceptance rule that prevents degradation for weak models?
